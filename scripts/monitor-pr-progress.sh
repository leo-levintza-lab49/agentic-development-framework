#!/opt/homebrew/bin/bash
# Monitor PR generation progress

cd ~/wrk/polybase

echo "==================================="
echo "PR Generation Progress"
echo "Time: $(date)"
echo "==================================="
echo ""

total=0
for repo in */; do
    repo_name=$(basename "$repo")
    if [ -d "$repo/.git" ]; then
        count=$(gh pr list --repo polybase-poc/$repo_name --state all 2>/dev/null | wc -l | tr -d ' ')
        total=$((total + count))
        if [ "$count" -gt 0 ]; then
            printf "%-35s: %2d PRs\n" "$repo_name" "$count"
        fi
    fi
done

echo "==================================="
echo "TOTAL: $total / 95 PRs ($(( total * 100 / 95 ))%)"
echo "Remaining: $(( 95 - total )) PRs"
echo "==================================="
