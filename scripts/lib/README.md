# Script Libraries

Reusable shell libraries for the case study implementation.

## timeline-manager.sh

Handles realistic timestamp spreading for commits and pull requests.

### Features

- **Business Hours Awareness**: Only counts 9am-6pm Eastern Time
- **Weekend Skipping**: Automatically moves weekend timestamps to Monday 9am
- **Holiday Detection**: Skips US federal holidays in 2026
- **Realistic Patterns**: Spreads commits naturally across PR lifetime
- **Git Integration**: Converts ISO timestamps to Git-compatible format

### Core Functions

#### `calculate_merge_time(created_timestamp, review_hours)`

Calculate when a PR should be merged based on review time.

```bash
source scripts/lib/timeline-manager.sh

PR_CREATED="2026-04-09T10:00:00"
REVIEW_HOURS=12

MERGE_TIME=$(calculate_merge_time "$PR_CREATED" "$REVIEW_HOURS")
echo "Merge at: $MERGE_TIME"
# Output: Merge at: 2026-04-10T13:00:00
```

#### `generate_commit_timestamps(pr_created_time, number_of_commits, complexity)`

Generate realistic commit timestamps within a PR's lifetime.

```bash
# Simple PR with 1 commit
COMMITS=$(generate_commit_timestamps "2026-04-09T10:00:00" 1 "simple")

# Medium PR with 3 commits spread over ~2 days
COMMITS=$(generate_commit_timestamps "2026-04-09T10:00:00" 3 "medium")

# Complex PR with 5 commits spread over ~3 days
COMMITS=$(generate_commit_timestamps "2026-04-09T10:00:00" 5 "complex")

# Use the timestamps
for commit_time in $COMMITS; do
    GIT_TS=$(to_git_timestamp "$commit_time")
    GIT_AUTHOR_DATE="$GIT_TS" git commit -m "Update feature"
done
```

Complexity levels:
- `simple`: 4 business hours total
- `medium`: 16 business hours (~2 days)
- `complex`: 24 business hours (~3 days)

#### `add_business_hours(base_timestamp, hours_to_add)`

Add business hours to a timestamp, skipping weekends and holidays.

```bash
BASE="2026-04-09T15:00:00"  # Wednesday 3pm
RESULT=$(add_business_hours "$BASE" 5)
echo "$RESULT"  # 2026-04-10T11:00:00 (wraps to next day)
```

#### `normalize_to_business_hours(timestamp)`

Move a timestamp to the next available business hour if it falls outside.

```bash
# Saturday morning -> Monday 9am
SATURDAY="2026-04-11T10:00:00"
NORMALIZED=$(normalize_to_business_hours "$SATURDAY")
echo "$NORMALIZED"  # 2026-04-13T09:00:00

# Late evening -> Next day 9am
LATE="2026-04-09T20:00:00"
NORMALIZED=$(normalize_to_business_hours "$LATE")
echo "$NORMALIZED"  # 2026-04-10T09:00:00
```

#### `to_git_timestamp(iso_timestamp)`

Convert ISO 8601 timestamp to Git-compatible format.

```bash
ISO="2026-04-09T14:23:45"
GIT=$(to_git_timestamp "$ISO")
echo "$GIT"  # 2026-04-09 14:23:45 -0400

# Use with git
GIT_AUTHOR_DATE="$GIT" git commit -m "Feature update"
```

### Utility Functions

#### `is_business_hours(timestamp)`

Check if a timestamp is during business hours (9am-6pm).

```bash
if is_business_hours "2026-04-09T10:00:00"; then
    echo "During business hours"
fi
```

#### `is_weekend(timestamp)`

Check if a timestamp falls on a weekend.

```bash
if ! is_weekend "2026-04-12T10:00:00"; then
    echo "It's the weekend"
fi
```

#### `is_holiday(date_string)`

Check if a date is a US federal holiday.

```bash
if is_holiday "2026-12-25"; then
    echo "It's Christmas"
fi
```

#### `is_valid_timestamp(timestamp)`

Validate ISO 8601 timestamp format.

```bash
if is_valid_timestamp "2026-04-09T10:00:00"; then
    echo "Valid timestamp"
fi
```

#### `get_current_business_timestamp()`

Get current time normalized to business hours.

```bash
NOW=$(get_current_business_timestamp)
echo "Current business time: $NOW"
```

### Configuration

Set timezone via environment variable (defaults to Eastern Time):

```bash
export TIMELINE_TZ="America/Los_Angeles"
source scripts/lib/timeline-manager.sh
```

### Realistic Patterns

The library implements realistic development patterns:

#### Quick Bug Fix
```bash
# Created Friday afternoon, merged same day
PR_START="2026-04-10T14:00:00"
COMMITS=$(generate_commit_timestamps "$PR_START" 1 "simple")
MERGE=$(calculate_merge_time "$PR_START" 2)
```

#### Standard Feature
```bash
# Created Monday morning, iterative development, merged Wednesday
PR_START="2026-04-07T09:30:00"
COMMITS=$(generate_commit_timestamps "$PR_START" 3 "medium")
MERGE=$(calculate_merge_time "$PR_START" 16)
```

#### Complex Refactoring
```bash
# Created Monday, significant iteration, merged following week
PR_START="2026-04-07T10:00:00"
COMMITS=$(generate_commit_timestamps "$PR_START" 5 "complex")
MERGE=$(calculate_merge_time "$PR_START" 32)
```

### Testing

Run the test suite:

```bash
./scripts/lib/test-timeline-manager.sh
```

View usage examples:

```bash
./scripts/lib/timeline-manager-example.sh
```

### Integration with PR Generation

Example integration with PR generation script:

```bash
source scripts/lib/timeline-manager.sh

# Get PR details from configuration
PR_TYPE="feature"
COMPLEXITY="medium"
NUM_COMMITS=3

# Calculate realistic timeline
PR_CREATED=$(get_current_business_timestamp)
COMMIT_TIMES=$(generate_commit_timestamps "$PR_CREATED" "$NUM_COMMITS" "$COMPLEXITY")

# Determine review time based on PR type
case "$PR_TYPE" in
    hotfix)
        REVIEW_HOURS=2
        ;;
    feature)
        REVIEW_HOURS=12
        ;;
    refactor)
        REVIEW_HOURS=24
        ;;
esac

MERGE_TIME=$(calculate_merge_time "$PR_CREATED" "$REVIEW_HOURS")

# Create commits with realistic timestamps
for commit_time in $COMMIT_TIMES; do
    GIT_TS=$(to_git_timestamp "$commit_time")
    GIT_AUTHOR_DATE="$GIT_TS" GIT_COMMITTER_DATE="$GIT_TS" \
        git commit -m "Implement feature"
done

# Create PR (would be merged at MERGE_TIME)
gh pr create --title "Feature" --body "Description"
```

### Notes

- All timestamps are in ISO 8601 format: `YYYY-MM-DDTHH:MM:SS`
- Business hours: 9am-6pm (9 hours per day)
- Weekends are Saturday (day 6) and Sunday (day 0)
- US Federal holidays for 2026 are pre-configured
- Timezone defaults to America/New_York (EDT/EST)
- Uses macOS `date -j` command (BSD date)

### Limitations

- Currently supports macOS/BSD date command syntax
- Holiday list only includes 2026 US federal holidays
- Does not account for company-specific holidays or PTO
- Business hours are fixed (not configurable per call)

### Future Enhancements

Potential improvements for production use:

- Linux/GNU date compatibility layer
- Configurable business hours per organization
- Company-specific holiday calendars
- Developer availability/PTO calendars
- Time zone conversion utilities
- Working hours by region (US, EU, APAC)
