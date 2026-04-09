#!/bin/bash
#
# GitHub Infrastructure Setup Script
# Enterprise Claude Code Case Study
#
# This script creates GitHub organizations, repositories, teams,
# and configurations for both monorepo and multi-repo scenarios.
#
# Usage:
#   ./setup-github-infrastructure.sh [options]
#
# Options:
#   --dry-run                 Preview operations without making changes
#   --scenario <name>         Scenario: monorepo, multirepo, or both (default: both)
#   --single-repo <name>      Create only a single repository (for testing)
#   --no-validation           Skip validation after creation
#   --validation-level <lvl>  Validation level: basic, detailed, comprehensive
#   -h, --help               Show this help message
#

set -e
set -o pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load environment
if [ -f "$PROJECT_ROOT/.envrc" ]; then
    set -a
    source "$PROJECT_ROOT/.envrc"
    set +a
else
    echo "Error: No .envrc file found"
    exit 1
fi

# Source library functions
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/repo-creation.sh"
source "$SCRIPT_DIR/lib/scaffolding.sh"
source "$SCRIPT_DIR/lib/validation.sh"
source "$SCRIPT_DIR/lib/teams.sh"

# Verify required environment variables
: "${GITHUB_TOKEN:?GITHUB_TOKEN not set}"
: "${MONOREPO_ORG:?MONOREPO_ORG not set}"
: "${MULTIREPO_ORG:?MULTIREPO_ORG not set}"

# Default values
SCENARIO="${SCENARIO:-both}"
DRY_RUN=${DRY_RUN:-false}
SINGLE_REPO=""
ENABLE_VALIDATION=${ENABLE_VALIDATION:-true}
VALIDATION_LEVEL=${VALIDATION_LEVEL:-detailed}
CLONE_REPOS_LOCALLY=${CLONE_REPOS_LOCALLY:-true}

# Parse command line arguments (before sourcing libraries to allow --help)
SHOW_HELP=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --scenario)
            SCENARIO="$2"
            shift 2
            ;;
        --single-repo)
            SINGLE_REPO="$2"
            shift 2
            ;;
        --no-validation)
            ENABLE_VALIDATION=false
            shift
            ;;
        --validation-level)
            VALIDATION_LEVEL="$2"
            shift 2
            ;;
        -h|--help)
            SHOW_HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$SHOW_HELP" = "true" ]; then
    cat <<EOF
GitHub Infrastructure Setup Script

Usage: ./scripts/setup-github-infrastructure.sh [options]

Options:
    --dry-run                 Preview operations without making changes
    --scenario <name>         Scenario: monorepo, multirepo, or both (default: both)
    --single-repo <name>      Create only a single repository (for testing)
    --no-validation           Skip validation after creation
    --validation-level <lvl>  Validation level: basic, detailed, comprehensive
    -h, --help               Show this help message

Examples:
    ./scripts/setup-github-infrastructure.sh --dry-run
    ./scripts/setup-github-infrastructure.sh --scenario monorepo
    ./scripts/setup-github-infrastructure.sh --single-repo user-service
    ./scripts/setup-github-infrastructure.sh --scenario both --validation-level comprehensive
EOF
    exit 0
fi

# Logs and state
LOG_DIR="$PROJECT_ROOT/logs/github-setup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$LOG_DIR"
STATE_FILE="$LOG_DIR/state.txt"
ERROR_LOG_FILE="$LOG_DIR/errors.log"
SUMMARY_FILE="$LOG_DIR/SUMMARY.md"

# Track created resources
declare -a CREATED_REPOS=()
declare -a CREATED_TEAMS=()

# Banner
print_header() {
    echo ""
    echo "======================================"
    echo "  GitHub Infrastructure Setup"
    echo "======================================"
    echo ""
}

# Display configuration
show_configuration() {
    print_info "Configuration:"
    echo "  Scenario: $SCENARIO"
    echo "  Monorepo org: $MONOREPO_ORG"
    echo "  Multi-repo org: $MULTIREPO_ORG"
    echo "  Dry run: $DRY_RUN"
    echo "  Clone locally: $CLONE_REPOS_LOCALLY"
    if [ -n "$SINGLE_REPO" ]; then
        echo "  Single repo mode: $SINGLE_REPO"
    fi
    echo "  Validation: $ENABLE_VALIDATION ($VALIDATION_LEVEL)"
    echo "  Log directory: $LOG_DIR"
    echo ""
}

# Create a single repository
create_single_repository() {
    local org=$1
    local repo=$2
    local type=$3
    local description=$4
    local team=$5

    print_info "Creating repository $org/$repo..."

    # Check rate limit
    check_rate_limit

    # Create on GitHub
    if [ "$DRY_RUN" = "false" ]; then
        if create_github_repo "$org" "$repo" "$description" "private"; then
            CREATED_REPOS+=("$org/$repo")
            log_to_file "$STATE_FILE" "CREATED|$org/$repo"
        else
            return 1
        fi
    else
        print_info "[DRY RUN] Would create: $org/$repo"
        return 0
    fi

    # Generate scaffolding locally
    if [ "$CLONE_REPOS_LOCALLY" = "true" ] && [ "$DRY_RUN" = "false" ]; then
        if generate_scaffolding "$org" "$repo" "$type" "$description" "$team"; then
            local repo_path=$(get_repo_path "$org" "$repo")

            # Initialize and push
            if initialize_repo "$org" "$repo" "$repo_path"; then
                print_success "Repository $org/$repo created and initialized"
            else
                print_error "Failed to initialize repository"
                return 1
            fi
        else
            print_error "Failed to generate scaffolding"
            return 1
        fi
    fi

    # Validate
    if [ "$ENABLE_VALIDATION" = "true" ] && [ "$DRY_RUN" = "false" ]; then
        sleep 2  # Give GitHub a moment to index
        validate_repository "$org" "$repo" "$VALIDATION_LEVEL"
    fi

    return 0
}

# Create all repositories from CSV
create_all_repositories() {
    local repos_file="$PROJECT_ROOT/config/repositories.csv"

    if [ ! -f "$repos_file" ]; then
        print_error "Repository configuration file not found: $repos_file"
        return 1
    fi

    print_info "Reading repository specifications from $repos_file..."

    local total=0
    local created=0
    local skipped=0
    local failed=0

    # Count total repos (skip comments and empty lines)
    total=$(parse_csv "$repos_file" | wc -l | tr -d ' ')

    print_info "Creating $total repositories..."
    echo ""

    local current=0

    while IFS=',' read -r org name type description visibility team; do
        ((current++))

        # Skip if not in selected scenario
        if [ "$SCENARIO" = "monorepo" ] && [ "$org" != "$MONOREPO_ORG" ]; then
            ((skipped++))
            continue
        fi
        if [ "$SCENARIO" = "multirepo" ] && [ "$org" != "$MULTIREPO_ORG" ]; then
            ((skipped++))
            continue
        fi

        # Skip if single-repo mode and not matching
        if [ -n "$SINGLE_REPO" ] && [ "$name" != "$SINGLE_REPO" ]; then
            ((skipped++))
            continue
        fi

        print_progress $current $total

        if create_single_repository "$org" "$name" "$type" "$description" "$team"; then
            ((created++))
        else
            ((failed++))
        fi

        echo ""
    done < <(parse_csv "$repos_file")

    echo ""
    print_info "Repository Creation Summary:"
    echo "  Total: $total"
    echo "  Created: $created"
    echo "  Skipped: $skipped"
    echo "  Failed: $failed"
    echo ""

    return $failed
}

# Create teams
create_teams() {
    local teams_file="$PROJECT_ROOT/config/teams.csv"

    if [ ! -f "$teams_file" ]; then
        print_warning "Teams configuration file not found: $teams_file"
        return 0
    fi

    print_info "Creating teams..."

    while IFS=',' read -r org team_name team_slug description permission; do
        if [ "$DRY_RUN" = "false" ]; then
            if create_team "$org" "$team_name" "$team_slug" "$description" "closed"; then
                CREATED_TEAMS+=("$org|$team_slug")
                log_to_file "$STATE_FILE" "TEAM_CREATED|$org|$team_slug"
            fi
        else
            print_info "[DRY RUN] Would create team: $team_name in $org"
        fi
    done < <(parse_csv "$teams_file")

    echo ""
}

# Generate summary report
generate_summary() {
    print_info "Generating summary report..."

    cat > "$SUMMARY_FILE" << EOF
# GitHub Infrastructure Setup Summary

**Generated**: $(date)

**Configuration**:
- Scenario: $SCENARIO
- Dry Run: $DRY_RUN
- Organizations:
  - Monorepo: $MONOREPO_ORG
  - Multi-repo: $MULTIREPO_ORG

## Created Repositories

EOF

    if [ ${#CREATED_REPOS[@]} -eq 0 ]; then
        echo "No repositories were created." >> "$SUMMARY_FILE"
    else
        for repo in "${CREATED_REPOS[@]}"; do
            local url="https://github.com/$repo"
            echo "- [$repo]($url)" >> "$SUMMARY_FILE"
        done
    fi

    cat >> "$SUMMARY_FILE" << EOF

## Created Teams

EOF

    if [ ${#CREATED_TEAMS[@]} -eq 0 ]; then
        echo "No teams were created." >> "$SUMMARY_FILE"
    else
        for team_spec in "${CREATED_TEAMS[@]}"; do
            local org="${team_spec%%|*}"
            local team="${team_spec##*|}"
            echo "- $org / $team" >> "$SUMMARY_FILE"
        done
    fi

    cat >> "$SUMMARY_FILE" << EOF

## Next Steps

1. **Review Created Repositories**
   - Verify all repositories are accessible
   - Check default branches are set correctly
   - Ensure workflows are present

2. **Clone Repositories Locally**
   - Monorepo: \`~/wrk/omnybase/enterprise-monorepo\`
   - Multi-repo: \`~/wrk/polybase/*\`

3. **Configure Teams**
   - Add team members
   - Assign repository access
   - Set up CODEOWNERS

4. **Test Claude Code Integration**
   - Navigate to a repository
   - Run \`claude code\`
   - Verify .claude/settings.json is loaded

5. **Set Up CI/CD**
   - Review GitHub Actions workflows
   - Add any required secrets
   - Test workflow execution

## Logs

- State file: $STATE_FILE
- Error log: $ERROR_LOG_FILE
- Summary: $SUMMARY_FILE

---

**Setup completed**: $(date)
EOF

    print_success "Summary written to: $SUMMARY_FILE"
}

# Main execution
main() {
    print_header
    show_configuration

    # Validate tools
    if ! validate_tools; then
        exit 1
    fi

    # Validate GitHub authentication
    if ! validate_gh_auth; then
        exit 1
    fi

    print_success "GitHub CLI authenticated"
    echo ""

    # Create teams first
    if [ "$DRY_RUN" = "false" ]; then
        create_teams
    fi

    # Create repositories
    if create_all_repositories; then
        print_success "All repositories created successfully!"
    else
        print_warning "Some repositories failed to create. Check logs for details."
    fi

    # Generate summary
    generate_summary

    echo ""
    print_success "Setup complete!"
    echo ""
    echo "Summary: $SUMMARY_FILE"
    echo ""
}

# Run main
main
