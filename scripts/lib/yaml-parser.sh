#!/usr/bin/env bash
#
# YAML Parser Library for PR Configuration Files
# Provides robust YAML parsing with multiple fallback strategies
# Requires: bash 4.0+ for associative arrays
#
# If bash 3.x is detected, will attempt to use newer bash from common locations
#

# Check bash version and upgrade if needed (only when executed directly, not sourced)
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    # Only try to exec if being run directly (not sourced)
    if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
        # Try to find a newer bash
        for bash_path in /opt/homebrew/bin/bash /usr/local/bin/bash /opt/homebrew/Cellar/bash/*/bin/bash; do
            if [ -x "$bash_path" ] && [ "$($bash_path -c 'echo ${BASH_VERSINFO[0]}')" -ge 4 ]; then
                exec "$bash_path" "$0" "$@"
            fi
        done
    fi
    echo "ERROR: This script requires bash 4.0 or higher (current: ${BASH_VERSION})" >&2
    echo "Please install bash 4+ using: brew install bash" >&2
    exit 1
fi

# Mark as loaded
export YAML_PARSER_LOADED=true

# Global associative arrays for storing PR configurations
declare -A PR_CONFIGS        # Stores all PR data: PR_CONFIGS["1_repo"]="db-schemas"
declare -a ALL_PRS           # Array of all PR IDs
declare -A PR_DATA_CACHE     # Cache full PR YAML blocks: PR_DATA_CACHE["1"]="yaml_content"

#################################################################
# HELPER FUNCTIONS
#################################################################

# Store value in PR_CONFIGS with proper key format
_store_pr_field() {
    local pr_id="$1"
    local field="$2"
    local value="$3"
    local key="${pr_id}_${field}"
    PR_CONFIGS["$key"]="$value"
}

# Get value from PR_CONFIGS
_get_pr_field_internal() {
    local pr_id="$1"
    local field="$2"
    local key="${pr_id}_${field}"
    echo "${PR_CONFIGS[$key]}"
}

#################################################################
# CORE YAML PARSING FUNCTIONS
#################################################################

# Parse YAML file into bash associative array
# Args: yaml_file_path
# Returns: Populates global PR_CONFIGS associative array
parse_yaml_file() {
    local yaml_file="$1"

    if [ ! -f "$yaml_file" ]; then
        echo "ERROR: YAML file not found: $yaml_file" >&2
        return 1
    fi

    # Try different parsing strategies in order of preference
    if command -v yq >/dev/null 2>&1; then
        _parse_with_yq "$yaml_file"
    elif command -v python3 >/dev/null 2>&1 && python3 -c "import yaml" 2>/dev/null; then
        _parse_with_python "$yaml_file"
    else
        _parse_with_bash "$yaml_file"
    fi
}

# Parse using yq (most reliable)
_parse_with_yq() {
    local yaml_file="$1"

    # Get all PR IDs first
    local pr_ids=$(yq eval '.prs[].id' "$yaml_file")

    for pr_id in $pr_ids; do
        ALL_PRS+=("$pr_id")

        # Extract all fields for this PR
        local pr_yaml=$(yq eval ".prs[] | select(.id == $pr_id)" "$yaml_file")
        PR_DATA_CACHE["$pr_id"]="$pr_yaml"

        # Store individual fields
        _store_pr_field "$pr_id" "id" "$pr_id"
        _store_pr_field "$pr_id" "repo" "$(echo "$pr_yaml" | yq eval '.repo' -)"
        _store_pr_field "$pr_id" "team" "$(echo "$pr_yaml" | yq eval '.team' -)"
        _store_pr_field "$pr_id" "branch" "$(echo "$pr_yaml" | yq eval '.branch' -)"
        _store_pr_field "$pr_id" "title" "$(echo "$pr_yaml" | yq eval '.title' -)"
        _store_pr_field "$pr_id" "complexity" "$(echo "$pr_yaml" | yq eval '.complexity' -)"
        _store_pr_field "$pr_id" "created" "$(echo "$pr_yaml" | yq eval '.created' -)"
        _store_pr_field "$pr_id" "review_hours" "$(echo "$pr_yaml" | yq eval '.review_hours' -)"

        # Handle dependencies array
        local deps=$(echo "$pr_yaml" | yq eval '.dependencies[]' - 2>/dev/null | tr '\n' ',')
        _store_pr_field "$pr_id" "dependencies" "${deps%,}"

        # Handle files array
        local files=$(echo "$pr_yaml" | yq eval '.files[]' - 2>/dev/null | tr '\n' ',')
        _store_pr_field "$pr_id" "files" "${files%,}"
    done
}

# Parse using Python + PyYAML
_parse_with_python() {
    local yaml_file="$1"

    local json_output=$(python3 -c "
import yaml, json, sys
try:
    with open('$yaml_file', 'r') as f:
        data = yaml.safe_load(f)
        print(json.dumps(data))
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
")

    if [ $? -ne 0 ]; then
        echo "ERROR: Python YAML parsing failed" >&2
        return 1
    fi

    # Parse JSON output using bash
    # This is a simplified approach - for production use jq or more robust JSON parsing
    echo "WARNING: Python JSON parsing not fully implemented, falling back to bash parser" >&2
    _parse_with_bash "$yaml_file"
}

# Parse using pure bash (fallback, less robust but works for our YAML structure)
_parse_with_bash() {
    local yaml_file="$1"

    # Extract all PR blocks
    local current_pr_id=""
    local in_pr_block=false
    local pr_block=""

    while IFS= read -r line; do
        # Detect PR block start (match alphanumeric IDs like "M-1" or "1")
        if [[ "$line" =~ ^[[:space:]]{2}-[[:space:]]id:[[:space:]]([A-Za-z0-9-]+) ]]; then
            # Save previous PR block if exists
            if [ -n "$current_pr_id" ]; then
                _parse_pr_block "$current_pr_id" "$pr_block"
            fi

            # Start new PR block
            current_pr_id="${BASH_REMATCH[1]}"
            ALL_PRS+=("$current_pr_id")
            pr_block="$line"$'\n'
            in_pr_block=true

        elif [ "$in_pr_block" = true ]; then
            # Check if we hit the next PR or end of prs section
            if [[ "$line" =~ ^[[:space:]]{2}-[[:space:]]id: ]] || [[ "$line" =~ ^[a-z]+: ]]; then
                # Save current PR block
                _parse_pr_block "$current_pr_id" "$pr_block"
                pr_block=""
                in_pr_block=false

                # Handle next PR
                if [[ "$line" =~ ^[[:space:]]{2}-[[:space:]]id:[[:space:]]([A-Za-z0-9-]+) ]]; then
                    current_pr_id="${BASH_REMATCH[1]}"
                    ALL_PRS+=("$current_pr_id")
                    pr_block="$line"$'\n'
                    in_pr_block=true
                fi
            else
                # Accumulate PR block lines
                pr_block+="$line"$'\n'
            fi
        fi
    done < "$yaml_file"

    # Save last PR block
    if [ -n "$current_pr_id" ] && [ -n "$pr_block" ]; then
        _parse_pr_block "$current_pr_id" "$pr_block"
    fi
}

# Parse a single PR block and store in PR_CONFIGS
_parse_pr_block() {
    local pr_id="$1"
    local pr_block="$2"

    # Cache the full PR block
    PR_DATA_CACHE["$pr_id"]="$pr_block"

    # Store ID
    _store_pr_field "$pr_id" "id" "$pr_id"

    # Extract simple fields (format: "  field: value")
    local repo=$(echo "$pr_block" | grep "^[[:space:]]*repo:" | head -1 | sed -E 's/^[[:space:]]*repo:[[:space:]]*//' | tr -d '"')
    _store_pr_field "$pr_id" "repo" "$repo"

    local team=$(echo "$pr_block" | grep "^[[:space:]]*team:" | head -1 | sed -E 's/^[[:space:]]*team:[[:space:]]*//' | tr -d '"')
    _store_pr_field "$pr_id" "team" "$team"

    local branch=$(echo "$pr_block" | grep "^[[:space:]]*branch:" | head -1 | sed -E 's/^[[:space:]]*branch:[[:space:]]*//' | tr -d '"')
    _store_pr_field "$pr_id" "branch" "$branch"

    local title=$(echo "$pr_block" | grep "^[[:space:]]*title:" | head -1 | sed -E 's/^[[:space:]]*title:[[:space:]]*//' | tr -d '"')
    _store_pr_field "$pr_id" "title" "$title"

    local complexity=$(echo "$pr_block" | grep "^[[:space:]]*complexity:" | head -1 | sed -E 's/^[[:space:]]*complexity:[[:space:]]*//' | tr -d '"')
    _store_pr_field "$pr_id" "complexity" "$complexity"

    local created=$(echo "$pr_block" | grep "^[[:space:]]*created:" | head -1 | sed -E 's/^[[:space:]]*created:[[:space:]]*//' | tr -d '"')
    _store_pr_field "$pr_id" "created" "$created"

    local review_hours=$(echo "$pr_block" | grep "^[[:space:]]*review_hours:" | head -1 | sed -E 's/^[[:space:]]*review_hours:[[:space:]]*//')
    _store_pr_field "$pr_id" "review_hours" "$review_hours"

    # Extract description (multi-line with |)
    local description=$(echo "$pr_block" | awk '/^[[:space:]]*description:[[:space:]]*\|/,/^[[:space:]]*[a-z_]+:/ {
        if ($0 ~ /^[[:space:]]*description:/) next;
        if ($0 ~ /^[[:space:]]*[a-z_]+:/) exit;
        print
    }' | sed -E 's/^[[:space:]]{6}//')
    _store_pr_field "$pr_id" "description" "$description"

    # Extract dependencies array (format: dependencies: [1, 2, 3] or dependencies: [])
    local deps=$(echo "$pr_block" | grep "^[[:space:]]*dependencies:" | sed -E 's/^[[:space:]]*dependencies:[[:space:]]*//' | tr -d '[]' | tr -d ' ')
    _store_pr_field "$pr_id" "dependencies" "$deps"

    # Extract files array (format: files:\n      - file1\n      - file2)
    # Need to handle proper indentation levels to avoid matching next field
    local files=$(echo "$pr_block" | awk '
BEGIN { in_files = 0 }
/^[[:space:]]*files:/ { in_files = 1; next }
in_files && /^[[:space:]]{0,5}[a-z_]+:/ { exit }
in_files && /^[[:space:]]+-/ {
    sub(/^[[:space:]]*-[[:space:]]*/, "");
    print
}
' | paste -sd ',' -)
    _store_pr_field "$pr_id" "files" "$files"
}

#################################################################
# HIGH-LEVEL API FUNCTIONS
#################################################################

# Load all PR configurations from config directory
# Args: config_dir (optional, defaults to project config dir)
# Returns: Populates global ALL_PRS array with all PR configs
load_all_pr_configs() {
    local config_dir="${1:-/Users/leo.levintza/wrk/first-agentic-ai/config}"

    # Clear existing data
    unset PR_CONFIGS
    unset ALL_PRS
    unset PR_DATA_CACHE
    declare -A PR_CONFIGS
    declare -a ALL_PRS
    declare -A PR_DATA_CACHE

    local files=(
        "$config_dir/pr-definitions-month1-2.yaml"
        "$config_dir/pr-definitions-month3-4.yaml"
        "$config_dir/pr-definitions-month5-6.yaml"
        "$config_dir/monorepo-pr-definitions.yaml"
    )

    local total_loaded=0

    for yaml_file in "${files[@]}"; do
        if [ -f "$yaml_file" ]; then
            echo "Loading: $(basename "$yaml_file")" >&2
            parse_yaml_file "$yaml_file"
            local count=${#ALL_PRS[@]}
            echo "  Loaded $((count - total_loaded)) PRs" >&2
            total_loaded=$count
        else
            echo "WARNING: Config file not found: $yaml_file" >&2
        fi
    done

    # Validate no duplicate PR IDs
    local unique_ids=($(printf '%s\n' "${ALL_PRS[@]}" | sort -u))
    if [ ${#unique_ids[@]} -ne ${#ALL_PRS[@]} ]; then
        echo "ERROR: Duplicate PR IDs detected!" >&2
        return 1
    fi

    echo "Total PRs loaded: ${#ALL_PRS[@]}" >&2
    return 0
}

# Get PR config by ID
# Args: pr_id
# Returns: Prints all PR configuration data
get_pr_config() {
    local pr_id="$1"
    local key="${pr_id}_id"

    if [ -z "${PR_CONFIGS[$key]}" ]; then
        echo "ERROR: PR ID $pr_id not found" >&2
        return 1
    fi

    # Return full PR data from cache if available
    if [ -n "${PR_DATA_CACHE[$pr_id]}" ]; then
        echo "${PR_DATA_CACHE[$pr_id]}"
    else
        # Reconstruct from individual fields
        local repo=$(_get_pr_field_internal "$pr_id" "repo")
        local team=$(_get_pr_field_internal "$pr_id" "team")
        local branch=$(_get_pr_field_internal "$pr_id" "branch")
        local title=$(_get_pr_field_internal "$pr_id" "title")
        local complexity=$(_get_pr_field_internal "$pr_id" "complexity")
        local created=$(_get_pr_field_internal "$pr_id" "created")
        local review_hours=$(_get_pr_field_internal "$pr_id" "review_hours")
        local dependencies=$(_get_pr_field_internal "$pr_id" "dependencies")

        cat <<EOF
  id: $pr_id
  repo: $repo
  team: $team
  branch: $branch
  title: $title
  complexity: $complexity
  created: $created
  review_hours: $review_hours
  dependencies: [$dependencies]
EOF
    fi
}

# Extract specific field from PR config
# Args: pr_id, field_name
# Returns: field value
get_pr_field() {
    local pr_id="$1"
    local field="$2"
    local key="${pr_id}_${field}"

    if [ -z "${PR_CONFIGS[$key]}" ]; then
        echo "ERROR: Field '$field' not found for PR $pr_id" >&2
        return 1
    fi

    echo "${PR_CONFIGS[$key]}"
}

# Get all PR IDs
# Args: none
# Returns: Array of all PR IDs
get_all_pr_ids() {
    printf '%s\n' "${ALL_PRS[@]}"
}

# Get PR count
# Args: none
# Returns: Total number of PRs loaded
get_pr_count() {
    echo "${#ALL_PRS[@]}"
}

# Get PR IDs by repository
# Args: repo_name
# Returns: PR IDs for the specified repository
get_prs_by_repo() {
    local repo="$1"

    for pr_id in "${ALL_PRS[@]}"; do
        local pr_repo=$(_get_pr_field_internal "$pr_id" "repo")
        if [ "$pr_repo" = "$repo" ]; then
            echo "$pr_id"
        fi
    done
}

# Get PR IDs by team
# Args: team_name
# Returns: PR IDs for the specified team
get_prs_by_team() {
    local team="$1"

    for pr_id in "${ALL_PRS[@]}"; do
        local pr_team=$(_get_pr_field_internal "$pr_id" "team")
        if [ "$pr_team" = "$team" ]; then
            echo "$pr_id"
        fi
    done
}

# Get PR IDs by complexity
# Args: complexity_level
# Returns: PR IDs matching the complexity level
get_prs_by_complexity() {
    local complexity="$1"

    for pr_id in "${ALL_PRS[@]}"; do
        local pr_complexity=$(_get_pr_field_internal "$pr_id" "complexity")
        if [ "$pr_complexity" = "$complexity" ]; then
            echo "$pr_id"
        fi
    done
}

# Get PR dependencies as array
# Args: pr_id
# Returns: Space-separated list of dependency PR IDs
get_pr_dependencies() {
    local pr_id="$1"
    local deps=$(_get_pr_field_internal "$pr_id" "dependencies")

    if [ -n "$deps" ]; then
        echo "$deps" | tr ',' ' '
    fi
}

# Get PR files as array
# Args: pr_id
# Returns: Newline-separated list of files
get_pr_files() {
    local pr_id="$1"
    local files=$(_get_pr_field_internal "$pr_id" "files")

    if [ -n "$files" ]; then
        echo "$files" | tr ',' '\n'
    fi
}

#################################################################
# VALIDATION FUNCTIONS
#################################################################

# Validate YAML file structure
# Args: yaml_file
# Returns: 0 if valid, 1 if invalid
validate_yaml_file() {
    local yaml_file="$1"
    local errors=0

    echo "Validating YAML file: $(basename "$yaml_file")" >&2

    # Check if file exists
    if [ ! -f "$yaml_file" ]; then
        echo "ERROR: File not found: $yaml_file" >&2
        return 1
    fi

    # Check required sections
    if ! grep -q "^metadata:" "$yaml_file"; then
        echo "ERROR: Missing 'metadata' section" >&2
        ((errors++))
    fi

    if ! grep -q "^prs:" "$yaml_file"; then
        echo "ERROR: Missing 'prs' section" >&2
        ((errors++))
    fi

    # Parse file to temporary arrays
    parse_yaml_file "$yaml_file"

    # Validate each PR has required fields
    for pr_id in "${ALL_PRS[@]}"; do
        local required_fields=("id" "repo" "team" "branch" "title" "dependencies" "complexity" "created" "review_hours")

        for field in "${required_fields[@]}"; do
            local key="${pr_id}_${field}"
            if [ -z "${PR_CONFIGS[$key]}" ]; then
                echo "ERROR: PR $pr_id missing field: $field" >&2
                ((errors++))
            fi
        done
    done

    if [ $errors -eq 0 ]; then
        echo "VALIDATION PASSED: $(basename "$yaml_file")" >&2
        return 0
    else
        echo "VALIDATION FAILED: $errors errors in $(basename "$yaml_file")" >&2
        return 1
    fi
}

# Validate all config files
validate_all_configs() {
    local config_dir="${1:-/Users/leo.levintza/wrk/first-agentic-ai/config}"
    local total_errors=0

    local files=(
        "$config_dir/pr-definitions-month1-2.yaml"
        "$config_dir/pr-definitions-month3-4.yaml"
        "$config_dir/pr-definitions-month5-6.yaml"
        "$config_dir/monorepo-pr-definitions.yaml"
    )

    for yaml_file in "${files[@]}"; do
        if [ -f "$yaml_file" ]; then
            if ! validate_yaml_file "$yaml_file"; then
                ((total_errors++))
            fi
            echo "" >&2
        fi
    done

    if [ $total_errors -eq 0 ]; then
        echo "All config files validated successfully" >&2
        return 0
    else
        echo "Validation failed for $total_errors files" >&2
        return 1
    fi
}

# Get metadata from YAML file
# Args: yaml_file, field_name
# Returns: field value
get_metadata_field() {
    local yaml_file="$1"
    local field="$2"

    if command -v yq >/dev/null 2>&1; then
        yq eval ".metadata.$field" "$yaml_file"
    else
        # Extract metadata section (from "metadata:" to "prs:")
        awk "/^metadata:/,/^prs:/" "$yaml_file" | grep "^  $field:" | head -1 | sed "s/^  $field: //" | tr -d '"'
    fi
}

#################################################################
# UTILITY FUNCTIONS
#################################################################

# Print PR summary
# Args: pr_id
print_pr_summary() {
    local pr_id="$1"
    local key="${pr_id}_id"

    if [ -z "${PR_CONFIGS[$key]}" ]; then
        echo "PR $pr_id not found"
        return 1
    fi

    local title=$(_get_pr_field_internal "$pr_id" "title")
    local repo=$(_get_pr_field_internal "$pr_id" "repo")
    local team=$(_get_pr_field_internal "$pr_id" "team")
    local branch=$(_get_pr_field_internal "$pr_id" "branch")
    local complexity=$(_get_pr_field_internal "$pr_id" "complexity")
    local review_hours=$(_get_pr_field_internal "$pr_id" "review_hours")
    local dependencies=$(_get_pr_field_internal "$pr_id" "dependencies")
    local created=$(_get_pr_field_internal "$pr_id" "created")

    cat <<EOF
PR #$pr_id: $title
  Repository: $repo
  Team: $team
  Branch: $branch
  Complexity: $complexity
  Review Hours: $review_hours
  Dependencies: [${dependencies:-none}]
  Created: $created
EOF
}

# Export all functions
export -f parse_yaml_file
export -f load_all_pr_configs
export -f get_pr_config
export -f get_pr_field
export -f get_all_pr_ids
export -f get_pr_count
export -f get_prs_by_repo
export -f get_prs_by_team
export -f get_prs_by_complexity
export -f get_pr_dependencies
export -f get_pr_files
export -f validate_yaml_file
export -f validate_all_configs
export -f get_metadata_field
export -f print_pr_summary

# Internal helper functions (also export for nested calls)
export -f _store_pr_field
export -f _get_pr_field_internal
export -f _parse_with_yq
export -f _parse_with_python
export -f _parse_with_bash
export -f _parse_pr_block
