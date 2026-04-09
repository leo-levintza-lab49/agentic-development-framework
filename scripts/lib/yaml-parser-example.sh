#!/usr/bin/env bash
#
# YAML Parser Library - Usage Examples
# Demonstrates how to use the YAML parser to read PR configurations
#

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source the YAML parser library
source "$SCRIPT_DIR/yaml-parser.sh"

echo "=== YAML Parser Library - Usage Examples ==="
echo ""

# Example 1: Parse a single YAML file
echo "1. Parse a single YAML file:"
echo "   parse_yaml_file \"\$PROJECT_ROOT/config/pr-definitions-month1-2.yaml\""
parse_yaml_file "$PROJECT_ROOT/config/pr-definitions-month1-2.yaml"
echo "   Result: Loaded $(get_pr_count) PRs"
echo ""

# Example 2: Get all PR IDs
echo "2. Get all PR IDs:"
echo "   get_all_pr_ids | head -10"
get_all_pr_ids | head -10
echo ""

# Example 3: Get specific field from a PR
echo "3. Get specific field from a PR:"
echo "   get_pr_field 1 title"
echo "   => $(get_pr_field 1 title)"
echo ""
echo "   get_pr_field 1 repo"
echo "   => $(get_pr_field 1 repo)"
echo ""

# Example 4: Get PR dependencies
echo "4. Get PR dependencies:"
echo "   get_pr_dependencies 2"
echo "   => $(get_pr_dependencies 2)"
echo ""

# Example 5: Get PR files
echo "5. Get PR files:"
echo "   get_pr_files 1"
get_pr_files 1
echo ""

# Example 6: Filter PRs by repository
echo "6. Filter PRs by repository:"
echo "   get_prs_by_repo 'db-schemas'"
echo "   => $(get_prs_by_repo 'db-schemas' | paste -sd ',' -)"
echo ""

# Example 7: Filter PRs by team
echo "7. Filter PRs by team:"
echo "   get_prs_by_team 'backend'"
echo "   => $(get_prs_by_team 'backend' | head -5 | paste -sd ',' -)"
echo ""

# Example 8: Filter PRs by complexity
echo "8. Filter PRs by complexity:"
echo "   get_prs_by_complexity 'senior-level'"
echo "   => $(get_prs_by_complexity 'senior-level' | paste -sd ',' -)"
echo ""

# Example 9: Print PR summary
echo "9. Print PR summary:"
echo "   print_pr_summary 1"
print_pr_summary 1
echo ""

# Example 10: Get full PR config
echo "10. Get full PR config:"
echo "    get_pr_config 1 | head -8"
get_pr_config 1 | head -8
echo ""

# Example 11: Get metadata field
echo "11. Get metadata field:"
echo "    get_metadata_field \"\$PROJECT_ROOT/config/pr-definitions-month1-2.yaml\" phase"
echo "    => $(get_metadata_field "$PROJECT_ROOT/config/pr-definitions-month1-2.yaml" phase)"
echo ""

# Example 12: Iterate through all PRs
echo "12. Iterate through all PRs:"
echo "    for pr_id in \$(get_all_pr_ids | head -3); do"
echo "        echo \"PR #\$pr_id: \$(get_pr_field \$pr_id title)\""
echo "    done"
for pr_id in $(get_all_pr_ids | head -3); do
    echo "    PR #$pr_id: $(get_pr_field $pr_id title)"
done
echo ""

# Example 13: Build dependency graph
echo "13. Build dependency graph (first 5 PRs):"
echo "    for pr_id in \$(get_all_pr_ids | head -5); do"
echo "        deps=\$(get_pr_dependencies \$pr_id)"
echo "        if [ -n \"\$deps\" ]; then"
echo "            echo \"PR #\$pr_id depends on: \$deps\""
echo "        else"
echo "            echo \"PR #\$pr_id has no dependencies\""
echo "        fi"
echo "    done"
for pr_id in $(get_all_pr_ids | head -5); do
    deps=$(get_pr_dependencies $pr_id)
    if [ -n "$deps" ]; then
        echo "    PR #$pr_id depends on: $deps"
    else
        echo "    PR #$pr_id has no dependencies"
    fi
done
echo ""

# Example 14: Access raw data structures
echo "14. Access raw data structures:"
echo "    PR_CONFIGS keys: ${!PR_CONFIGS[@]} | wc -w"
echo "    => $(echo ${!PR_CONFIGS[@]} | wc -w | tr -d ' ') keys"
echo "    ALL_PRS count: \${#ALL_PRS[@]}"
echo "    => ${#ALL_PRS[@]} PRs"
echo ""

# Example 15: Validate YAML file
echo "15. Validate YAML file:"
echo "    validate_yaml_file \"\$PROJECT_ROOT/config/pr-definitions-month1-2.yaml\""
validate_yaml_file "$PROJECT_ROOT/config/pr-definitions-month1-2.yaml" 2>&1 | head -2
echo ""

echo "=== End of Examples ==="
