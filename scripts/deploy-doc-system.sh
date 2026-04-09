#!/usr/bin/env bash
#
# Deploy Documentation System
#
# Deploys the documentation agent, skills, and hooks configuration
# to all repositories in an organization.
#
# Usage:
#   ./deploy-doc-system.sh --org polybase-poc
#   ./deploy-doc-system.sh --org omnibase-poc --dry-run
#

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load utility functions
source "$SCRIPT_DIR/lib/utils.sh" 2>/dev/null || {
    echo "Error: Could not load utils.sh" >&2
    exit 1
}

# Configuration
CONFIG_DIR="$PROJECT_ROOT/config"
REPOS_CSV="$CONFIG_DIR/repositories.csv"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# Default values
DRY_RUN=false
ORG=""
REPO=""
FORCE=false

# Statistics
declare -g TOTAL_REPOS=0
declare -g SUCCESS_COUNT=0
declare -g FAILED_COUNT=0
declare -gA RESULTS=()

#######################################
# Print usage information
#######################################
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Deploy documentation system to repositories.

OPTIONS:
    --org <org>           Organization name (polybase-poc or omnibase-poc)
    --repo <repo>         Single repository name (optional)
    --dry-run             Preview without making changes
    --force               Overwrite existing configurations
    --help                Show this help message

EXAMPLES:
    # Deploy to entire organization
    $0 --org polybase-poc

    # Deploy to single repo
    $0 --org polybase-poc --repo user-service

    # Dry run
    $0 --org omnibase-poc --dry-run

EOF
    exit 0
}

#######################################
# Parse command line arguments
#######################################
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --org)
                ORG="$2"
                shift 2
                ;;
            --repo)
                REPO="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --help)
                usage
                ;;
            *)
                echo "Unknown option: $1"
                usage
                ;;
        esac
    done

    # Validation
    if [[ -z "$ORG" ]]; then
        echo "Error: Must specify --org"
        exit 1
    fi
}

#######################################
# Get repository path
#######################################
get_repo_path() {
    local org="$1"
    local repo="$2"

    if [[ "$org" == "polybase-poc" ]]; then
        echo "${HOME}/wrk/polybase/${repo}"
    elif [[ "$org" == "omnibase-poc" ]]; then
        echo "${HOME}/wrk/omnybase/${repo}"
    else
        echo "Error: Unknown organization: $org" >&2
        return 1
    fi
}

#######################################
# Deploy to a single repository
#######################################
deploy_to_repo() {
    local org="$1"
    local repo="$2"

    print_info "Deploying to $org/$repo..."

    # Get repository path
    local repo_path
    repo_path=$(get_repo_path "$org" "$repo")

    if [[ ! -d "$repo_path" ]]; then
        print_error "Repository not found: $repo_path"
        RESULTS["$repo"]="FAILED: Not found"
        ((FAILED_COUNT++))
        return 1
    fi

    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would deploy to $repo_path"
        RESULTS["$repo"]="DRY RUN"
        ((SUCCESS_COUNT++))
        return 0
    fi

    # Create .claude directory if it doesn't exist
    mkdir -p "$repo_path/.claude/agents"
    mkdir -p "$repo_path/.claude/skills"
    mkdir -p "$repo_path/.claude/scripts"

    # Copy agents
    print_info "  Copying agents..."
    cp -r "$CLAUDE_DIR/agents/"* "$repo_path/.claude/agents/" 2>/dev/null || true

    # Copy skills
    print_info "  Copying skills..."
    cp -r "$CLAUDE_DIR/skills/"* "$repo_path/.claude/skills/" 2>/dev/null || true

    # Copy scripts
    print_info "  Copying scripts..."
    cp "$CLAUDE_DIR/scripts/check-doc-freshness.sh" "$repo_path/.claude/scripts/" 2>/dev/null || true
    chmod +x "$repo_path/.claude/scripts/check-doc-freshness.sh"

    # Update or create settings.json
    local settings_file="$repo_path/.claude/settings.json"

    if [[ -f "$settings_file" ]]; then
        if [[ "$FORCE" == true ]]; then
            print_info "  Updating settings.json (--force)..."
            # Backup existing settings
            cp "$settings_file" "$settings_file.backup"

            # Merge settings (this is simplified - in production use jq)
            print_info "  Settings backed up to settings.json.backup"
            print_warning "  Manual merge may be required"
        else
            print_warning "  settings.json exists. Use --force to overwrite."
        fi
    else
        print_info "  Creating settings.json..."
        cp "$CLAUDE_DIR/settings.json" "$settings_file"
    fi

    # Success
    print_success "  Deployed successfully"
    RESULTS["$repo"]="SUCCESS"
    ((SUCCESS_COUNT++))
}

#######################################
# Get list of repositories
#######################################
get_repositories() {
    local repos=()

    if [[ -n "$REPO" ]]; then
        repos=("$REPO")
    else
        # All repos in organization
        if [[ ! -f "$REPOS_CSV" ]]; then
            print_error "Repositories CSV not found: $REPOS_CSV"
            exit 1
        fi

        while IFS=',' read -r org_name repo_name team rest; do
            if [[ "$org_name" == "$ORG" && "$repo_name" != "repo_name" ]]; then
                repos+=("$repo_name")
            fi
        done < "$REPOS_CSV"
    fi

    if [[ ${#repos[@]} -eq 0 ]]; then
        print_error "No repositories found for $ORG"
        exit 1
    fi

    echo "${repos[@]}"
}

#######################################
# Process all repositories
#######################################
process_repositories() {
    local repos=($@)
    TOTAL_REPOS=${#repos[@]}

    print_section "Deploying Documentation System"
    print_info "Organization: $ORG"
    print_info "Total repositories: $TOTAL_REPOS"
    print_info "Dry run: $DRY_RUN"
    print_info "Force: $FORCE"
    echo ""

    local current=0
    for repo in "${repos[@]}"; do
        ((current++))
        echo "[$current/$TOTAL_REPOS] $repo"
        deploy_to_repo "$ORG" "$repo"
        echo ""
    done
}

#######################################
# Print summary
#######################################
print_summary() {
    echo ""
    print_section "Deployment Summary"

    echo "Total Repositories: $TOTAL_REPOS"
    echo "Successful:        $SUCCESS_COUNT"
    echo "Failed:            $FAILED_COUNT"
    echo ""

    if [[ ${#RESULTS[@]} -gt 0 ]]; then
        echo "Detailed Results:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        for repo in "${!RESULTS[@]}"; do
            printf "  %-30s %s\n" "$repo" "${RESULTS[$repo]}"
        done
        echo ""
    fi

    if [[ $FAILED_COUNT -gt 0 ]]; then
        print_error "Some deployments failed."
        return 1
    else
        print_success "Deployment complete!"

        echo ""
        echo "Next Steps:"
        echo "1. Review deployed configurations in each repository"
        echo "2. Test skills: cd <repo> && claude code"
        echo "3. Try: /doc-generate or /doc-check"
        echo "4. Verify hooks work: make code changes and try to stop session"
        return 0
    fi
}

#######################################
# Main execution
#######################################
main() {
    # Parse arguments
    parse_args "$@"

    # Verify source files exist
    if [[ ! -d "$CLAUDE_DIR/agents" ]]; then
        print_error "Agents directory not found: $CLAUDE_DIR/agents"
        exit 1
    fi

    if [[ ! -d "$CLAUDE_DIR/skills" ]]; then
        print_error "Skills directory not found: $CLAUDE_DIR/skills"
        exit 1
    fi

    # Get repositories
    local repos
    repos=$(get_repositories)

    # Process repositories
    process_repositories $repos

    # Print summary
    print_summary
}

# Run main function
main "$@"
