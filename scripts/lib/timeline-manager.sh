#!/usr/bin/env bash
#
# timeline-manager.sh - Realistic timestamp spreading for commits and PRs
#
# This library ensures commits and PRs have realistic timestamps that:
# - Respect business hours (9am-6pm)
# - Skip weekends
# - Spread commits realistically across PR lifetime
# - Handle timezone conversions
#

set -euo pipefail

# Default timezone
TIMELINE_TZ="${TIMELINE_TZ:-America/New_York}"

# Business hours (24-hour format)
BUSINESS_START_HOUR=9
BUSINESS_END_HOUR=18

# US Federal Holidays for 2026 (format: YYYY-MM-DD)
declare -a US_HOLIDAYS_2026=(
    "2026-01-01"  # New Year's Day
    "2026-01-19"  # MLK Day
    "2026-02-16"  # Presidents' Day
    "2026-05-25"  # Memorial Day
    "2026-07-03"  # Independence Day (observed)
    "2026-09-07"  # Labor Day
    "2026-10-12"  # Columbus Day
    "2026-11-11"  # Veterans Day
    "2026-11-26"  # Thanksgiving
    "2026-12-25"  # Christmas
)

#######################################
# Check if a date is a US federal holiday
# Arguments:
#   date_str: Date in YYYY-MM-DD format
# Returns:
#   0 if holiday, 1 if not
#######################################
is_holiday() {
    local date_str="$1"
    local holiday

    for holiday in "${US_HOLIDAYS_2026[@]}"; do
        if [[ "$date_str" == "$holiday" ]]; then
            return 0
        fi
    done

    return 1
}

#######################################
# Check if timestamp is on weekend
# Arguments:
#   timestamp: ISO 8601 timestamp
# Returns:
#   0 if weekday, 1 if weekend
#######################################
is_weekend() {
    local timestamp="$1"
    local day_of_week

    # Get day of week (0=Sunday, 6=Saturday)
    day_of_week=$(TZ="$TIMELINE_TZ" date -j -f "%Y-%m-%dT%H:%M:%S" \
        "${timestamp:0:19}" "+%w" 2>/dev/null || echo "0")

    if [[ "$day_of_week" == "0" ]] || [[ "$day_of_week" == "6" ]]; then
        return 1  # Weekend
    fi

    return 0  # Weekday
}

#######################################
# Check if timestamp is during business hours
# Arguments:
#   timestamp: ISO 8601 timestamp
# Returns:
#   0 if business hours, 1 if not
#######################################
is_business_hours() {
    local timestamp="$1"
    local hour

    # Extract hour from timestamp
    hour=$(TZ="$TIMELINE_TZ" date -j -f "%Y-%m-%dT%H:%M:%S" \
        "${timestamp:0:19}" "+%H" 2>/dev/null || echo "0")

    # Remove leading zero for comparison
    hour=$((10#$hour))

    if [[ $hour -ge $BUSINESS_START_HOUR ]] && [[ $hour -lt $BUSINESS_END_HOUR ]]; then
        return 0  # Business hours
    fi

    return 1  # Outside business hours
}

#######################################
# Get next business day at 9am
# Arguments:
#   timestamp: ISO 8601 timestamp
# Returns:
#   Next business day at 9am in ISO format
#######################################
get_next_business_day() {
    local timestamp="$1"
    local date_part="${timestamp:0:10}"
    local next_day="$date_part"
    local max_iterations=10
    local iterations=0

    while [[ $iterations -lt $max_iterations ]]; do
        # Add one day
        next_day=$(TZ="$TIMELINE_TZ" date -j -v+1d -f "%Y-%m-%d" \
            "$next_day" "+%Y-%m-%d" 2>/dev/null)

        local test_timestamp="${next_day}T09:00:00"

        # Check if it's a weekday and not a holiday
        if is_weekend "$test_timestamp" && ! is_holiday "$next_day"; then
            echo "${next_day}T09:00:00"
            return 0
        fi

        iterations=$((iterations + 1))
    done

    # Fallback: return original with 9am
    echo "${date_part}T09:00:00"
}

#######################################
# Normalize timestamp to business hours
# If outside business hours or on weekend, move to next business day 9am
# Arguments:
#   timestamp: ISO 8601 timestamp
# Returns:
#   Normalized timestamp in ISO format
#######################################
normalize_to_business_hours() {
    local timestamp="$1"
    local date_part="${timestamp:0:10}"

    # Check if holiday
    if is_holiday "$date_part"; then
        get_next_business_day "$timestamp"
        return 0
    fi

    # Check if weekend
    if ! is_weekend "$timestamp"; then
        get_next_business_day "$timestamp"
        return 0
    fi

    # Check if outside business hours
    if ! is_business_hours "$timestamp"; then
        local hour
        hour=$(TZ="$TIMELINE_TZ" date -j -f "%Y-%m-%dT%H:%M:%S" \
            "${timestamp:0:19}" "+%H" 2>/dev/null || echo "0")
        hour=$((10#$hour))

        # If before 9am, move to 9am same day
        if [[ $hour -lt $BUSINESS_START_HOUR ]]; then
            echo "${date_part}T09:00:00"
            return 0
        fi

        # If after 6pm, move to 9am next business day
        get_next_business_day "$timestamp"
        return 0
    fi

    # Already in business hours on a weekday
    echo "$timestamp"
}

#######################################
# Add business hours to a timestamp
# Skips weekends and holidays, only counts business hours
# Arguments:
#   base_timestamp: ISO 8601 timestamp
#   hours_to_add: Number of hours to add
# Returns:
#   New timestamp in ISO format
#######################################
add_business_hours() {
    local base="$1"
    local hours="$2"
    local current="$base"
    local remaining_hours="$hours"

    # Normalize starting point to business hours
    current=$(normalize_to_business_hours "$current")

    while (( $(echo "$remaining_hours > 0" | bc -l) )); do
        # Get current hour
        local hour
        hour=$(TZ="$TIMELINE_TZ" date -j -f "%Y-%m-%dT%H:%M:%S" \
            "${current:0:19}" "+%H" 2>/dev/null || echo "9")
        hour=$((10#$hour))

        # Calculate hours left in current business day
        local hours_left_today=$((BUSINESS_END_HOUR - hour))

        if (( $(echo "$remaining_hours <= $hours_left_today" | bc -l) )); then
            # Can fit remaining hours in current day
            current=$(TZ="$TIMELINE_TZ" date -j -v+"${remaining_hours}H" \
                -f "%Y-%m-%dT%H:%M:%S" "${current:0:19}" "+%Y-%m-%dT%H:%M:%S" 2>/dev/null || echo "$current")
            remaining_hours=0
        else
            # Move to next business day at 9am
            remaining_hours=$(echo "$remaining_hours - $hours_left_today" | bc -l)
            current=$(get_next_business_day "$current")
        fi
    done

    echo "$current"
}

#######################################
# Calculate merge time based on review hours
# Arguments:
#   created_timestamp: ISO 8601 timestamp when PR was created
#   review_hours: Number of business hours for review
# Returns:
#   Merge timestamp in ISO format
#######################################
calculate_merge_time() {
    local created="$1"
    local review_hours="$2"

    add_business_hours "$created" "$review_hours"
}

#######################################
# Generate realistic commit timestamps within a PR
# Arguments:
#   pr_created_time: ISO 8601 timestamp when PR was created
#   number_of_commits: Number of commits to generate
#   pr_complexity: simple, medium, or complex (optional, default: medium)
# Returns:
#   Space-separated list of timestamps
#######################################
generate_commit_timestamps() {
    local created="$1"
    local num_commits="$2"
    local complexity="${3:-medium}"
    local -a timestamps=()

    # First commit is at PR creation time
    timestamps+=("$created")

    if [[ $num_commits -eq 1 ]]; then
        echo "$created"
        return 0
    fi

    # Determine time spread based on complexity
    local total_hours
    case "$complexity" in
        simple)
            total_hours=4  # 4 business hours
            ;;
        medium)
            total_hours=16  # 2 business days
            ;;
        complex)
            total_hours=24  # 3 business days
            ;;
        *)
            total_hours=16
            ;;
    esac

    # Generate additional commit timestamps
    local interval
    interval=$(echo "$total_hours / ($num_commits - 1)" | bc -l)

    for ((i=1; i<num_commits; i++)); do
        local hours_to_add
        hours_to_add=$(echo "$interval * $i" | bc -l)

        # Add some randomness (±30 minutes)
        local randomness
        randomness=$(echo "scale=2; ($RANDOM % 100) / 100 - 0.5" | bc -l)
        hours_to_add=$(echo "$hours_to_add + $randomness" | bc -l)

        local commit_time
        commit_time=$(add_business_hours "$created" "$hours_to_add")
        timestamps+=("$commit_time")
    done

    # Return timestamps as space-separated list
    echo "${timestamps[*]}"
}

#######################################
# Convert ISO timestamp to Git-compatible format
# Arguments:
#   timestamp: ISO 8601 timestamp
# Returns:
#   Git-compatible timestamp (YYYY-MM-DD HH:MM:SS -HHMM)
#######################################
to_git_timestamp() {
    local timestamp="$1"

    # Get date and time parts
    local datetime="${timestamp:0:19}"

    # Get timezone offset
    local tz_offset
    tz_offset=$(TZ="$TIMELINE_TZ" date -j -f "%Y-%m-%dT%H:%M:%S" \
        "$datetime" "+%z" 2>/dev/null || echo "-0500")

    # Format for Git: YYYY-MM-DD HH:MM:SS ±HHMM
    local git_format
    git_format=$(TZ="$TIMELINE_TZ" date -j -f "%Y-%m-%dT%H:%M:%S" \
        "$datetime" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$datetime")

    echo "$git_format $tz_offset"
}

#######################################
# Get current timestamp in business hours
# Returns:
#   Current timestamp normalized to business hours
#######################################
get_current_business_timestamp() {
    local now
    now=$(TZ="$TIMELINE_TZ" date "+%Y-%m-%dT%H:%M:%S")
    normalize_to_business_hours "$now"
}

#######################################
# Validate ISO timestamp format
# Arguments:
#   timestamp: Timestamp to validate
# Returns:
#   0 if valid, 1 if invalid
#######################################
is_valid_timestamp() {
    local timestamp="$1"

    # Check basic format
    if [[ ! "$timestamp" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2} ]]; then
        return 1
    fi

    # Try to parse it
    if ! TZ="$TIMELINE_TZ" date -j -f "%Y-%m-%dT%H:%M:%S" \
        "${timestamp:0:19}" "+%s" >/dev/null 2>&1; then
        return 1
    fi

    return 0
}

# Export functions for use in other scripts
export -f is_holiday
export -f is_weekend
export -f is_business_hours
export -f get_next_business_day
export -f normalize_to_business_hours
export -f add_business_hours
export -f calculate_merge_time
export -f generate_commit_timestamps
export -f to_git_timestamp
export -f get_current_business_timestamp
export -f is_valid_timestamp
