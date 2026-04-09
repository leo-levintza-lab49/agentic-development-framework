#!/bin/bash
#
# Validation Functions
#

# Source utilities if not already loaded
if [ -z "$UTILS_LOADED" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/utils.sh"
fi

# Validate repository
validate_repository() {
    local org=$1
    local repo=$2
    local level=${3:-detailed}

    print_info "Validating $org/$repo (level: $level)..."

    local errors=0

    # Basic: Repository exists
    if ! gh api "/repos/$org/$repo" >/dev/null 2>&1; then
        print_error "  Repository does not exist"
        return 1
    fi
    print_success "  Repository exists"

    # Basic: Check default branch
    local default_branch=$(gh api "/repos/$org/$repo" --jq '.default_branch')
    if [ "$default_branch" = "main" ]; then
        print_success "  Default branch is 'main'"
    else
        print_warning "  Default branch is '$default_branch' (expected 'main')"
        ((errors++))
    fi

    if [ "$level" = "basic" ]; then
        return $errors
    fi

    # Detailed: Check for key files
    if gh api "/repos/$org/$repo/contents/README.md" >/dev/null 2>&1; then
        print_success "  README.md exists"
    else
        print_error "  README.md missing"
        ((errors++))
    fi

    if gh api "/repos/$org/$repo/contents/.claude" >/dev/null 2>&1; then
        print_success "  .claude/ directory exists"
    else
        print_error "  .claude/ directory missing"
        ((errors++))
    fi

    if gh api "/repos/$org/$repo/contents/.github" >/dev/null 2>&1; then
        print_success "  .github/ directory exists"
    else
        print_warning "  .github/ directory missing"
    fi

    # Check for workflows
    if gh api "/repos/$org/$repo/contents/.github/workflows" >/dev/null 2>&1; then
        local workflow_count=$(gh api "/repos/$org/$repo/contents/.github/workflows" --jq 'length')
        print_success "  Found $workflow_count workflow(s)"
    else
        print_warning "  No workflows found"
    fi

    if [ "$level" = "comprehensive" ]; then
        # Comprehensive: Additional checks

        # Check if repo can be cloned
        local temp_dir=$(mktemp -d)
        if gh repo clone "$org/$repo" "$temp_dir" -- --depth 1 >/dev/null 2>&1; then
            print_success "  Repository can be cloned"
            rm -rf "$temp_dir"
        else
            print_error "  Failed to clone repository"
            ((errors++))
        fi
    fi

    if [ $errors -eq 0 ]; then
        print_success "Validation passed for $org/$repo"
        return 0
    else
        print_warning "Validation completed with $errors issue(s)"
        return $errors
    fi
}

# Validate all repositories in an organization
validate_org_repos() {
    local org=$1
    local level=${2:-detailed}

    print_info "Validating all repositories in $org..."

    local repos=$(gh repo list "$org" --limit 1000 --json name --jq '.[].name')
    local total=0
    local passed=0
    local failed=0

    while IFS= read -r repo; do
        ((total++))
        if validate_repository "$org" "$repo" "$level"; then
            ((passed++))
        else
            ((failed++))
        fi
        echo ""
    done <<< "$repos"

    print_info "Validation Summary:"
    echo "  Total: $total"
    echo "  Passed: $passed"
    echo "  Failed: $failed"

    [ $failed -eq 0 ]
}

# Validate team exists
validate_team() {
    local org=$1
    local team_slug=$2

    if gh api "/orgs/$org/teams/$team_slug" >/dev/null 2>&1; then
        print_success "Team '$team_slug' exists in $org"
        return 0
    else
        print_error "Team '$team_slug' does not exist in $org"
        return 1
    fi
}

# Check repository locally
validate_local_repo() {
    local repo_path=$1

    if [ ! -d "$repo_path" ]; then
        print_error "Directory does not exist: $repo_path"
        return 1
    fi

    if [ ! -d "$repo_path/.git" ]; then
        print_error "Not a git repository: $repo_path"
        return 1
    fi

    cd "$repo_path" || return 1

    # Check for required files
    local required_files=("README.md" ".claude/settings.json" ".gitignore")
    local missing=0

    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            print_success "  $file exists"
        else
            print_error "  $file missing"
            ((missing++))
        fi
    done

    [ $missing -eq 0 ]
}

export -f validate_repository
export -f validate_org_repos
export -f validate_team
export -f validate_local_repo
