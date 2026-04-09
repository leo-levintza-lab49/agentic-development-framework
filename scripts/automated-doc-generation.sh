#!/usr/bin/env bash
#
# Automated Documentation Generation Script
#
# Orchestrates batch documentation generation across repositories
# by invoking the doc-architect agent for each target repository.
#
# Usage:
#   ./automated-doc-generation.sh --org polybase-poc
#   ./automated-doc-generation.sh --org omnibase-poc --repo enterprise-monorepo
#   ./automated-doc-generation.sh --repos "user-service,auth-service" --dry-run
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
WORKSPACE_CONF="$CONFIG_DIR/workspace.conf"
REPOS_CSV="$CONFIG_DIR/repositories.csv"
TEAMS_CSV="$CONFIG_DIR/teams.csv"
DOC_DEFINITIONS="$CONFIG_DIR/doc-definitions.yaml"

# Default values
DRY_RUN=false
SKIP_PR=false
FORCE=false
VERBOSE=false
ORG=""
REPO=""
REPOS_LIST=""
LOG_FILE="$PROJECT_ROOT/logs/doc-generation-$(date +%Y%m%d-%H%M%S).log"

# Statistics
declare -g TOTAL_REPOS=0
declare -g SUCCESS_COUNT=0
declare -g FAILED_COUNT=0
declare -g SKIPPED_COUNT=0
declare -gA RESULTS=()

#######################################
# Print usage information
#######################################
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Automated documentation generation for repositories.

OPTIONS:
    --org <org>           Organization name (polybase-poc or omnibase-poc)
    --repo <repo>         Single repository name
    --repos <list>        Comma-separated list of repositories
    --dry-run             Preview without creating PRs
    --skip-pr             Generate docs but don't create PR
    --force               Regenerate even if docs exist
    --verbose             Show detailed output
    --help                Show this help message

EXAMPLES:
    # Generate docs for entire organization
    $0 --org polybase-poc

    # Generate docs for single repo
    $0 --org polybase-poc --repo user-service

    # Generate docs for specific repos
    $0 --repos "user-service,auth-service" --dry-run

    # Force regeneration
    $0 --org omnibase-poc --force

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
            --repos)
                REPOS_LIST="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-pr)
                SKIP_PR=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --verbose)
                VERBOSE=true
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
    if [[ -z "$ORG" && -z "$REPOS_LIST" ]]; then
        echo "Error: Must specify --org or --repos"
        exit 1
    fi
}

#######################################
# Load workspace configuration
#######################################
load_config() {
    if [[ -f "$WORKSPACE_CONF" ]]; then
        source "$WORKSPACE_CONF"
        print_info "Loaded workspace configuration"
    else
        print_error "Workspace configuration not found: $WORKSPACE_CONF"
        exit 1
    fi
}

#######################################
# Get list of repositories to process
#######################################
get_repositories() {
    local repos=()

    if [[ -n "$REPO" ]]; then
        # Single repo specified
        repos=("$REPO")
    elif [[ -n "$REPOS_LIST" ]]; then
        # List of repos specified
        IFS=',' read -ra repos <<< "$REPOS_LIST"
    elif [[ -n "$ORG" ]]; then
        # All repos in organization
        if [[ ! -f "$REPOS_CSV" ]]; then
            print_error "Repositories CSV not found: $REPOS_CSV"
            exit 1
        fi

        # Parse CSV and filter by org
        while IFS=',' read -r org_name repo_name team rest; do
            if [[ "$org_name" == "$ORG" && "$repo_name" != "repo_name" ]]; then
                repos+=("$repo_name")
            fi
        done < "$REPOS_CSV"
    fi

    if [[ ${#repos[@]} -eq 0 ]]; then
        print_error "No repositories found for processing"
        exit 1
    fi

    echo "${repos[@]}"
}

#######################################
# Get repository path
#######################################
get_repo_path() {
    local org="$1"
    local repo="$2"

    # Determine base directory
    if [[ "$org" == "polybase-poc" ]]; then
        echo "${HOME}/wrk/polybase/${repo}"
    elif [[ "$org" == "omnibase-poc" ]]; then
        echo "${HOME}/wrk/omnybase/${repo}"
    else
        print_error "Unknown organization: $org"
        return 1
    fi
}

#######################################
# Check if repository needs documentation
#######################################
needs_documentation() {
    local repo_path="$1"

    if [[ "$FORCE" == true ]]; then
        return 0
    fi

    # Check if docs directory exists and has content
    if [[ -d "$repo_path/docs" ]]; then
        local doc_count=$(find "$repo_path/docs" -name "*.md" | wc -l)
        if [[ $doc_count -gt 3 ]]; then
            print_info "Documentation appears complete (found $doc_count files)"
            return 1
        fi
    fi

    return 0
}

#######################################
# Generate documentation for a repository
#######################################
generate_docs_for_repo() {
    local org="$1"
    local repo="$2"
    local team="${3:-unknown}"

    print_section "Processing: $org/$repo"

    # Get repository path
    local repo_path
    repo_path=$(get_repo_path "$org" "$repo")

    if [[ ! -d "$repo_path" ]]; then
        print_error "Repository not found: $repo_path"
        RESULTS["$repo"]="FAILED: Not found"
        ((FAILED_COUNT++))
        return 1
    fi

    # Check if documentation is needed
    if ! needs_documentation "$repo_path"; then
        print_info "Skipping (documentation exists, use --force to regenerate)"
        RESULTS["$repo"]="SKIPPED: Docs exist"
        ((SKIPPED_COUNT++))
        return 0
    fi

    # Dry run check
    if [[ "$DRY_RUN" == true ]]; then
        print_info "[DRY RUN] Would generate documentation for $org/$repo"
        RESULTS["$repo"]="DRY RUN"
        ((SUCCESS_COUNT++))
        return 0
    fi

    # Generate documentation by invoking doc-architect agent
    print_info "Invoking doc-architect agent..."

    # Build agent prompt
    local agent_prompt="Generate comprehensive documentation for the repository.

Repository: $org/$repo
Team: $team
Path: $repo_path
Skip PR: $SKIP_PR

Workflow:
1. Analyze code structure and patterns
2. Generate documentation files
3. Create Mermaid diagrams where appropriate
4. $(if [[ "$SKIP_PR" == false ]]; then echo "Create PR with labels and assignments"; else echo "Save files locally without PR"; fi)

Configuration:
- Config directory: $CONFIG_DIR
- Base directory: $(dirname "$repo_path")
- Organization: $org

Execute full documentation generation workflow."

    # Log the command
    log_to_file "$LOG_FILE" "=== Generating docs for $org/$repo ==="
    log_to_file "$LOG_FILE" "Command: claude --agent doc-architect"
    log_to_file "$LOG_FILE" "Prompt: $agent_prompt"

    # Invoke Claude Code with doc-architect agent
    # Note: This would normally invoke the Claude Code CLI
    # For now, we'll simulate the call and log it

    if command -v claude &> /dev/null; then
        cd "$repo_path"

        # Create a temporary file with the prompt
        local prompt_file="/tmp/doc-architect-prompt-$$rand.txt"
        echo "$agent_prompt" > "$prompt_file"

        # Invoke agent (this is a placeholder - actual invocation may differ)
        if claude --agent doc-architect < "$prompt_file" >> "$LOG_FILE" 2>&1; then
            print_success "Documentation generated successfully"
            RESULTS["$repo"]="SUCCESS"
            ((SUCCESS_COUNT++))
        else
            print_error "Failed to generate documentation"
            RESULTS["$repo"]="FAILED: Agent error"
            ((FAILED_COUNT++))
        fi

        rm -f "$prompt_file"
    else
        print_warning "Claude Code CLI not available - logging operation only"
        log_to_file "$LOG_FILE" "Would invoke: claude --agent doc-architect"
        RESULTS["$repo"]="SKIPPED: CLI not available"
        ((SKIPPED_COUNT++))
    fi

    echo ""
}

#######################################
# Process all repositories
#######################################
process_repositories() {
    local repos=($@)
    TOTAL_REPOS=${#repos[@]}

    print_section "Documentation Generation"
    print_info "Total repositories: $TOTAL_REPOS"
    print_info "Organization: ${ORG:-multiple}"
    print_info "Dry run: $DRY_RUN"
    print_info "Skip PR: $SKIP_PR"
    print_info "Force: $FORCE"
    echo ""

    local current=0
    for repo in "${repos[@]}"; do
        ((current++))
        print_info "[$current/$TOTAL_REPOS] Processing $repo..."

        # Get org and team for this repo
        local repo_org="$ORG"
        local repo_team="unknown"

        if [[ -f "$REPOS_CSV" ]]; then
            while IFS=',' read -r org_name repo_name team rest; do
                if [[ "$repo_name" == "$repo" ]]; then
                    repo_org="$org_name"
                    repo_team="$team"
                    break
                fi
            done < "$REPOS_CSV"
        fi

        # Generate documentation
        generate_docs_for_repo "$repo_org" "$repo" "$repo_team"

        # Small delay between repos to avoid rate limits
        sleep 2
    done
}

#######################################
# Print summary report
#######################################
print_summary() {
    echo ""
    print_section "Documentation Generation Summary"

    echo "Total Repositories: $TOTAL_REPOS"
    echo "Successful:        $SUCCESS_COUNT"
    echo "Failed:            $FAILED_COUNT"
    echo "Skipped:           $SKIPPED_COUNT"
    echo ""

    if [[ ${#RESULTS[@]} -gt 0 ]]; then
        echo "Detailed Results:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        for repo in "${!RESULTS[@]}"; do
            printf "  %-30s %s\n" "$repo" "${RESULTS[$repo]}"
        done
        echo ""
    fi

    echo "Log file: $LOG_FILE"

    if [[ $FAILED_COUNT -gt 0 ]]; then
        print_error "Some repositories failed. Check log for details."
        return 1
    elif [[ $SUCCESS_COUNT -eq 0 && $SKIPPED_COUNT -eq $TOTAL_REPOS ]]; then
        print_warning "All repositories skipped. Use --force to regenerate."
        return 0
    else
        print_success "Documentation generation complete!"
        return 0
    fi
}

#######################################
# Main execution
#######################################
main() {
    # Parse arguments
    parse_args "$@"

    # Load configuration
    load_config

    # Ensure log directory exists
    mkdir -p "$(dirname "$LOG_FILE")"

    # Get repositories to process
    local repos
    repos=$(get_repositories)

    # Process repositories
    process_repositories $repos

    # Print summary
    print_summary
}

# Run main function
main "$@"
