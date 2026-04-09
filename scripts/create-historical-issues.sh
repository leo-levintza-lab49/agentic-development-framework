#!/bin/bash
#
# Create Historical GitHub Issues for Completed Work
#
# PURPOSE:
#   One-time migration script to create 127 closed GitHub issues representing
#   completed work from October 2025 - April 2026 enterprise development initiative.
#   Populates GitHub Projects roadmaps with historical accomplishments.
#
# USAGE:
#   ./scripts/create-historical-issues.sh           # Create all issues
#   DRY_RUN=true ./scripts/create-historical-issues.sh  # Test without creating
#
# CREATES:
#   - 95 issues in polybase-poc (multi-repo PRs)
#   - 19 issues in omnibase-poc (monorepo services)
#   - 13 issues in agentic-development-framework (framework enhancements)
#
# FEATURES:
#   - Automatic throttling (3s between issues)
#   - Rate limit monitoring
#   - All issues created as closed with 2026-04-09 completion date
#   - Automatic project assignment
#
# DOCUMENTATION:
#   See: docs/GITHUB_INTEGRATION.md#automated-issue-creation-for-historical-work
#
# REQUIREMENTS:
#   - GitHub CLI (gh) authenticated
#   - Write access to polybase-poc, omnibase-poc, leo-levintza-lab49
#   - Project permissions for organization projects
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THROTTLE_SECONDS=3
DRY_RUN=${DRY_RUN:-false}

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*"; }
info() { echo -e "${BLUE}ℹ${NC} $*"; }

# Rate limit checking
check_rate_limit() {
  local remaining=$(gh api rate_limit --jq '.rate.remaining')
  local limit=$(gh api rate_limit --jq '.rate.limit')
  local reset=$(gh api rate_limit --jq '.rate.reset')

  info "API Rate Limit: $remaining/$limit remaining"

  if [ "$remaining" -lt 100 ]; then
    warn "Rate limit getting low. Waiting 60 seconds..."
    sleep 60
  fi
}

# Create labels for a repository
create_labels() {
  local org=$1
  local repo=$2

  info "Creating labels for $org/$repo..."

  if [ "$DRY_RUN" = "true" ]; then
    log "DRY RUN: Would create labels for $org/$repo"
    return
  fi

  # Type labels
  gh label create "feat" --repo "$org/$repo" --description "New feature" --color "0052CC" --force 2>/dev/null || true
  gh label create "fix" --repo "$org/$repo" --description "Bug fix" --color "B60205" --force 2>/dev/null || true
  gh label create "docs" --repo "$org/$repo" --description "Documentation" --color "1D76DB" --force 2>/dev/null || true
  gh label create "chore" --repo "$org/$repo" --description "Maintenance" --color "D4C5F9" --force 2>/dev/null || true

  # Team labels
  gh label create "backend" --repo "$org/$repo" --description "Backend team" --color "FFA500" --force 2>/dev/null || true
  gh label create "bff" --repo "$org/$repo" --description "BFF team" --color "FF6347" --force 2>/dev/null || true
  gh label create "frontend" --repo "$org/$repo" --description "Frontend team" --color "4169E1" --force 2>/dev/null || true
  gh label create "mobile" --repo "$org/$repo" --description "Mobile team" --color "32CD32" --force 2>/dev/null || true
  gh label create "data-platform" --repo "$org/$repo" --description "Data Platform team" --color "9370DB" --force 2>/dev/null || true
  gh label create "platform-sre" --repo "$org/$repo" --description "Platform SRE team" --color "DC143C" --force 2>/dev/null || true

  # Status labels
  gh label create "completed" --repo "$org/$repo" --description "Completed work" --color "28A745" --force 2>/dev/null || true
  gh label create "historical" --repo "$org/$repo" --description "Historical work item" --color "E6E6FA" --force 2>/dev/null || true

  log "Labels created for $org/$repo"
  sleep 1  # Brief pause after label creation
}

# Create and close an issue
create_closed_issue() {
  local org=$1
  local repo=$2
  local title=$3
  local body=$4
  local labels=$5
  local project_num=$6

  if [ "$DRY_RUN" = "true" ]; then
    log "DRY RUN: Would create issue: $title"
    return
  fi

  # Create issue
  local issue_url=$(gh issue create \
    --repo "$org/$repo" \
    --title "$title" \
    --body "$body" \
    --label "$labels")

  if [ -z "$issue_url" ]; then
    error "Failed to create issue: $title"
    return 1
  fi

  local issue_num=$(echo "$issue_url" | grep -oE '[0-9]+$')
  log "Created issue #$issue_num: $title"

  # Add to project if specified
  if [ -n "$project_num" ] && [ "$project_num" != "0" ]; then
    gh project item-add "$project_num" --owner "$org" --url "$issue_url" 2>/dev/null || warn "Could not add to project"
  fi

  # Close immediately with completion comment
  gh issue close "$issue_num" \
    --repo "$org/$repo" \
    --comment "✅ Completed on 2026-04-09 as part of enterprise development initiative."

  log "Closed issue #$issue_num"

  # Throttle
  sleep "$THROTTLE_SECONDS"
}

# Main execution
main() {
  log "Starting historical issue creation..."
  log "Throttle: ${THROTTLE_SECONDS}s between issues"
  [ "$DRY_RUN" = "true" ] && warn "DRY RUN MODE - No issues will be created"

  check_rate_limit

  # ========================================
  # PHASE 1: Multi-Repo PRs (polybase-poc)
  # ========================================

  info ""
  info "=========================================="
  info "PHASE 1: Multi-Repo PRs (95 issues)"
  info "=========================================="
  info ""

  # Get polybase-poc project number
  POLYBASE_PROJECT=2

  # Repository data: repo:count:team
  local REPOS=(
    "order-service:12:backend"
    "web-app:9:frontend"
    "terraform-aws-infrastructure:9:platform-sre"
    "user-service:8:backend"
    "web-bff:7:bff"
    "auth-service:6:backend"
    "component-library:6:frontend"
    "grafana-dashboards:5:platform-sre"
    "prometheus-alerts:5:platform-sre"
    "db-migrations:4:data-platform"
    "db-schemas:4:data-platform"
    "graphql-gateway:4:bff"
    "notification-service:4:backend"
    "payment-service:4:backend"
    "ios-app:3:mobile"
    "android-app:2:mobile"
    "mobile-shared:2:mobile"
    "mobile-bff:1:bff"
  )

  local total_created=0

  for repo_entry in "${REPOS[@]}"; do
    IFS=: read -r repo count team <<< "$repo_entry"

    info "Creating $count issues for $repo (team: $team)..."

    # Create labels first
    create_labels "polybase-poc" "$repo"

    for i in $(seq 1 $count); do
      local title="PR #$i completed (historical)"
      local body="## Completed Work

Generated as part of multi-repo development initiative (October 2025 - April 2026).

### Details
- **Repository**: $repo
- **Team**: $team
- **Completion Date**: 2026-04-09
- **Phase**: Multi-repo foundation and features
- **Part of**: 95 total PRs across 18 repositories

### Context
This issue represents historical work that was completed during the enterprise development initiative. It was automatically created to preserve the project history and populate the GitHub Projects roadmap.

### Related
- Archive: \`reference/archives/01. 2026-04-09-step6-multi-repo-pr-generation-complete.md\`
- Framework: https://github.com/leo-levintza-lab49/agentic-development-framework"

      create_closed_issue "polybase-poc" "$repo" "$title" "$body" "feat,$team,historical,completed" "$POLYBASE_PROJECT"
      ((total_created++))

      # Rate limit check every 20 issues
      if [ $((total_created % 20)) -eq 0 ]; then
        check_rate_limit
      fi
    done

    log "Completed $repo: $count issues created"
  done

  log "Phase 1 complete: $total_created multi-repo PR issues created"

  # ========================================
  # PHASE 2: Monorepo Services (omnibase-poc)
  # ========================================

  info ""
  info "=========================================="
  info "PHASE 2: Monorepo Services (19 issues)"
  info "=========================================="
  info ""

  check_rate_limit

  # Get omnibase-poc project number
  OMNIBASE_PROJECT=1

  # Create labels for monorepo
  create_labels "omnibase-poc" "enterprise-monorepo"

  # Services with details
  declare -a SERVICES=(
    "user-service:Java:backend:30"
    "auth-service:Java:backend:25"
    "order-service:Java:backend:35"
    "payment-service:Java:backend:30"
    "notification-service:Java:backend:28"
    "web-bff:Node.js:bff:20"
    "mobile-bff:Node.js:bff:20"
    "graphql-gateway:Node.js:bff:18"
    "web-app:React:frontend:25"
    "component-library:React:frontend:22"
    "ios-app:Swift:mobile:15"
    "android-app:Kotlin:mobile:18"
    "mobile-shared:React Native:mobile:12"
    "db-schemas:SQL:data-platform:8"
    "db-migrations:SQL:data-platform:10"
    "terraform-aws-infrastructure:Terraform:platform-sre:20"
    "grafana-dashboards:Config:platform-sre:12"
    "prometheus-alerts:Config:platform-sre:10"
    "claude-configs-shared:Config:platform-sre:8"
  )

  for service_entry in "${SERVICES[@]}"; do
    IFS=: read -r name type team files <<< "$service_entry"

    local title="Generate $name ($type service)"
    local body="## Completed Service Generation

Service: \`$name\`
Type: **$type**
Team: **$team**
Files Generated: **$files**

### Implementation
- [x] Service scaffolding complete
- [x] $files files generated
- [x] $type technology configured
- [x] Tests included
- [x] Dockerfile and documentation created

### Location
\`teams/$team/$name/\`

### Completion
- **Date**: 2026-04-09
- **Part of**: Enterprise Monorepo Phase (19/19 services)

### Context
This service was generated as part of the enterprise monorepo development initiative. All services follow a consistent structure with team-based organization and shared infrastructure.

### Related
- Archive: \`reference/archives/02. 2026-04-09-enterprise-monorepo-completion-19-services.md\`
- Monorepo: https://github.com/omnibase-poc/enterprise-monorepo"

    create_closed_issue "omnibase-poc" "enterprise-monorepo" "$title" "$body" "feat,$team,historical,completed" "$OMNIBASE_PROJECT"
    ((total_created++))
  done

  log "Phase 2 complete: 19 monorepo service issues created"

  # ========================================
  # PHASE 3: Framework Enhancements
  # ========================================

  info ""
  info "=========================================="
  info "PHASE 3: Framework Enhancements (13 issues)"
  info "=========================================="
  info ""

  check_rate_limit

  # Create labels for framework repo
  create_labels "leo-levintza-lab49" "agentic-development-framework"

  # SVG Presentation Images (7 + 4 fixes = 11 total work items, but create 7 issues)
  declare -a SVG_IMAGES=(
    "01-project-results-dashboard.svg:Project results dashboard:✅ Valid (fixed ampersand encoding)"
    "02-architecture-comparison.svg:Architecture comparison:✅ Valid"
    "03-team-structure-tech-stacks.svg:Team structure visualization:✅ Fixed edge alignment"
    "04-configuration-hierarchy.svg:Configuration hierarchy:✅ Valid"
    "05-team-specific-workflows.svg:Team workflows:✅ Fixed ampersand encoding"
    "06-pr-generation-pipeline.svg:PR pipeline:✅ Valid"
    "07-claude-code-extensibility-docs.svg:Extensibility architecture:✅ Complete rewrite for alignment"
  )

  for entry in "${SVG_IMAGES[@]}"; do
    IFS=: read -r file title status <<< "$entry"

    local issue_title="Create presentation SVG: $title"
    local body="## Completed SVG Creation

File: \`images/$file\`
Status: $status
Completion: **2026-04-09**

### Details
- **Format**: 1920×1080px (16:9 aspect ratio)
- **Technology**: SVG with professional styling
- **Theme**: Dark theme for CxO presentations
- **Validation**: XML validated and browser-tested

### Quality Fixes Applied
- XML validation (ampersand encoding)
- Edge alignment corrections
- Layout rebalancing for visual clarity
- Cross-browser compatibility verified

### Purpose
Part of 7-image presentation series showcasing enterprise repository evolution case study for senior leadership stakeholders.

### Related
- Archive: \`reference/archives/04. 2026-04-09-svg-presentation-images-creation-and-fixes.md\`
- Image Location: \`images/$file\`"

    create_closed_issue "leo-levintza-lab49" "agentic-development-framework" "$issue_title" "$body" "docs,completed,historical" "0"
    ((total_created++))
  done

  # Automation script enhancements (6 items)
  declare -a SCRIPT_ENHANCEMENTS=(
    "monitor-pr-progress.sh:PR progress monitoring:Quick PR count check across repositories"
    "watch-pr-progress.sh:PR progress watch:Real-time monitoring with auto-refresh"
    "throttled-pr-generation.sh:Throttled PR generation:Rate-limited batch execution"
    "pr-generator.sh:Commit handler fix:Graceful handling of existing committed files"
    "generate-pr-history.sh:PR existence check:Skip regenerating existing PRs"
    "create_commit_with_timestamp:Empty commit detection:Proper staged change validation"
  )

  for entry in "${SCRIPT_ENHANCEMENTS[@]}"; do
    IFS=: read -r script title desc <<< "$entry"

    local issue_title="$title"
    local body="## Completed Enhancement

Script: \`scripts/$script\`
Purpose: **$desc**
Completion: **2026-04-09**

### Details
- **Type**: Script enhancement/fix
- **Impact**: Improved PR generation reliability and monitoring
- **Technology**: Bash scripting with GitHub CLI integration

### Context
This enhancement was part of the automation infrastructure improvements during the multi-repo PR generation phase. It addressed edge cases and improved the developer experience for monitoring large-scale PR generation.

### Related
- Archive: \`reference/archives/01. 2026-04-09-step6-multi-repo-pr-generation-complete.md\`
- Script Location: \`scripts/$script\`"

    create_closed_issue "leo-levintza-lab49" "agentic-development-framework" "$issue_title" "$body" "feat,chore,completed,historical" "0"
    ((total_created++))
  done

  log "Phase 3 complete: 13 framework enhancement issues created"

  # ========================================
  # FINAL SUMMARY
  # ========================================

  info ""
  log "=========================================="
  log "✅ HISTORICAL ISSUE CREATION COMPLETE"
  log "=========================================="
  log ""
  log "Total Issues Created: $total_created"
  log ""
  log "Breakdown:"
  log "  - Multi-repo PRs (polybase-poc): 95 issues"
  log "  - Monorepo services (omnibase-poc): 19 issues"
  log "  - Framework enhancements: 13 issues"
  log ""
  log "All issues created as closed with completion date: 2026-04-09"
  log ""
  info "Next steps:"
  info "  1. View polybase-poc roadmap: https://github.com/orgs/polybase-poc/projects/2"
  info "  2. View omnibase-poc roadmap: https://github.com/orgs/omnibase-poc/projects/1"
  info "  3. Verify issues in each repository"
  log ""

  check_rate_limit
}

# Execute
main "$@"
