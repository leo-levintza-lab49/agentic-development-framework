#!/usr/bin/env bash
#
# Simple YAML Parser Test
# Direct testing without subshells to preserve global state
#

# Check bash version
if [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    for bash_path in /opt/homebrew/bin/bash /usr/local/bin/bash /opt/homebrew/Cellar/bash/*/bin/bash; do
        if [ -x "$bash_path" ] && [ "$($bash_path -c 'echo ${BASH_VERSINFO[0]}')" -ge 4 ]; then
            exec "$bash_path" "$0" "$@"
        fi
    done
    echo "ERROR: This script requires bash 4.0 or higher (current: ${BASH_VERSION})"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source the YAML parser
source "$SCRIPT_DIR/yaml-parser.sh"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

pass_count=0
fail_count=0

echo -e "${YELLOW}=== Simple YAML Parser Test ===${NC}"
echo ""

# Test 1: Parse a YAML file
echo -e "${BLUE}TEST 1: Parse month1-2 YAML file${NC}"
parse_yaml_file "$PROJECT_ROOT/config/pr-definitions-month1-2.yaml"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL${NC}"
    ((fail_count++))
fi
echo ""

# Test 2: Check PR count
echo -e "${BLUE}TEST 2: Get PR count${NC}"
pr_count=$(get_pr_count)
echo "  Count: $pr_count"
if [ "$pr_count" -eq 28 ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL - Expected 28, got $pr_count${NC}"
    ((fail_count++))
fi
echo ""

# Test 3: Get all PR IDs
echo -e "${BLUE}TEST 3: Get all PR IDs (first 5)${NC}"
pr_ids=$(get_all_pr_ids | head -5 | paste -sd ',' -)
echo "  IDs: $pr_ids"
if [ -n "$pr_ids" ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL${NC}"
    ((fail_count++))
fi
echo ""

# Test 4: Get PR field
echo -e "${BLUE}TEST 4: Get PR #1 title${NC}"
title=$(get_pr_field 1 title)
echo "  Title: $title"
if [ -n "$title" ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL${NC}"
    ((fail_count++))
fi
echo ""

# Test 5: Get PR repo
echo -e "${BLUE}TEST 5: Get PR #1 repository${NC}"
repo=$(get_pr_field 1 repo)
echo "  Repo: $repo"
if [ "$repo" = "db-schemas" ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL - Expected 'db-schemas', got '$repo'${NC}"
    ((fail_count++))
fi
echo ""

# Test 6: Get PR team
echo -e "${BLUE}TEST 6: Get PR #1 team${NC}"
team=$(get_pr_field 1 team)
echo "  Team: $team"
if [ "$team" = "data-platform" ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL - Expected 'data-platform', got '$team'${NC}"
    ((fail_count++))
fi
echo ""

# Test 7: Get PR dependencies
echo -e "${BLUE}TEST 7: Get PR #2 dependencies${NC}"
deps=$(get_pr_field 2 dependencies)
echo "  Dependencies: $deps"
if [ "$deps" = "1" ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL - Expected '1', got '$deps'${NC}"
    ((fail_count++))
fi
echo ""

# Test 8: Get PR files
echo -e "${BLUE}TEST 8: Get PR #1 files (first 2)${NC}"
files=$(get_pr_files 1 | head -2 | paste -sd ',' -)
echo "  Files: $files"
if [[ "$files" == *"schemas/users.sql"* ]]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL${NC}"
    ((fail_count++))
fi
echo ""

# Test 9: Filter by repo
echo -e "${BLUE}TEST 9: Get PRs for db-schemas repository (first 3)${NC}"
repo_prs=$(get_prs_by_repo 'db-schemas' | head -3 | paste -sd ',' -)
echo "  PRs: $repo_prs"
if [ -n "$repo_prs" ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL${NC}"
    ((fail_count++))
fi
echo ""

# Test 10: Filter by team
echo -e "${BLUE}TEST 10: Get PRs for backend team (first 3)${NC}"
team_prs=$(get_prs_by_team 'backend' | head -3 | paste -sd ',' -)
echo "  PRs: $team_prs"
if [ -n "$team_prs" ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL${NC}"
    ((fail_count++))
fi
echo ""

# Test 11: Filter by complexity
echo -e "${BLUE}TEST 11: Get mid-level PRs (first 5)${NC}"
complex_prs=$(get_prs_by_complexity 'mid-level' | head -5 | paste -sd ',' -)
echo "  PRs: $complex_prs"
if [ -n "$complex_prs" ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL${NC}"
    ((fail_count++))
fi
echo ""

# Test 12: Print PR summary
echo -e "${BLUE}TEST 12: Print PR #1 summary${NC}"
print_pr_summary 1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL${NC}"
    ((fail_count++))
fi
echo ""

# Test 13: Get PR config
echo -e "${BLUE}TEST 13: Get PR #1 full config${NC}"
config=$(get_pr_config 1)
echo "  Config (first 3 lines):"
echo "$config" | head -3 | sed 's/^/    /'
if [ -n "$config" ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL${NC}"
    ((fail_count++))
fi
echo ""

# Test 14: Get metadata
echo -e "${BLUE}TEST 14: Get phase from metadata${NC}"
phase=$(get_metadata_field "$PROJECT_ROOT/config/pr-definitions-month1-2.yaml" phase)
echo "  Phase: $phase"
if [ "$phase" = "foundation" ]; then
    echo -e "${GREEN}  PASS${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL - Expected 'foundation', got '$phase'${NC}"
    ((fail_count++))
fi
echo ""

# Test 15: Error handling
echo -e "${BLUE}TEST 15: Get non-existent PR field (should error)${NC}"
get_pr_field 1 nonexistent 2>&1 | head -1
if get_pr_field 1 nonexistent 2>&1 | grep -q "ERROR"; then
    echo -e "${GREEN}  PASS - Correctly returned error${NC}"
    ((pass_count++))
else
    echo -e "${RED}  FAIL - Should have returned error${NC}"
    ((fail_count++))
fi
echo ""

# Summary
total_count=$((pass_count + fail_count))
echo -e "${YELLOW}=== Test Summary ===${NC}"
echo "Total tests: $total_count"
echo -e "Passed: ${GREEN}$pass_count${NC}"
echo -e "Failed: ${RED}$fail_count${NC}"

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
