#!/usr/bin/env bash
#
# pr-generator.sh - Core library for creating branches, commits, and PRs
#
# This library provides functions for:
# - Creating feature branches with proper base branch handling
# - Creating commits with specific timestamps
# - Pushing branches and creating PRs via gh CLI
# - Merging PRs with approval simulation
# - Complete PR workflow generation from configuration
#

set -euo pipefail

# Source common utilities if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/common.sh" ]]; then
    source "$SCRIPT_DIR/common.sh"
fi

# ==============================================================================
# Branch Management
# ==============================================================================

# Create a feature branch for PR
# Args: repo_path, branch_name, base_branch
# Returns: 0 on success, 1 on error
create_branch() {
    local repo="$1"
    local branch="$2"
    local base="${3:-main}"

    log_info "Creating branch '$branch' from '$base' in $repo"

    if [[ ! -d "$repo" ]]; then
        log_error "Repository path does not exist: $repo"
        return 1
    fi

    cd "$repo" || return 1

    # Check if branch already exists
    if git rev-parse --verify "$branch" >/dev/null 2>&1; then
        log_warn "Branch '$branch' already exists"
        git checkout "$branch"
        return 0
    fi

    # Ensure we're on the base branch and up to date
    log_debug "Checking out base branch: $base"
    git checkout "$base" || {
        log_error "Failed to checkout base branch: $base"
        return 1
    }

    log_debug "Pulling latest changes from origin/$base"
    git pull origin "$base" || {
        log_error "Failed to pull from origin/$base"
        return 1
    }

    # Create and checkout new branch
    log_debug "Creating new branch: $branch"
    git checkout -b "$branch" || {
        log_error "Failed to create branch: $branch"
        return 1
    }

    log_success "Branch '$branch' created successfully"
    return 0
}

# Delete a branch locally and remotely
# Args: repo_path, branch_name, force
delete_branch() {
    local repo="$1"
    local branch="$2"
    local force="${3:-false}"

    cd "$repo" || return 1

    # Switch to main if we're on the branch to delete
    local current_branch
    current_branch=$(git branch --show-current)
    if [[ "$current_branch" == "$branch" ]]; then
        git checkout main
    fi

    # Delete local branch
    if [[ "$force" == "true" ]]; then
        git branch -D "$branch" 2>/dev/null || true
    else
        git branch -d "$branch" 2>/dev/null || true
    fi

    # Delete remote branch if it exists
    git push origin --delete "$branch" 2>/dev/null || true

    log_success "Branch '$branch' deleted"
    return 0
}

# ==============================================================================
# Commit Management
# ==============================================================================

# Create a commit with specific timestamp
# Args: repo_path, message, timestamp, files_to_add...
# Returns: 0 on success, 1 on error
create_commit() {
    local repo="$1"
    local message="$2"
    local timestamp="$3"
    shift 3
    local files=("$@")

    log_info "Creating commit in $repo"
    log_debug "Commit message: $message"
    log_debug "Timestamp: $timestamp"
    log_debug "Files: ${files[*]}"

    cd "$repo" || return 1

    # Add files to staging
    if [[ ${#files[@]} -eq 0 ]]; then
        log_error "No files specified for commit"
        return 1
    fi

    for file in "${files[@]}"; do
        if [[ ! -e "$file" ]]; then
            log_error "File does not exist: $file"
            return 1
        fi
        git add "$file" || {
            log_error "Failed to add file: $file"
            return 1
        }
    done

    # Check if there are changes to commit
    if ! git diff --cached --quiet; then
        # Create commit with specified timestamp
        GIT_AUTHOR_DATE="$timestamp" \
        GIT_COMMITTER_DATE="$timestamp" \
        git commit -m "$message

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>" || {
            log_error "Failed to create commit"
            return 1
        }

        log_success "Commit created successfully"
        return 0
    else
        log_warn "No changes to commit (files already committed)"
        return 0  # Return success since files are already there
    fi
}

# Create multiple commits from an array of commit configs
# Args: repo_path, commits_array_name
# commits_array should contain: message, timestamp, files
create_commits() {
    local repo="$1"
    local -n commits_array="$2"

    cd "$repo" || return 1

    local commit_count=0
    for commit_config in "${commits_array[@]}"; do
        # Parse commit config (format: "message|timestamp|file1,file2,...")
        IFS='|' read -r message timestamp files_str <<< "$commit_config"
        IFS=',' read -ra files <<< "$files_str"

        if create_commit "$repo" "$message" "$timestamp" "${files[@]}"; then
            ((commit_count++))
        else
            log_error "Failed to create commit: $message"
            return 1
        fi
    done

    log_success "Created $commit_count commits"
    return 0
}

# ==============================================================================
# Pull Request Management
# ==============================================================================

# Check if PR already exists
# Args: repo_path, branch_name
# Returns: 0 if exists, 1 if not
pr_exists() {
    local repo="$1"
    local branch="$2"

    cd "$repo" || return 1

    local result
    result=$(gh pr list --head "$branch" --json number 2>/dev/null || echo "[]")

    if [[ "$result" != "[]" ]] && echo "$result" | grep -q "number"; then
        return 0
    else
        return 1
    fi
}

# Get PR number for a branch
# Args: repo_path, branch_name
# Returns: PR number or empty string
get_pr_number() {
    local repo="$1"
    local branch="$2"

    cd "$repo" || return 1

    gh pr list --head "$branch" --json number --jq '.[0].number' 2>/dev/null || echo ""
}

# Push branch and create PR via gh CLI
# Args: repo_path, branch_name, pr_title, pr_description, labels
# Returns: PR number on success, empty on error
create_pr() {
    local repo="$1"
    local branch="$2"
    local title="$3"
    local description="$4"
    local labels="${5:-}"

    log_info "Creating PR for branch '$branch'"
    log_debug "Title: $title"

    cd "$repo" || return 1

    # Check if PR already exists
    if pr_exists "$repo" "$branch"; then
        log_warn "PR already exists for branch: $branch"
        local pr_num
        pr_num=$(get_pr_number "$repo" "$branch")
        echo "$pr_num"
        return 0
    fi

    # Push branch to remote
    log_debug "Pushing branch to origin"
    git push -u origin "$branch" || {
        log_error "Failed to push branch: $branch"
        return 1
    }

    # Build gh pr create command
    local gh_cmd="gh pr create --title \"$title\" --body \"$description\" --base main"

    # Try to add labels if specified, but don't fail if labels don't exist
    local pr_url
    if [[ -n "$labels" ]]; then
        log_debug "Creating PR via gh CLI with label: $labels"
        pr_url=$(eval "$gh_cmd --label \"$labels\"" 2>&1)

        # If label creation failed, try again without labels
        if [[ $? -ne 0 ]] && echo "$pr_url" | grep -q "not found"; then
            log_warn "Label '$labels' not found, creating PR without label"
            pr_url=$(eval "$gh_cmd" 2>&1) || {
                log_error "Failed to create PR: $pr_url"
                return 1
            }
        elif [[ $? -ne 0 ]]; then
            log_error "Failed to create PR: $pr_url"
            return 1
        fi
    else
        log_debug "Creating PR via gh CLI"
        pr_url=$(eval "$gh_cmd" 2>&1) || {
            log_error "Failed to create PR: $pr_url"
            return 1
        }
    fi

    # Extract PR number from URL (gh pr create returns the URL on the last line)
    local pr_num
    local pr_url_clean=$(echo "$pr_url" | grep -E 'github.com/.*/pull/[0-9]+' | tail -1)

    if [[ -n "$pr_url_clean" ]]; then
        pr_num=$(echo "$pr_url_clean" | grep -oE '[0-9]+$')
    else
        # Fallback: try to get any number from the output
        pr_num=$(echo "$pr_url" | grep -oE '[0-9]+' | tail -1)
    fi

    if [[ -z "$pr_num" ]]; then
        log_error "Failed to extract PR number from output"
        return 1
    fi

    log_success "PR #$pr_num created: $pr_url_clean"
    echo "$pr_num"
    return 0
}

# Add a review comment to a PR
# Args: repo_path, pr_number, comment
add_pr_comment() {
    local repo="$1"
    local pr_num="$2"
    local comment="$3"

    cd "$repo" || return 1

    gh pr comment "$pr_num" --body "$comment" || {
        log_error "Failed to add comment to PR #$pr_num"
        return 1
    }

    log_success "Comment added to PR #$pr_num"
    return 0
}

# Approve a PR
# Args: repo_path, pr_number, review_comment
approve_pr() {
    local repo="$1"
    local pr_num="$2"
    local review_comment="${3:-LGTM! Changes look good.}"

    cd "$repo" || return 1

    log_info "Approving PR #$pr_num"

    gh pr review "$pr_num" --approve --body "$review_comment" || {
        log_error "Failed to approve PR #$pr_num"
        return 1
    }

    log_success "PR #$pr_num approved"
    return 0
}

# Merge PR with specific timestamp
# Args: repo_path, pr_number, merge_timestamp, review_comment
# Returns: 0 on success, 1 on error
merge_pr() {
    local repo="$1"
    local pr_num="$2"
    local timestamp="$3"
    local review_comment="${4:-LGTM! Changes look good.}"

    log_info "Merging PR #$pr_num"
    log_debug "Merge timestamp: $timestamp"

    cd "$repo" || return 1

    # Check if PR exists
    if ! gh pr view "$pr_num" >/dev/null 2>&1; then
        log_error "PR #$pr_num does not exist"
        return 1
    fi

    # Approve PR first
    approve_pr "$repo" "$pr_num" "$review_comment" || return 1

    # Merge with squash and delete branch
    log_debug "Merging PR with squash"
    GIT_AUTHOR_DATE="$timestamp" \
    GIT_COMMITTER_DATE="$timestamp" \
    gh pr merge "$pr_num" --squash --delete-branch || {
        log_error "Failed to merge PR #$pr_num"
        return 1
    }

    log_success "PR #$pr_num merged successfully"
    return 0
}

# Close PR without merging
# Args: repo_path, pr_number, comment
close_pr() {
    local repo="$1"
    local pr_num="$2"
    local comment="${3:-Closing without merging.}"

    cd "$repo" || return 1

    gh pr close "$pr_num" --comment "$comment" || {
        log_error "Failed to close PR #$pr_num"
        return 1
    }

    log_success "PR #$pr_num closed"
    return 0
}

# ==============================================================================
# Complete PR Workflow
# ==============================================================================

# Generate complete PR from configuration
# Args: config_array_name (associative array with all PR details)
# Config keys:
#   - repo_path: Path to repository
#   - branch_name: Name of feature branch
#   - base_branch: Base branch (default: main)
#   - pr_title: PR title
#   - pr_description: PR description
#   - pr_labels: Comma-separated labels
#   - commits: Array of commit configs (message|timestamp|files)
#   - merge_timestamp: When to merge PR
#   - review_comment: Approval comment
#   - auto_merge: Whether to auto-merge (default: true)
# Returns: PR number on success, empty on error
generate_full_pr() {
    local -n config="$1"

    # Extract configuration
    local repo_path="${config[repo_path]}"
    local branch_name="${config[branch_name]}"
    local base_branch="${config[base_branch]:-main}"
    local pr_title="${config[pr_title]}"
    local pr_description="${config[pr_description]}"
    local pr_labels="${config[pr_labels]:-}"
    local merge_timestamp="${config[merge_timestamp]:-}"
    local review_comment="${config[review_comment]:-LGTM! Changes look good.}"
    local auto_merge="${config[auto_merge]:-true}"

    log_info "Generating PR workflow for: $pr_title"

    # Validate required fields
    if [[ -z "$repo_path" ]] || [[ -z "$branch_name" ]] || [[ -z "$pr_title" ]]; then
        log_error "Missing required configuration fields"
        return 1
    fi

    # Step 1: Create branch
    create_branch "$repo_path" "$branch_name" "$base_branch" || {
        log_error "Failed to create branch"
        return 1
    }

    # Step 2: Create commits (handled by caller - they generate code first)
    # This function assumes commits are already created

    # Step 3: Push and create PR
    local pr_num
    pr_num=$(create_pr "$repo_path" "$branch_name" "$pr_title" "$pr_description" "$pr_labels")
    if [[ -z "$pr_num" ]]; then
        log_error "Failed to create PR"
        return 1
    fi

    # Step 4: Auto-merge if configured
    if [[ "$auto_merge" == "true" ]] && [[ -n "$merge_timestamp" ]]; then
        log_info "Auto-merging PR #$pr_num"
        sleep 2  # Brief delay to simulate review time
        merge_pr "$repo_path" "$pr_num" "$merge_timestamp" "$review_comment" || {
            log_error "Failed to merge PR"
            return 1
        }
    fi

    log_success "PR workflow completed: #$pr_num"
    echo "$pr_num"
    return 0
}

# Generate PR with code generation step
# Args: config_array_name, generator_function_name
# This wrapper calls a generator function to create code before committing
generate_pr_with_code() {
    local -n config="$1"
    local generator_func="$2"

    local repo_path="${config[repo_path]}"
    local branch_name="${config[branch_name]}"
    local base_branch="${config[base_branch]:-main}"

    # Step 1: Create branch
    create_branch "$repo_path" "$branch_name" "$base_branch" || return 1

    # Step 2: Generate code using provided function
    log_info "Generating code for PR"
    if ! "$generator_func" "$repo_path" config; then
        log_error "Code generation failed"
        return 1
    fi

    # Step 3: Complete PR workflow
    generate_full_pr config
}

# ==============================================================================
# Validation and Utilities
# ==============================================================================

# Validate gh CLI is authenticated
# Returns: 0 if authenticated, 1 if not
validate_gh_auth() {
    if ! command -v gh >/dev/null 2>&1; then
        log_error "gh CLI is not installed"
        return 1
    fi

    if ! gh auth status >/dev/null 2>&1; then
        log_error "gh CLI is not authenticated. Run: gh auth login"
        return 1
    fi

    return 0
}

# Validate repository path
# Args: repo_path
# Returns: 0 if valid, 1 if not
validate_repo() {
    local repo="$1"

    if [[ ! -d "$repo" ]]; then
        log_error "Repository path does not exist: $repo"
        return 1
    fi

    if [[ ! -d "$repo/.git" ]]; then
        log_error "Not a git repository: $repo"
        return 1
    fi

    return 0
}

# Rollback branch on failure
# Args: repo_path, branch_name
rollback_branch() {
    local repo="$1"
    local branch="$2"

    log_warn "Rolling back branch: $branch"

    cd "$repo" || return 1

    # Switch to main
    git checkout main 2>/dev/null || true

    # Delete local branch
    git branch -D "$branch" 2>/dev/null || true

    # Delete remote branch if pushed
    git push origin --delete "$branch" 2>/dev/null || true

    log_success "Rollback complete"
}

# ==============================================================================
# Logging Functions (if not provided by common.sh)
# ==============================================================================

if ! command -v log_info >/dev/null 2>&1; then
    log_info() { echo "[INFO] $*" >&2; }
    log_error() { echo "[ERROR] $*" >&2; }
    log_warn() { echo "[WARN] $*" >&2; }
    log_debug() { echo "[DEBUG] $*" >&2; }
    log_success() { echo "[SUCCESS] $*" >&2; }
fi

# ==============================================================================
# Export Functions
# ==============================================================================

export -f create_branch
export -f delete_branch
export -f create_commit
export -f create_commits
export -f pr_exists
export -f get_pr_number
export -f create_pr
export -f add_pr_comment
export -f approve_pr
export -f merge_pr
export -f close_pr
export -f generate_full_pr
export -f generate_pr_with_code
export -f validate_gh_auth
export -f validate_repo
export -f rollback_branch
