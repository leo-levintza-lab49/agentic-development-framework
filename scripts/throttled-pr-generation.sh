#!/opt/homebrew/bin/bash
# Throttled PR generation with automatic batching

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Batch configuration
BATCH_SIZE=20
DELAY_BETWEEN_BATCHES=300  # 5 minutes in seconds (safe for API limits)

# PR range to process
START_PR=${1:-1}
END_PR=${2:-95}

echo "Starting throttled PR generation"
echo "  Range: PR $START_PR to $END_PR"
echo "  Batch size: $BATCH_SIZE PRs"
echo "  Delay between batches: $DELAY_BETWEEN_BATCHES seconds ($(($DELAY_BETWEEN_BATCHES / 60)) minutes)"
echo ""

current_pr=$START_PR
batch_num=1

while [ $current_pr -le $END_PR ]; do
    batch_end=$((current_pr + BATCH_SIZE - 1))
    if [ $batch_end -gt $END_PR ]; then
        batch_end=$END_PR
    fi

    echo ""
    echo "=========================================="
    echo "Batch $batch_num: PR $current_pr to $batch_end"
    echo "Time: $(date)"
    echo "=========================================="

    log_file="$PROJECT_ROOT/logs/batch-${batch_num}-pr${current_pr}-to-pr${batch_end}.log"

    if "$SCRIPT_DIR/generate-pr-history.sh" \
        --org polybase-poc \
        --skip-merge \
        --resume-from $current_pr \
        2>&1 | tee "$log_file"; then
        echo "✅ Batch $batch_num completed successfully"
    else
        echo "❌ Batch $batch_num failed. Check log: $log_file"
        exit 1
    fi

    current_pr=$((batch_end + 1))
    batch_num=$((batch_num + 1))

    if [ $current_pr -le $END_PR ]; then
        echo ""
        echo "Batch complete. Waiting $DELAY_BETWEEN_BATCHES seconds before next batch..."
        echo "Next batch will start at PR $current_pr ($(date -v+${DELAY_BETWEEN_BATCHES}S))"
        sleep $DELAY_BETWEEN_BATCHES
    fi
done

echo ""
echo "=========================================="
echo "All batches complete!"
echo "Time: $(date)"
echo "=========================================="

# Count final PRs
echo ""
echo "Counting PRs across all repositories..."
cd ~/wrk/polybase
total=0
for repo in */; do
    repo_name=$(basename "$repo")
    if [ -d "$repo/.git" ]; then
        count=$(gh pr list --repo polybase-poc/$repo_name --state all 2>/dev/null | wc -l | tr -d ' ')
        total=$((total + count))
        if [ "$count" -gt 0 ]; then
            echo "  $repo_name: $count PRs"
        fi
    fi
done
echo "=========================================="
echo "TOTAL: $total PRs created"
echo "Target: 95+ PRs"
echo "=========================================="
