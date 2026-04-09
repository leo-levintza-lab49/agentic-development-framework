#!/opt/homebrew/bin/bash
# Watch PR generation progress in real-time

INTERVAL=${1:-180}  # Default: check every 3 minutes

echo "Monitoring PR generation progress (checking every $INTERVAL seconds)"
echo "Press Ctrl+C to stop monitoring"
echo ""

last_count=0

while true; do
    cd ~/wrk/polybase

    total=0
    echo "==================================="
    echo "Time: $(date '+%H:%M:%S')"
    echo "==================================="

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
    printf "TOTAL: %d / 95 PRs (%d%%)\n" "$total" "$(( total * 100 / 95 ))"

    if [ "$total" -gt "$last_count" ]; then
        delta=$((total - last_count))
        printf "Progress: +%d PRs since last check\n" "$delta"
    fi

    printf "Remaining: %d PRs\n" "$(( 95 - total ))"
    echo "==================================="
    echo ""

    last_count=$total

    # Check if we're done
    if [ "$total" -ge 95 ]; then
        echo "✅ Target reached! 95+ PRs created."
        break
    fi

    sleep "$INTERVAL"
done
