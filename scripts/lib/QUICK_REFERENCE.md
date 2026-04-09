# Timeline Manager - Quick Reference

## Setup

```bash
source scripts/lib/timeline-manager.sh
```

## Common Use Cases

### 1. Calculate PR Merge Time

```bash
PR_CREATED="2026-04-09T10:00:00"
REVIEW_HOURS=12

MERGE_TIME=$(calculate_merge_time "$PR_CREATED" "$REVIEW_HOURS")
# Result: 2026-04-10T13:00:00
```

### 2. Generate Commit Timestamps

```bash
# Simple PR (1 commit)
COMMITS=$(generate_commit_timestamps "2026-04-09T10:00:00" 1 "simple")

# Medium PR (3 commits, ~2 days)
COMMITS=$(generate_commit_timestamps "2026-04-09T10:00:00" 3 "medium")

# Complex PR (5 commits, ~3 days)
COMMITS=$(generate_commit_timestamps "2026-04-09T10:00:00" 5 "complex")
```

### 3. Create Git Commits with Timestamps

```bash
PR_START="2026-04-09T10:00:00"
COMMITS=$(generate_commit_timestamps "$PR_START" 3 "medium")

for commit_time in $COMMITS; do
    GIT_TS=$(to_git_timestamp "$commit_time")
    GIT_AUTHOR_DATE="$GIT_TS" GIT_COMMITTER_DATE="$GIT_TS" \
        git commit -m "Update feature"
done
```

### 4. Handle Weekend/Holiday Times

```bash
# Move Saturday to Monday
SATURDAY="2026-04-11T10:00:00"
NORMALIZED=$(normalize_to_business_hours "$SATURDAY")
# Result: 2026-04-13T09:00:00

# Move late evening to next morning
LATE="2026-04-09T20:00:00"
NORMALIZED=$(normalize_to_business_hours "$LATE")
# Result: 2026-04-10T09:00:00
```

### 5. Add Business Hours

```bash
# Add hours that wrap to next day
BASE="2026-04-09T16:00:00"  # 4pm
RESULT=$(add_business_hours "$BASE" 4)
# Result: 2026-04-10T11:00:00 (2hrs today + 2hrs tomorrow)
```

## PR Type Templates

### Hotfix (Quick Turnaround)
```bash
PR_START="2026-04-09T14:00:00"
COMMITS=$(generate_commit_timestamps "$PR_START" 1 "simple")
MERGE=$(calculate_merge_time "$PR_START" 2)
```

### Feature (Standard Review)
```bash
PR_START="2026-04-07T09:30:00"
COMMITS=$(generate_commit_timestamps "$PR_START" 3 "medium")
MERGE=$(calculate_merge_time "$PR_START" 12)
```

### Refactoring (Extended Review)
```bash
PR_START="2026-04-07T10:00:00"
COMMITS=$(generate_commit_timestamps "$PR_START" 5 "complex")
MERGE=$(calculate_merge_time "$PR_START" 24)
```

## Validation

```bash
# Check if timestamp is valid
if is_valid_timestamp "2026-04-09T10:00:00"; then
    echo "Valid"
fi

# Check if during business hours
if is_business_hours "2026-04-09T10:00:00"; then
    echo "Business hours"
fi

# Check if weekend
if ! is_weekend "2026-04-09T10:00:00"; then
    echo "Weekend"
fi

# Check if holiday
if is_holiday "2026-12-25"; then
    echo "Holiday"
fi
```

## Timestamp Conversion

```bash
# ISO to Git format
ISO="2026-04-09T14:23:45"
GIT=$(to_git_timestamp "$ISO")
# Result: 2026-04-09 14:23:45 -0400

# Get current business time
NOW=$(get_current_business_timestamp)
```

## Review Time Guidelines

| PR Type | Review Hours | Typical Duration |
|---------|--------------|------------------|
| Hotfix | 2 | Same day |
| Bug Fix | 4-6 | Same day / next morning |
| Feature | 8-16 | 1-2 days |
| Refactor | 16-24 | 2-3 days |
| Major Feature | 24-32 | 3-4 days |

## Commit Patterns

| Complexity | Commits | Time Span | Use Case |
|-----------|---------|-----------|----------|
| Simple | 1 | 4 hours | Hotfix, docs, config |
| Medium | 2-3 | 2 days | Standard feature |
| Complex | 4-5 | 3 days | Large feature, refactor |

## Configuration

```bash
# Change timezone (default: America/New_York)
export TIMELINE_TZ="America/Los_Angeles"

# Business hours (modify in script)
BUSINESS_START_HOUR=9
BUSINESS_END_HOUR=18
```

## Full Example

```bash
#!/usr/bin/env bash
set -euo pipefail

# Load library
source scripts/lib/timeline-manager.sh

# PR parameters
PR_TITLE="Add user authentication"
PR_TYPE="feature"
NUM_COMMITS=3
COMPLEXITY="medium"

# Calculate timeline
PR_CREATED=$(get_current_business_timestamp)
COMMIT_TIMES=$(generate_commit_timestamps "$PR_CREATED" "$NUM_COMMITS" "$COMPLEXITY")
MERGE_TIME=$(calculate_merge_time "$PR_CREATED" 12)

echo "PR: $PR_TITLE"
echo "Created: $PR_CREATED"
echo "Commits:"

# Create commits with timestamps
commit_num=1
for commit_time in $COMMIT_TIMES; do
    GIT_TS=$(to_git_timestamp "$commit_time")
    echo "  $commit_num. $GIT_TS"
    
    # In real script, would do:
    # GIT_AUTHOR_DATE="$GIT_TS" GIT_COMMITTER_DATE="$GIT_TS" \
    #     git commit -m "Implement feature - part $commit_num"
    
    commit_num=$((commit_num + 1))
done

echo "Will merge: $MERGE_TIME"
```

## Testing

```bash
# Run tests
./scripts/lib/test-timeline-manager.sh

# View examples
./scripts/lib/timeline-manager-example.sh
```
