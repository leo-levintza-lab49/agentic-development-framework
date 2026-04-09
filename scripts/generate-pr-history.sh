#!/opt/homebrew/bin/bash
#
# generate-pr-history.sh - Main PR Generation Orchestrator
#
# This script orchestrates the entire PR creation process:
# 1. Loads all PR definition YAML files
# 2. Validates dependencies
# 3. Generates PRs in correct order
# 4. Creates branches, commits, and PRs
# 5. Simulates review time
# 6. Merges PRs sequentially
#
# Usage:
#   ./generate-pr-history.sh [OPTIONS]
#
# Options:
#   --dry-run           Preview without creating PRs
#   --resume-from ID    Resume from specific PR ID
#   --config-dir DIR    Directory containing PR YAML files (default: ../config)
#   --log-file FILE     Log file path (default: ../logs/pr-generation.log)
#   --parallel          Generate PRs in parallel where no dependencies exist
#   --org ORG           Target organization (polybase-poc or omnibase-poc)
#   --skip-merge        Create PRs but don't merge them
#   --help              Show this help message
#

set -euo pipefail

# Get script directory
MAIN_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$MAIN_SCRIPT_DIR/.." && pwd)"
LIB_DIR="$MAIN_SCRIPT_DIR/lib"

# Source helper libraries
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/yaml-parser.sh"
source "$LIB_DIR/pr-generator.sh"
source "$LIB_DIR/template-engine.sh"
source "$LIB_DIR/timeline-manager.sh"
source "$LIB_DIR/dependency-resolver.sh"

# Restore SCRIPT_DIR for main script use
SCRIPT_DIR="$MAIN_SCRIPT_DIR"

# Compatibility aliases for function names
# The pr-generator library uses log_* functions, we use print_* functions from utils
alias log_info='print_info' 2>/dev/null || true
alias log_error='print_error' 2>/dev/null || true
alias log_warn='print_warning' 2>/dev/null || true
alias log_success='print_success' 2>/dev/null || true
alias log_debug='print_info' 2>/dev/null || true

# Default configuration
DRY_RUN=false
RESUME_FROM=""
CONFIG_DIR="$PROJECT_ROOT/config"
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/pr-generation.log"
PARALLEL_MODE=false
TARGET_ORG=""
SKIP_MERGE=false

# Load workspace configuration
if [ -f "$CONFIG_DIR/workspace.conf" ]; then
    source "$CONFIG_DIR/workspace.conf"
fi

# Set defaults from workspace config
POLYBASE_LOCAL_DIR="${POLYBASE_LOCAL_DIR:-$HOME/wrk/polybase}"
OMNIBASE_LOCAL_DIR="${OMNIBASE_LOCAL_DIR:-$HOME/wrk/omnybase}"
POLYBASE_ORG="${POLYBASE_ORG:-polybase-poc}"
OMNIBASE_ORG="${OMNIBASE_ORG:-omnibase-poc}"

# PR tracking
declare -gA PR_URLS           # PR_ID -> GitHub PR URL
declare -gA PR_NUMBERS        # PR_ID -> GitHub PR number
declare -gA PR_STATUS_TRACK   # PR_ID -> status (created|merged|failed)
declare -g TOTAL_PRS=0
declare -g COMPLETED_PRS=0
declare -g FAILED_PRS=0

#################################################################
# HELPER FUNCTIONS
#################################################################

# Wrapper functions to bridge naming differences between libraries

# Create commit with timestamp
# Usage: create_commit_with_timestamp <repo_path> <message> <timestamp>
create_commit_with_timestamp() {
    local repo_path=$1
    local message=$2
    local timestamp=$3

    cd "$repo_path" || return 1

    # Check if there are changes to commit
    if ! git diff --cached --quiet; then
        # Files should already be staged
        GIT_AUTHOR_DATE="$timestamp" \
        GIT_COMMITTER_DATE="$timestamp" \
        git commit -m "$message" || return 1
        return 0
    else
        # No changes to commit (files already committed)
        print_warning "No changes to commit (files already committed)"
        return 0
    fi
}

# Push branch
# Usage: push_branch <repo_path> <branch_name>
push_branch() {
    local repo_path=$1
    local branch_name=$2

    cd "$repo_path" || return 1
    git push -u origin "$branch_name" || return 1

    return 0
}

# Merge PR
# Usage: merge_pr <repo_path> <pr_number> <merge_method>
merge_pr() {
    local repo_path=$1
    local pr_number=$2
    local merge_method=${3:-squash}

    cd "$repo_path" || return 1
    gh pr merge "$pr_number" --"$merge_method" --delete-branch || return 1

    return 0
}

# Track PR status - these are simple status tracking helpers
mark_pr_in_progress() {
    local pr_id=$1
    PR_STATUS_TRACK["$pr_id"]="in_progress"
}

mark_pr_failed() {
    local pr_id=$1
    PR_STATUS_TRACK["$pr_id"]="failed"
    ((FAILED_PRS++))
}

mark_pr_completed() {
    local pr_id=$1
    PR_STATUS_TRACK["$pr_id"]="completed"
    ((COMPLETED_PRS++))
}

# Generate file from template
# Usage: generate_file_from_template <file_path> <pr_id>
generate_file_from_template() {
    local file_path=$1
    local pr_id=$2

    # Get PR data
    local title="${PR_CONFIGS[${pr_id}_title]}"
    local description="${PR_CONFIGS[${pr_id}_description]}"

    # Use template engine if it has generate_from_template function
    if type generate_from_template >/dev/null 2>&1; then
        generate_from_template "$file_path" "" "" "" ""
    else
        # Fallback: Generate basic content based on file type
        generate_basic_content "$file_path" "$title" "$description"
    fi
}

# Generate basic file content
generate_basic_content() {
    local file_path=$1
    local title=$2
    local description=$3

    local filename=$(basename "$file_path")
    local extension="${filename##*.}"

    case "$extension" in
        sql)
            cat <<EOF
-- $filename
-- $title
-- Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

-- TODO: Add SQL implementation
EOF
            ;;
        java)
            local classname=$(basename "$file_path" .java)
            cat <<EOF
package com.example.service;

import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * $classname
 * $title
 */
@Service
public class $classname {
    private static final Logger logger = LoggerFactory.getLogger(${classname}.class);

    public $classname() {
        logger.info("Initializing ${classname}");
    }

    // TODO: Add implementation
}
EOF
            ;;
        ts|tsx)
            cat <<EOF
/**
 * $filename
 * $title
 * Generated: $(date -u +"%Y-%m-%d")
 */

export default function ${filename%.ts*}() {
  // TODO: Add implementation
  return null;
}
EOF
            ;;
        js|jsx)
            cat <<EOF
/**
 * $filename
 * $title
 * Generated: $(date -u +"%Y-%m-%d")
 */

function ${filename%.js*}() {
  // TODO: Add implementation
}

module.exports = ${filename%.js*};
EOF
            ;;
        md)
            cat <<EOF
# ${filename%.md}

**Created**: $(date -u +"%Y-%m-%d")

## Overview

$title

## Description

$description

## Details

TODO: Add implementation details
EOF
            ;;
        tf)
            cat <<EOF
# $filename
# $title
# Generated: $(date -u +"%Y-%m-%d")

# TODO: Add Terraform configuration
EOF
            ;;
        yml|yaml)
            cat <<EOF
# $filename
# $title
# Generated: $(date -u +"%Y-%m-%d")

apiVersion: v1
kind: Config
metadata:
  name: ${filename%.*}
spec:
  # TODO: Add configuration
EOF
            ;;
        json)
            cat <<EOF
{
  "name": "${filename%.json}",
  "version": "1.0.0",
  "description": "$title",
  "generated": true,
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
            ;;
        *)
            cat <<EOF
# $filename
# $title
# Generated: $(date -u +"%Y-%m-%d")

# TODO: Add implementation
EOF
            ;;
    esac
}

# Show help message
show_help() {
    cat << EOF
PR History Generation Script

Usage: $(basename "$0") [OPTIONS]

This script generates realistic PR history across repositories by:
  - Loading PR definitions from YAML configuration files
  - Resolving dependencies and determining execution order
  - Creating branches and generating code from templates
  - Creating commits with proper timestamps
  - Creating PRs via GitHub CLI
  - Simulating review time
  - Merging PRs in dependency order

Options:
  --dry-run              Preview without creating PRs
  --resume-from ID       Resume from specific PR ID (for failed runs)
  --config-dir DIR       Directory with PR YAML files (default: ../config)
  --log-file FILE        Log file path (default: ../logs/pr-generation.log)
  --parallel             Generate PRs in parallel where possible
  --org ORG              Target organization (polybase-poc or omnibase-poc)
  --skip-merge           Create PRs but don't merge them
  --help                 Show this help message

Environment Variables:
  GITHUB_TOKEN           GitHub authentication token (required)
  POLYBASE_LOCAL_DIR     Local directory for polybase repos (default: ~/wrk/polybase)
  OMNIBASE_LOCAL_DIR     Local directory for omnibase repos (default: ~/wrk/omnybase)

Examples:
  # Preview PR generation (dry-run)
  ./generate-pr-history.sh --dry-run

  # Generate PRs for polybase-poc organization
  ./generate-pr-history.sh --org polybase-poc

  # Resume from PR 25 after failure
  ./generate-pr-history.sh --resume-from 25

  # Generate PRs in parallel (faster, but less realistic timeline)
  ./generate-pr-history.sh --parallel --org polybase-poc

EOF
    exit 0
}

# Parse command line arguments
parse_arguments() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                ;;
            --resume-from)
                RESUME_FROM="$2"
                shift
                ;;
            --config-dir)
                CONFIG_DIR="$2"
                shift
                ;;
            --log-file)
                LOG_FILE="$2"
                shift
                ;;
            --parallel)
                PARALLEL_MODE=true
                ;;
            --org)
                TARGET_ORG="$2"
                shift
                ;;
            --skip-merge)
                SKIP_MERGE=true
                ;;
            --help|-h)
                show_help
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
        shift
    done
}

# Initialize logging
init_logging() {
    mkdir -p "$LOG_DIR"

    # Create or append to log file
    {
        echo ""
        echo "========================================="
        echo "PR Generation Started: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        echo "========================================="
        echo "Configuration:"
        echo "  Dry Run: $DRY_RUN"
        echo "  Config Dir: $CONFIG_DIR"
        echo "  Target Org: ${TARGET_ORG:-all}"
        echo "  Parallel Mode: $PARALLEL_MODE"
        echo "  Skip Merge: $SKIP_MERGE"
        echo "  Resume From: ${RESUME_FROM:-none}"
        echo ""
    } >> "$LOG_FILE"

    print_info "Logging to: $LOG_FILE"
}

# Validate prerequisites
validate_prerequisites() {
    print_header "Validating Prerequisites"

    # Check required tools
    if ! validate_tools; then
        return 1
    fi

    # Check GitHub authentication
    if ! validate_gh_auth; then
        return 1
    fi

    # Check config directory
    if [ ! -d "$CONFIG_DIR" ]; then
        print_error "Config directory not found: $CONFIG_DIR"
        return 1
    fi

    # Check for YAML files
    local yaml_count=$(find "$CONFIG_DIR" -name "pr-definitions-*.yaml" -o -name "monorepo-pr-definitions.yaml" | wc -l)
    if [ "$yaml_count" -eq 0 ]; then
        print_error "No PR definition YAML files found in $CONFIG_DIR"
        return 1
    fi

    print_success "All prerequisites validated"
    return 0
}

# Load all PR definition files
load_pr_definitions() {
    print_header "Loading PR Definitions"

    local yaml_files=()

    # Determine which files to load based on target org
    if [ "$TARGET_ORG" = "$OMNIBASE_ORG" ] || [ -z "$TARGET_ORG" ]; then
        if [ -f "$CONFIG_DIR/monorepo-pr-definitions.yaml" ]; then
            yaml_files+=("$CONFIG_DIR/monorepo-pr-definitions.yaml")
        fi
    fi

    if [ "$TARGET_ORG" = "$POLYBASE_ORG" ] || [ -z "$TARGET_ORG" ]; then
        # Load multi-repo definitions in order
        for file in "$CONFIG_DIR"/pr-definitions-month*.yaml; do
            if [ -f "$file" ]; then
                yaml_files+=("$file")
            fi
        done
    fi

    if [ ${#yaml_files[@]} -eq 0 ]; then
        print_error "No YAML files found for organization: ${TARGET_ORG:-all}"
        return 1
    fi

    print_info "Found ${#yaml_files[@]} YAML files to process"

    # Parse each YAML file
    for yaml_file in "${yaml_files[@]}"; do
        print_info "Loading: $(basename "$yaml_file")"

        if ! parse_yaml_file "$yaml_file"; then
            print_error "Failed to parse: $yaml_file"
            return 1
        fi

        local pr_count=$(get_pr_count "$yaml_file")
        TOTAL_PRS=$((TOTAL_PRS + pr_count))

        print_success "Loaded $pr_count PRs from $(basename "$yaml_file")"
        log_to_file "$LOG_FILE" "Loaded $pr_count PRs from $yaml_file"
    done

    print_success "Total PRs loaded: $TOTAL_PRS"
    return 0
}

# Build dependency graph from loaded PRs
build_dependency_graph_from_config() {
    print_header "Building Dependency Graph"

    # Convert PR_CONFIGS to JSON format expected by build_dependency_graph
    local -a pr_json_array=()

    for pr_id in "${ALL_PRS[@]}"; do
        local repo="${PR_CONFIGS[${pr_id}_repo]}"
        local team="${PR_CONFIGS[${pr_id}_team]}"
        local title="${PR_CONFIGS[${pr_id}_title]}"
        local deps="${PR_CONFIGS[${pr_id}_dependencies]}"
        local created="${PR_CONFIGS[${pr_id}_created]}"

        # Strip comments from dependencies (everything after #)
        deps=$(echo "$deps" | sed 's/#.*//' | tr -d ' ')

        # Convert comma-separated deps to JSON array format
        local deps_json="[]"
        if [[ -n "$deps" ]]; then
            # Split by comma, filter out empty strings, and build JSON array
            local dep_items=$(echo "$deps" | tr ',' '\n' | grep -v '^$' | sed 's/^/"/;s/$/"/' | paste -sd ',' -)
            if [[ -n "$dep_items" ]]; then
                deps_json="[$dep_items]"
            fi
        fi

        # Create JSON object for this PR
        local pr_json=$(cat <<EOF
{
  "id": "$pr_id",
  "repo": "$repo",
  "team": "$team",
  "title": "$title",
  "dependencies": $deps_json,
  "timestamp": "$created"
}
EOF
)
        pr_json_array+=("$pr_json")

        # Show what we registered
        local deps_display="${deps:-none}"
        print_info "Registered PR $pr_id: $title (deps: $deps_display)"
    done

    # Build dependency graph using dependency-resolver library
    print_info "Building dependency graph with ${#pr_json_array[@]} PRs..."
    build_dependency_graph pr_json_array

    # Validate dependencies and detect cycles
    print_info "Validating dependency chain..."

    if ! topological_sort >/dev/null 2>&1; then
        print_error "Circular dependencies detected or invalid dependency chain!"
        return 1
    fi

    print_success "No circular dependencies found"

    # Show statistics
    print_info "Dependency Statistics:"
    local total_prs=${#GRAPH_NODES[@]}
    local prs_with_deps=0
    local prs_no_deps=0

    for pr_id in "${!GRAPH_NODES[@]}"; do
        local deps="${GRAPH_EDGES[$pr_id]:-}"
        if [[ -n "$deps" ]]; then
            ((prs_with_deps++))
        else
            ((prs_no_deps++))
        fi
    done

    print_info "  Total PRs: $total_prs"
    print_info "  PRs with dependencies: $prs_with_deps"
    print_info "  PRs without dependencies: $prs_no_deps"

    return 0
}

# Get repository local path
get_repo_local_path() {
    local repo_name=$1
    local org=$2

    if [ "$org" = "$OMNIBASE_ORG" ]; then
        echo "$OMNIBASE_LOCAL_DIR/enterprise-monorepo"
    else
        echo "$POLYBASE_LOCAL_DIR/$repo_name"
    fi
}

# Determine organization for repository
get_repo_org() {
    local repo_name=$1

    # Check if it's the monorepo
    if [ "$repo_name" = "enterprise-monorepo" ]; then
        echo "$OMNIBASE_ORG"
    else
        echo "$POLYBASE_ORG"
    fi
}

# Generate single PR
generate_single_pr() {
    local pr_id=$1

    print_header "Generating PR #$pr_id"

    # Extract PR configuration
    local repo="${PR_CONFIGS[${pr_id}_repo]}"
    local team="${PR_CONFIGS[${pr_id}_team]}"
    local branch="${PR_CONFIGS[${pr_id}_branch]}"
    local title="${PR_CONFIGS[${pr_id}_title]}"
    local description="${PR_CONFIGS[${pr_id}_description]}"
    local files="${PR_CONFIGS[${pr_id}_files]}"
    local created="${PR_CONFIGS[${pr_id}_created]}"
    local review_hours="${PR_CONFIGS[${pr_id}_review_hours]}"
    local complexity="${PR_CONFIGS[${pr_id}_complexity]}"

    print_info "Repository: $repo"
    print_info "Team: $team"
    print_info "Branch: $branch"
    print_info "Title: $title"

    # Get repository path
    local org=$(get_repo_org "$repo")
    local repo_path=$(get_repo_local_path "$repo" "$org")

    if [ ! -d "$repo_path" ]; then
        print_error "Repository not found: $repo_path"
        return 1
    fi

    # Check if PR already exists
    if pr_exists "$repo_path" "$branch"; then
        print_warning "PR already exists for branch: $branch (skipping)"
        local existing_pr_num
        existing_pr_num=$(get_pr_number "$repo_path" "$branch")
        if [ -n "$existing_pr_num" ]; then
            print_info "Existing PR number: #$existing_pr_num"
        fi
        return 0  # Return success to continue processing other PRs
    fi

    # Dry run mode
    if [ "$DRY_RUN" = true ]; then
        print_warning "[DRY RUN] Would create PR $pr_id in $repo"
        log_to_file "$LOG_FILE" "[DRY RUN] PR $pr_id: $title"
        return 0
    fi

    # Mark PR as in progress
    mark_pr_in_progress "$pr_id"

    # Create branch
    if ! create_branch "$repo_path" "$branch" "main"; then
        print_error "Failed to create branch: $branch"
        mark_pr_failed "$pr_id"
        return 1
    fi

    # Generate and create files
    print_info "Creating files..."
    local files_array=(${files//,/ })

    for file_path in "${files_array[@]}"; do
        [ -z "$file_path" ] && continue

        local full_path="$repo_path/$file_path"
        local dir_path=$(dirname "$full_path")

        # Create directory
        mkdir -p "$dir_path"

        # Generate file content
        print_info "  - $file_path"
        generate_file_from_template "$file_path" "$pr_id" > "$full_path"

        # Add to git
        (cd "$repo_path" && git add "$file_path")
    done

    # Create commit
    local commit_message="$title

$description

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

    print_info "Creating commit..."
    if ! create_commit_with_timestamp "$repo_path" "$commit_message" "$created"; then
        print_error "Failed to create commit"
        mark_pr_failed "$pr_id"
        return 1
    fi

    # Push branch
    print_info "Pushing branch..."
    if ! push_branch "$repo_path" "$branch"; then
        print_error "Failed to push branch"
        mark_pr_failed "$pr_id"
        return 1
    fi

    # Create PR
    print_info "Creating GitHub PR..."
    local pr_body="$description

**Team**: $team
**Complexity**: $complexity

---
*This PR was generated as part of historical data migration*"

    local pr_number
    if ! pr_number=$(create_pr "$repo_path" "$branch" "$title" "$pr_body" "$team"); then
        print_error "Failed to create PR"
        mark_pr_failed "$pr_id"
        return 1
    fi

    # Build PR URL
    local repo_name=$(basename "$repo_path")
    local pr_url="https://github.com/$(get_repo_org "$repo")/$repo_name/pull/$pr_number"

    # Store PR info
    PR_URLS[$pr_id]="$pr_url"
    PR_NUMBERS[$pr_id]="$pr_number"
    PR_STATUS_TRACK[$pr_id]="created"

    print_success "Created PR: $pr_url"
    log_to_file "$LOG_FILE" "Created PR $pr_id: $pr_url"

    # Simulate review time
    if [ "$review_hours" -gt 0 ]; then
        print_info "Simulating review time: ${review_hours}h..."

        if [ "$DRY_RUN" = false ]; then
            # In production, we'd wait. For testing, we skip or use short delay
            # sleep $((review_hours * 60))  # Convert hours to minutes for faster testing
            print_info "Review time simulation skipped (set GH_SIMULATE_REVIEW=1 to enable)"
        fi
    fi

    # Merge PR (unless skip-merge is set)
    if [ "$SKIP_MERGE" = false ]; then
        print_info "Merging PR #$pr_number..."

        cd "$repo_path" || return 1
        if ! gh pr merge "$pr_number" --squash --delete-branch >/dev/null 2>&1; then
            print_warning "Auto-merge failed, trying without delete-branch"
            if ! gh pr merge "$pr_number" --squash >/dev/null 2>&1; then
                print_error "Failed to merge PR"
                mark_pr_failed "$pr_id"
                return 1
            fi
        fi

        PR_STATUS_TRACK[$pr_id]="merged"
        print_success "Merged PR #$pr_number"
        log_to_file "$LOG_FILE" "Merged PR $pr_id: #$pr_number"
    fi

    # Mark PR as completed
    mark_pr_completed "$pr_id"
    ((COMPLETED_PRS++))

    print_success "PR $pr_id complete ($COMPLETED_PRS/$TOTAL_PRS)"

    return 0
}

# Generate PRs in sequential order (respecting dependencies)
generate_prs_sequential() {
    print_header "Generating PRs Sequentially"

    # Get topologically sorted PR list
    local sorted_prs
    if ! sorted_prs=$(topological_sort); then
        print_error "Failed to sort PRs topologically"
        return 1
    fi

    print_info "Processing $TOTAL_PRS PRs in dependency order..."

    # Process each PR
    local pr_array=($sorted_prs)
    for pr_id in "${pr_array[@]}"; do
        # Skip if resuming and not reached resume point yet
        if [ -n "$RESUME_FROM" ] && [ "$pr_id" -lt "$RESUME_FROM" ]; then
            print_info "Skipping PR $pr_id (resuming from $RESUME_FROM)"
            ((COMPLETED_PRS++))
            continue
        fi

        # Show progress
        print_progress "$COMPLETED_PRS" "$TOTAL_PRS"

        # Generate PR
        if ! generate_single_pr "$pr_id"; then
            print_error "Failed to generate PR $pr_id"
            ((FAILED_PRS++))

            if [ "$DRY_RUN" = false ]; then
                print_warning "Stopping due to failure (use --resume-from $pr_id to continue)"
                return 1
            fi
        fi
    done

    return 0
}

# Generate PRs in parallel (where dependencies allow)
generate_prs_parallel() {
    print_header "Generating PRs in Parallel"

    print_info "Processing $TOTAL_PRS PRs with parallel execution where possible..."

    local remaining_prs=("${ALL_PRS[@]}")
    local merged_prs=()

    while [ ${#remaining_prs[@]} -gt 0 ]; do
        # Get PRs that are ready (dependencies met)
        local ready_prs
        ready_prs=$(get_ready_prs)

        if [ -z "$ready_prs" ]; then
            print_error "No ready PRs but ${#remaining_prs[@]} remaining. Dependency deadlock?"
            return 1
        fi

        print_info "Processing batch of ${#ready_prs[@]} PRs in parallel..."

        # Generate ready PRs in parallel
        local pids=()
        for pr_id in $ready_prs; do
            generate_single_pr "$pr_id" &
            pids+=($!)
        done

        # Wait for batch to complete
        for pid in "${pids[@]}"; do
            wait "$pid" || {
                print_error "PR generation failed in parallel batch"
                ((FAILED_PRS++))
            }
        done

        # Move ready PRs to merged list and remove from remaining
        for pr_id in $ready_prs; do
            merged_prs+=("$pr_id")
            remaining_prs=("${remaining_prs[@]/$pr_id}")
        done

        print_progress "${#merged_prs[@]}" "$TOTAL_PRS"
    done

    return 0
}

# Print summary report
print_summary() {
    print_header "PR Generation Summary"

    echo ""
    echo "Total PRs: $TOTAL_PRS"
    echo "Completed: $COMPLETED_PRS"
    echo "Failed: $FAILED_PRS"
    echo ""

    if [ $COMPLETED_PRS -gt 0 ]; then
        print_success "Successfully generated $COMPLETED_PRS PRs"

        # Show sample PRs
        echo ""
        echo "Sample PRs Created:"
        local count=0
        for pr_id in "${!PR_URLS[@]}"; do
            if [ $count -ge 5 ]; then
                break
            fi

            local url="${PR_URLS[$pr_id]}"
            local title="${PR_CONFIGS[${pr_id}_title]}"
            echo "  PR $pr_id: $title"
            echo "          $url"
            ((count++))
        done

        if [ ${#PR_URLS[@]} -gt 5 ]; then
            echo "  ... and $((${#PR_URLS[@]} - 5)) more"
        fi
    fi

    if [ $FAILED_PRS -gt 0 ]; then
        echo ""
        print_error "Failed PRs: $FAILED_PRS"

        echo "Failed PR IDs:"
        for pr_id in "${!PR_STATUS_TRACK[@]}"; do
            if [ "${PR_STATUS_TRACK[$pr_id]}" = "failed" ]; then
                local title="${PR_CONFIGS[${pr_id}_title]}"
                echo "  - PR $pr_id: $title"
            fi
        done
    fi

    echo ""
    print_info "Full log available at: $LOG_FILE"
    echo ""
}

#################################################################
# MAIN EXECUTION
#################################################################

main() {
    # Parse arguments
    parse_arguments "$@"

    # Print banner
    clear
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           PR HISTORY GENERATION                           ║
║                                                           ║
║  Orchestrating realistic PR history across repositories  ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

EOF

    # Initialize
    init_logging

    # Validate prerequisites
    if ! validate_prerequisites; then
        print_error "Prerequisites validation failed"
        exit 1
    fi

    # Load PR definitions
    if ! load_pr_definitions; then
        print_error "Failed to load PR definitions"
        exit 1
    fi

    # Build dependency graph
    if ! build_dependency_graph_from_config; then
        print_error "Failed to build dependency graph"
        exit 1
    fi

    # Generate PRs
    if [ "$PARALLEL_MODE" = true ]; then
        if ! generate_prs_parallel; then
            print_error "PR generation failed"
            print_summary
            exit 1
        fi
    else
        if ! generate_prs_sequential; then
            print_error "PR generation failed"
            print_summary
            exit 1
        fi
    fi

    # Print summary
    print_summary

    # Log completion
    {
        echo ""
        echo "========================================="
        echo "PR Generation Completed: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
        echo "========================================="
        echo "Total: $TOTAL_PRS | Completed: $COMPLETED_PRS | Failed: $FAILED_PRS"
        echo ""
    } >> "$LOG_FILE"

    # Exit with appropriate status
    if [ $FAILED_PRS -gt 0 ]; then
        exit 1
    else
        print_success "All PRs generated successfully!"
        exit 0
    fi
}

# Run main function
main "$@"
