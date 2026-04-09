#!/usr/bin/env bash
#
# timeline-manager-example.sh - Usage examples for timeline manager library
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/timeline-manager.sh"

echo "=========================================="
echo "Timeline Manager Usage Examples"
echo "=========================================="
echo ""

# Example 1: Creating a PR with realistic timestamps
echo "Example 1: Creating a PR with realistic timestamps"
echo "---"

PR_CREATED="2026-04-09T10:30:00"
echo "PR created at: $PR_CREATED"

# Simple PR - reviewed quickly
REVIEW_HOURS=3
MERGE_TIME=$(calculate_merge_time "$PR_CREATED" "$REVIEW_HOURS")
echo "Simple PR (${REVIEW_HOURS}h review): merged at $MERGE_TIME"

# Medium complexity PR
REVIEW_HOURS=12
MERGE_TIME=$(calculate_merge_time "$PR_CREATED" "$REVIEW_HOURS")
echo "Medium PR (${REVIEW_HOURS}h review): merged at $MERGE_TIME"

# Complex PR - spans multiple days
REVIEW_HOURS=24
MERGE_TIME=$(calculate_merge_time "$PR_CREATED" "$REVIEW_HOURS")
echo "Complex PR (${REVIEW_HOURS}h review): merged at $MERGE_TIME"
echo ""

# Example 2: Generating commit timestamps
echo "Example 2: Generating commit timestamps"
echo "---"

PR_START="2026-04-09T14:00:00"
echo "PR started at: $PR_START"
echo ""

# Simple PR - single commit
echo "Simple PR (1 commit):"
COMMITS=$(generate_commit_timestamps "$PR_START" 1 "simple")
echo "  $COMMITS"
echo ""

# Medium PR - 3 commits spread over time
echo "Medium PR (3 commits):"
COMMITS=$(generate_commit_timestamps "$PR_START" 3 "medium")
for commit in $COMMITS; do
    GIT_TS=$(to_git_timestamp "$commit")
    echo "  Commit: $GIT_TS"
done
echo ""

# Complex PR - 5 commits over several days
echo "Complex PR (5 commits):"
COMMITS=$(generate_commit_timestamps "$PR_START" 5 "complex")
for commit in $COMMITS; do
    GIT_TS=$(to_git_timestamp "$commit")
    echo "  Commit: $GIT_TS"
done
echo ""

# Example 3: Weekend and holiday handling
echo "Example 3: Weekend and holiday handling"
echo "---"

# Friday afternoon commit
FRIDAY_PM="2026-04-10T16:30:00"
echo "Friday 4:30pm: $FRIDAY_PM"
NORMALIZED=$(normalize_to_business_hours "$FRIDAY_PM")
echo "  Normalized: $NORMALIZED (stays same, in business hours)"

# Saturday commit - should move to Monday
SATURDAY="2026-04-11T10:00:00"
echo "Saturday 10am: $SATURDAY"
NORMALIZED=$(normalize_to_business_hours "$SATURDAY")
echo "  Normalized: $NORMALIZED (moved to Monday)"

# Holiday (Christmas)
CHRISTMAS="2026-12-25T10:00:00"
echo "Christmas: $CHRISTMAS"
NORMALIZED=$(normalize_to_business_hours "$CHRISTMAS")
echo "  Normalized: $NORMALIZED (moved to next business day)"
echo ""

# Example 4: Business hours arithmetic
echo "Example 4: Business hours arithmetic"
echo "---"

BASE_TIME="2026-04-09T15:00:00"
echo "Base time: $BASE_TIME (Wednesday 3pm)"
echo ""

# Add hours that fit in same day
echo "Add 2 hours:"
RESULT=$(add_business_hours "$BASE_TIME" 2)
echo "  Result: $RESULT (same day, 5pm)"

# Add hours that span to next day
echo "Add 5 hours:"
RESULT=$(add_business_hours "$BASE_TIME" 5)
echo "  Result: $RESULT (spans to next day)"

# Add hours that span multiple days
echo "Add 20 hours:"
RESULT=$(add_business_hours "$BASE_TIME" 20)
echo "  Result: $RESULT (spans multiple days)"
echo ""

# Example 5: Realistic development workflow
echo "Example 5: Realistic development workflow"
echo "---"

# Senior developer working on a feature
DEV_START="2026-04-07T09:30:00"
echo "Senior dev starts feature: $DEV_START (Monday 9:30am)"

# Initial implementation - takes most of the day
INITIAL_COMMIT="$DEV_START"
echo "Initial commit: $(to_git_timestamp "$INITIAL_COMMIT")"

# Code review feedback - next morning
REVIEW_RECEIVED=$(add_business_hours "$INITIAL_COMMIT" 18)
echo "Review received: $(to_git_timestamp "$REVIEW_RECEIVED")"

# Address feedback - 3 hours later
SECOND_COMMIT=$(add_business_hours "$REVIEW_RECEIVED" 3)
echo "Fix review comments: $(to_git_timestamp "$SECOND_COMMIT")"

# Final approval and merge - 2 hours later
MERGE_TIME=$(add_business_hours "$SECOND_COMMIT" 2)
echo "PR merged: $(to_git_timestamp "$MERGE_TIME")"

# Calculate total elapsed business hours
TOTAL_HOURS=23
echo "Total elapsed: $TOTAL_HOURS business hours (~3 days)"
echo ""

# Example 6: Converting timestamps for Git
echo "Example 6: Converting timestamps for Git"
echo "---"

ISO_TIME="2026-04-09T14:23:45"
GIT_TIME=$(to_git_timestamp "$ISO_TIME")
echo "ISO format:  $ISO_TIME"
echo "Git format:  $GIT_TIME"
echo "Usage:       GIT_AUTHOR_DATE='$GIT_TIME' git commit ..."
echo ""

echo "=========================================="
echo "All examples completed successfully!"
echo "=========================================="
