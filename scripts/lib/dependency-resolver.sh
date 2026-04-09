#!/usr/bin/env bash
# dependency-resolver.sh - Manage PR dependencies and merge order
# Provides functions for building dependency graphs, topological sorting,
# and validating dependency chains.

set -euo pipefail

# Build dependency graph from all PRs
# Args: pr_configs_array (name reference)
# Returns: Populates global associative arrays:
#   - GRAPH_EDGES: adjacency list (pr_id -> space-separated list of dependencies)
#   - GRAPH_NODES: all PR IDs
#   - GRAPH_DEPENDENTS: reverse graph (pr_id -> space-separated list of dependents)
build_dependency_graph() {
    local -n prs="$1"

    # Initialize global graph structures
    declare -gA GRAPH_EDGES
    declare -gA GRAPH_NODES
    declare -gA GRAPH_DEPENDENTS

    # First pass: register all nodes
    for pr_config in "${prs[@]}"; do
        local pr_id
        pr_id=$(jq -r '.id' <<< "$pr_config")
        GRAPH_NODES["$pr_id"]=1
        GRAPH_EDGES["$pr_id"]=""
        GRAPH_DEPENDENTS["$pr_id"]=""
    done

    # Second pass: build edges
    for pr_config in "${prs[@]}"; do
        local pr_id dependencies
        pr_id=$(jq -r '.id' <<< "$pr_config")

        # Extract dependencies array (may be empty)
        if dependencies=$(jq -r '.dependencies[]? // empty' <<< "$pr_config" 2>/dev/null); then
            if [[ -n "$dependencies" ]]; then
                # Store dependencies for this PR
                GRAPH_EDGES["$pr_id"]="$dependencies"

                # Build reverse graph (dependents)
                for dep in $dependencies; do
                    if [[ -n "${GRAPH_DEPENDENTS[$dep]:-}" ]]; then
                        GRAPH_DEPENDENTS["$dep"]="${GRAPH_DEPENDENTS[$dep]} $pr_id"
                    else
                        GRAPH_DEPENDENTS["$dep"]="$pr_id"
                    fi
                done
            fi
        fi
    done
}

# Topological sort of PRs using Kahn's algorithm
# Args: None (uses global GRAPH_EDGES and GRAPH_NODES)
# Outputs: sorted list of PR IDs (one per line) to stdout
# Returns: 0 if successful, 1 if cycle detected
topological_sort() {
    local -A in_degree
    local -a queue
    local -a sorted

    # Calculate in-degree for each node
    for node in "${!GRAPH_NODES[@]}"; do
        in_degree["$node"]=0
    done

    for node in "${!GRAPH_EDGES[@]}"; do
        local deps="${GRAPH_EDGES[$node]}"
        if [[ -n "$deps" ]]; then
            for dep in $deps; do
                ((in_degree["$node"]++))
            done
        fi
    done

    # Find all nodes with in-degree 0
    for node in "${!in_degree[@]}"; do
        if [[ ${in_degree[$node]} -eq 0 ]]; then
            queue+=("$node")
        fi
    done

    # Process queue
    while [[ ${#queue[@]} -gt 0 ]]; do
        # Pop from queue
        local current="${queue[0]}"
        queue=("${queue[@]:1}")
        sorted+=("$current")

        # Reduce in-degree of dependents
        local dependents="${GRAPH_DEPENDENTS[$current]:-}"
        if [[ -n "$dependents" ]]; then
            for dependent in $dependents; do
                ((in_degree["$dependent"]--))
                if [[ ${in_degree[$dependent]} -eq 0 ]]; then
                    queue+=("$dependent")
                fi
            done
        fi
    done

    # Check if all nodes were processed (no cycles)
    if [[ ${#sorted[@]} -ne ${#GRAPH_NODES[@]} ]]; then
        echo "ERROR: Circular dependency detected in PR chain" >&2

        # Find nodes still in graph (part of cycle)
        local cycle_nodes=()
        for node in "${!in_degree[@]}"; do
            if [[ ${in_degree[$node]} -gt 0 ]]; then
                cycle_nodes+=("$node")
            fi
        done
        echo "PRs involved in cycle: ${cycle_nodes[*]}" >&2
        return 1
    fi

    # Output sorted list
    printf '%s\n' "${sorted[@]}"
    return 0
}

# Check if PR dependencies are satisfied
# Args: pr_id, merged_prs_list (name reference to array)
# Returns: 0 if all deps met, 1 if not
check_dependencies_met() {
    local pr_id="$1"
    local -n merged="$2"

    # Get dependencies for this PR
    local deps="${GRAPH_EDGES[$pr_id]:-}"

    # If no dependencies, they're trivially satisfied
    if [[ -z "$deps" ]]; then
        return 0
    fi

    # Convert merged array to associative array for O(1) lookup
    local -A merged_set
    for m in "${merged[@]}"; do
        merged_set["$m"]=1
    done

    # Check each dependency
    for dep in $deps; do
        if [[ -z "${merged_set[$dep]:-}" ]]; then
            return 1
        fi
    done

    return 0
}

# Get all PRs that can be processed in parallel
# Args: remaining_prs (name reference to array), merged_prs (name reference to array)
# Outputs: list of PR IDs (one per line) to stdout
# Returns: 0 always
get_ready_prs() {
    local -n remaining="$1"
    local -n merged="$2"

    local -a ready=()

    for pr_id in "${remaining[@]}"; do
        if check_dependencies_met "$pr_id" merged; then
            ready+=("$pr_id")
        fi
    done

    printf '%s\n' "${ready[@]}"
}

# Validate entire dependency chain
# Args: all_pr_configs (name reference to array of JSON strings)
# Outputs: error messages to stderr
# Returns: 0 if valid, 1 if invalid
validate_dependencies() {
    local -n all_prs="$1"
    local errors=0

    # Build PR lookup map
    local -A pr_map
    local -A pr_timestamps

    for pr_config in "${all_prs[@]}"; do
        local pr_id timestamp
        pr_id=$(jq -r '.id' <<< "$pr_config")
        timestamp=$(jq -r '.timestamp // empty' <<< "$pr_config")

        pr_map["$pr_id"]="$pr_config"
        pr_timestamps["$pr_id"]="${timestamp:-0}"
    done

    # Check 1: All referenced dependencies exist
    for pr_config in "${all_prs[@]}"; do
        local pr_id dependencies
        pr_id=$(jq -r '.id' <<< "$pr_config")

        if dependencies=$(jq -r '.dependencies[]? // empty' <<< "$pr_config" 2>/dev/null); then
            for dep in $dependencies; do
                if [[ -z "${pr_map[$dep]:-}" ]]; then
                    echo "ERROR: PR '$pr_id' depends on non-existent PR '$dep'" >&2
                    errors=1
                fi
            done
        fi
    done

    # Check 2: No cycles (build graph and try topological sort)
    build_dependency_graph all_prs
    if ! topological_sort > /dev/null 2>&1; then
        echo "ERROR: Circular dependencies detected in PR chain" >&2
        errors=1
    fi

    # Check 3: Timestamp violations (PR created before its dependency)
    for pr_config in "${all_prs[@]}"; do
        local pr_id pr_timestamp dependencies
        pr_id=$(jq -r '.id' <<< "$pr_config")
        pr_timestamp="${pr_timestamps[$pr_id]}"

        if [[ "$pr_timestamp" != "0" ]]; then
            if dependencies=$(jq -r '.dependencies[]? // empty' <<< "$pr_config" 2>/dev/null); then
                for dep in $dependencies; do
                    local dep_timestamp="${pr_timestamps[$dep]:-0}"
                    if [[ "$dep_timestamp" != "0" && "$pr_timestamp" -lt "$dep_timestamp" ]]; then
                        echo "ERROR: PR '$pr_id' (timestamp: $pr_timestamp) depends on later PR '$dep' (timestamp: $dep_timestamp)" >&2
                        errors=1
                    fi
                done
            fi
        fi
    done

    return $errors
}

# Get dependency depth for a PR (longest path from root)
# Args: pr_id
# Outputs: depth number to stdout
# Returns: 0 always
get_dependency_depth() {
    local pr_id="$1"
    local -A visited
    local -A depths

    _calculate_depth() {
        local node="$1"

        # Return cached result if available
        if [[ -n "${depths[$node]:-}" ]]; then
            echo "${depths[$node]}"
            return 0
        fi

        # Check for cycle
        if [[ -n "${visited[$node]:-}" ]]; then
            echo "0"
            return 0
        fi

        visited["$node"]=1

        # Get dependencies
        local deps="${GRAPH_EDGES[$node]:-}"
        local max_depth=0

        if [[ -n "$deps" ]]; then
            for dep in $deps; do
                local dep_depth
                dep_depth=$(_calculate_depth "$dep")
                if [[ $dep_depth -ge $max_depth ]]; then
                    max_depth=$((dep_depth + 1))
                fi
            done
        fi

        depths["$node"]=$max_depth
        unset 'visited[$node]'
        echo "$max_depth"
    }

    _calculate_depth "$pr_id"
}

# Group PRs by dependency level for parallel processing
# Args: None (uses global graph)
# Outputs: JSON array of levels, each containing PR IDs that can be processed in parallel
# Format: [["pr1", "pr2"], ["pr3"], ["pr4", "pr5"]]
get_parallel_levels() {
    local -a sorted_prs
    local -A pr_levels

    # Get topologically sorted list
    mapfile -t sorted_prs < <(topological_sort)

    # Calculate level for each PR
    for pr_id in "${sorted_prs[@]}"; do
        local deps="${GRAPH_EDGES[$pr_id]:-}"
        local max_dep_level=-1

        if [[ -n "$deps" ]]; then
            for dep in $deps; do
                local dep_level="${pr_levels[$dep]}"
                if [[ $dep_level -gt $max_dep_level ]]; then
                    max_dep_level=$dep_level
                fi
            done
        fi

        pr_levels["$pr_id"]=$((max_dep_level + 1))
    done

    # Group by level
    local -A levels
    for pr_id in "${sorted_prs[@]}"; do
        local level="${pr_levels[$pr_id]}"
        if [[ -n "${levels[$level]:-}" ]]; then
            levels["$level"]="${levels[$level]} $pr_id"
        else
            levels["$level"]="$pr_id"
        fi
    done

    # Output as JSON array
    echo -n "["
    local first=1
    for level in $(printf '%s\n' "${!levels[@]}" | sort -n); do
        if [[ $first -eq 0 ]]; then
            echo -n ","
        fi
        first=0

        echo -n "["
        local pr_first=1
        for pr_id in ${levels[$level]}; do
            if [[ $pr_first -eq 0 ]]; then
                echo -n ","
            fi
            pr_first=0
            echo -n "\"$pr_id\""
        done
        echo -n "]"
    done
    echo "]"
}

# Print dependency graph in human-readable format
# Args: None (uses global graph)
# Outputs: formatted graph to stdout
print_dependency_graph() {
    echo "Dependency Graph:"
    echo "================="

    for pr_id in "${!GRAPH_NODES[@]}"; do
        local deps="${GRAPH_EDGES[$pr_id]:-}"
        local dependents="${GRAPH_DEPENDENTS[$pr_id]:-}"

        echo "PR: $pr_id"

        if [[ -n "$deps" ]]; then
            echo "  Depends on: $deps"
        else
            echo "  Depends on: (none)"
        fi

        if [[ -n "$dependents" ]]; then
            echo "  Required by: $dependents"
        else
            echo "  Required by: (none)"
        fi

        echo ""
    done
}

# Export functions for use in other scripts
export -f build_dependency_graph
export -f topological_sort
export -f check_dependencies_met
export -f get_ready_prs
export -f validate_dependencies
export -f get_dependency_depth
export -f get_parallel_levels
export -f print_dependency_graph
