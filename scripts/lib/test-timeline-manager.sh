#!/usr/bin/env bash
#
# test-timeline-manager.sh - Test suite for timeline manager functions
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/timeline-manager.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

#######################################
# Assert equality
#######################################
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$expected" == "$actual" ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        return 1
    fi
}

#######################################
# Assert true (exit code 0)
#######################################
assert_true() {
    local message="$1"
    shift

    TESTS_RUN=$((TESTS_RUN + 1))

    if "$@"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: $message"
        return 1
    fi
}

#######################################
# Assert false (exit code 1)
#######################################
assert_false() {
    local message="$1"
    shift

    TESTS_RUN=$((TESTS_RUN + 1))

    if ! "$@"; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo "✓ PASS: $message"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo "✗ FAIL: $message"
        return 1
    fi
}

echo "=========================================="
echo "Timeline Manager Test Suite"
echo "=========================================="
echo ""

# Test 1: Validate timestamp format
echo "Test 1: Timestamp validation"
assert_true "Valid timestamp format" is_valid_timestamp "2026-04-09T10:30:00"
assert_false "Invalid timestamp format" is_valid_timestamp "2026-04-09 10:30:00"
assert_false "Invalid date" is_valid_timestamp "2026-13-01T10:00:00"
echo ""

# Test 2: Weekend detection
echo "Test 2: Weekend detection"
assert_true "Wednesday is a weekday" is_weekend "2026-04-08T10:00:00"
assert_false "Saturday is weekend" is_weekend "2026-04-11T10:00:00"
assert_false "Sunday is weekend" is_weekend "2026-04-12T10:00:00"
echo ""

# Test 3: Business hours detection
echo "Test 3: Business hours detection"
assert_true "10am is business hours" is_business_hours "2026-04-09T10:00:00"
assert_true "5pm is business hours" is_business_hours "2026-04-09T17:00:00"
assert_false "8am is not business hours" is_business_hours "2026-04-09T08:00:00"
assert_false "6pm is not business hours" is_business_hours "2026-04-09T18:00:00"
assert_false "11pm is not business hours" is_business_hours "2026-04-09T23:00:00"
echo ""

# Test 4: Holiday detection
echo "Test 4: Holiday detection"
assert_true "New Year's Day 2026" is_holiday "2026-01-01"
assert_true "Christmas 2026" is_holiday "2026-12-25"
assert_false "Regular day" is_holiday "2026-04-09"
echo ""

# Test 5: Normalize to business hours
echo "Test 5: Normalize to business hours"
result=$(normalize_to_business_hours "2026-04-09T08:00:00")
assert_equals "2026-04-09T09:00:00" "$result" "8am normalized to 9am"

result=$(normalize_to_business_hours "2026-04-09T10:30:00")
assert_equals "2026-04-09T10:30:00" "$result" "10:30am stays the same"

result=$(normalize_to_business_hours "2026-04-09T19:00:00")
# Should move to next business day at 9am (April 10)
[[ "$result" =~ ^2026-04-10T09:00:00 ]] && echo "✓ PASS: 7pm normalized to next day 9am" || echo "✗ FAIL: Expected next day 9am, got $result"
TESTS_RUN=$((TESTS_RUN + 1))
[[ "$result" =~ ^2026-04-10T09:00:00 ]] && TESTS_PASSED=$((TESTS_PASSED + 1)) || TESTS_FAILED=$((TESTS_FAILED + 1))
echo ""

# Test 6: Add business hours
echo "Test 6: Add business hours"
result=$(add_business_hours "2026-04-09T10:00:00" 2)
assert_equals "2026-04-09T12:00:00" "$result" "Add 2 hours within same day"

result=$(add_business_hours "2026-04-09T16:00:00" 4)
# Should wrap to next day: 2 hours today (4pm-6pm) + 2 hours next day (9am-11am)
[[ "$result" =~ ^2026-04-10T11:00:00 ]] && echo "✓ PASS: Add 4 hours wraps to next day" || echo "✗ FAIL: Expected next day 11am, got $result"
TESTS_RUN=$((TESTS_RUN + 1))
[[ "$result" =~ ^2026-04-10T11:00:00 ]] && TESTS_PASSED=$((TESTS_PASSED + 1)) || TESTS_FAILED=$((TESTS_FAILED + 1))
echo ""

# Test 7: Calculate merge time
echo "Test 7: Calculate merge time"
result=$(calculate_merge_time "2026-04-09T10:00:00" 3)
assert_equals "2026-04-09T13:00:00" "$result" "3 hour review within same day"

result=$(calculate_merge_time "2026-04-09T15:00:00" 8)
# 3 hours today (3pm-6pm) + 5 hours next day (9am-2pm)
[[ "$result" =~ ^2026-04-10T14:00:00 ]] && echo "✓ PASS: 8 hour review spans two days" || echo "✗ FAIL: Expected 2pm next day, got $result"
TESTS_RUN=$((TESTS_RUN + 1))
[[ "$result" =~ ^2026-04-10T14:00:00 ]] && TESTS_PASSED=$((TESTS_PASSED + 1)) || TESTS_FAILED=$((TESTS_FAILED + 1))
echo ""

# Test 8: Generate commit timestamps
echo "Test 8: Generate commit timestamps"
result=$(generate_commit_timestamps "2026-04-09T10:00:00" 1 "simple")
assert_equals "2026-04-09T10:00:00" "$result" "Single commit at creation time"

result=$(generate_commit_timestamps "2026-04-09T10:00:00" 3 "medium")
count=$(echo "$result" | wc -w | tr -d ' ')
assert_equals "3" "$count" "Generate 3 commit timestamps"

# Verify first timestamp matches creation time
first=$(echo "$result" | awk '{print $1}')
assert_equals "2026-04-09T10:00:00" "$first" "First commit at creation time"
echo ""

# Test 9: Git timestamp conversion
echo "Test 9: Git timestamp conversion"
result=$(to_git_timestamp "2026-04-09T10:30:00")
[[ "$result" =~ ^2026-04-09\ 10:30:00 ]] && echo "✓ PASS: Git timestamp format" || echo "✗ FAIL: Expected git format, got $result"
TESTS_RUN=$((TESTS_RUN + 1))
[[ "$result" =~ ^2026-04-09\ 10:30:00 ]] && TESTS_PASSED=$((TESTS_PASSED + 1)) || TESTS_FAILED=$((TESTS_FAILED + 1))
echo ""

# Test 10: Get current business timestamp
echo "Test 10: Get current business timestamp"
result=$(get_current_business_timestamp)
assert_true "Current timestamp is valid" is_valid_timestamp "$result"
assert_true "Current timestamp is in business hours" is_business_hours "$result"
echo ""

# Summary
echo "=========================================="
echo "Test Results"
echo "=========================================="
echo "Total tests:  $TESTS_RUN"
echo "Passed:       $TESTS_PASSED"
echo "Failed:       $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "✓ All tests passed!"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
