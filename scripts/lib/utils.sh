#!/bin/bash
#
# Utility Functions for GitHub Infrastructure Setup
#

# Mark as loaded
export UTILS_LOADED=true

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Output functions
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_header() { echo -e "\n${BLUE}==== $1 ====${NC}\n"; }

# Progress bar
print_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    printf "\rProgress: ["
    printf "%${completed}s" | tr ' ' '='
    printf "%${remaining}s" | tr ' ' ' '
    printf "] %3d%% (%d/%d)" "$percentage" "$current" "$total"

    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# Get local directory for organization
get_local_dir() {
    local org=$1

    if [ "$org" = "$MONOREPO_ORG" ]; then
        echo "${OMNIBASE_LOCAL_DIR:-$HOME/wrk/omnybase}"
    elif [ "$org" = "$MULTIREPO_ORG" ]; then
        echo "${POLYBASE_LOCAL_DIR:-$HOME/wrk/polybase}"
    else
        echo "$HOME/wrk/$org"
    fi
}

# Clone repository to local directory
clone_repository() {
    local org=$1
    local repo=$2
    local local_dir=$(get_local_dir "$org")
    local repo_path="$local_dir/$repo"

    # Skip if not cloning locally
    if [ "${CLONE_REPOS_LOCALLY:-false}" != "true" ]; then
        return 0
    fi

    # Skip if already exists
    if [ -d "$repo_path" ]; then
        print_info "Repository already exists locally: $repo_path"
        return 0
    fi

    # Create parent directory
    mkdir -p "$local_dir"

    # Clone repository
    print_info "Cloning $org/$repo to $repo_path..."
    if gh repo clone "$org/$repo" "$repo_path" 2>&1; then
        print_success "Cloned to $repo_path"
        return 0
    else
        print_error "Failed to clone $org/$repo"
        return 1
    fi
}

# Check if repository exists locally
repo_exists_locally() {
    local org=$1
    local repo=$2
    local local_dir=$(get_local_dir "$org")
    local repo_path="$local_dir/$repo"

    [ -d "$repo_path/.git" ]
}

# Get repository path
get_repo_path() {
    local org=$1
    local repo=$2
    local local_dir=$(get_local_dir "$org")

    echo "$local_dir/$repo"
}

# Validate GitHub CLI authentication
validate_gh_auth() {
    if ! gh auth status >/dev/null 2>&1; then
        print_error "GitHub CLI not authenticated"
        print_info "Run: gh auth login"
        return 1
    fi
    return 0
}

# Check rate limit
check_rate_limit() {
    local remaining=$(gh api /rate_limit --jq '.resources.core.remaining')
    local reset=$(gh api /rate_limit --jq '.resources.core.reset')

    if [ "$remaining" -lt 100 ]; then
        local now=$(date +%s)
        local wait_time=$((reset - now + 60))

        print_warning "Rate limit low ($remaining remaining). Waiting $wait_time seconds..."
        sleep "$wait_time"
    fi
}

# Parse CSV file (skip comments and empty lines)
parse_csv() {
    local csv_file=$1
    grep -v '^#' "$csv_file" | grep -v '^[[:space:]]*$'
}

# Replace template variables
replace_template_vars() {
    local template=$1
    local output=$2
    shift 2

    # Copy template to output
    cp "$template" "$output"

    # Replace variables (passed as VAR=value pairs)
    while [ $# -gt 0 ]; do
        local var="${1%%=*}"
        local value="${1#*=}"

        # Use @ as delimiter to avoid conflicts with / in paths
        sed -i '' "s@{{${var}}}@${value}@g" "$output"

        shift
    done
}

# Generate timestamp
timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Log to file
log_to_file() {
    local log_file=$1
    local message=$2

    echo "[$(timestamp)] $message" >> "$log_file"
}

# Create directory structure
create_dir_structure() {
    local base_dir=$1
    shift
    local dirs=("$@")

    for dir in "${dirs[@]}"; do
        mkdir -p "$base_dir/$dir"
    done
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate required tools
validate_tools() {
    local required_tools=("gh" "git" "jq")
    local missing_tools=()

    for tool in "${required_tools[@]}"; do
        if ! command_exists "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        return 1
    fi

    print_success "All required tools are installed"
    return 0
}

# Sanitize repository name (remove special characters)
sanitize_repo_name() {
    local name=$1
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//'
}

# Generate unique ID
generate_id() {
    date +%s%N | md5sum | head -c 8
}

# Confirm action
confirm_action() {
    local prompt=$1
    local default=${2:-n}

    if [ "$default" = "y" ]; then
        read -p "$prompt [Y/n]: " response
        response=${response:-y}
    else
        read -p "$prompt [y/N]: " response
        response=${response:-n}
    fi

    case "$response" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Export functions for use in subshells
export -f print_info
export -f print_success
export -f print_warning
export -f print_error
export -f print_header
export -f print_progress
export -f get_local_dir
export -f clone_repository
export -f repo_exists_locally
export -f get_repo_path
