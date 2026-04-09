#!/usr/bin/env bash
#
# Check Documentation Freshness
#
# This script is called by the SessionStart hook to check if documentation
# is up-to-date with recent code changes.
#

set -eo pipefail

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Check if docs directory exists
if [[ ! -d "$REPO_ROOT/docs" ]]; then
    echo "ℹ️  No docs/ directory found. Run /doc-generate to create documentation."
    exit 0
fi

# Check when docs were last updated
DOC_LAST_UPDATE=$(git log -1 --format=%ct -- "$REPO_ROOT/docs" "$REPO_ROOT/README.md" 2>/dev/null || echo "0")
CODE_LAST_UPDATE=$(git log -1 --format=%ct -- "$REPO_ROOT" ':(exclude)docs' ':(exclude)README.md' 2>/dev/null || echo "0")

# If docs have never been updated
if [[ "$DOC_LAST_UPDATE" == "0" ]]; then
    echo "⚠️  Documentation exists but has no git history."
    exit 0
fi

# Calculate age difference in days
AGE_DIFF=$(( (CODE_LAST_UPDATE - DOC_LAST_UPDATE) / 86400 ))

if [[ $AGE_DIFF -gt 7 ]]; then
    echo "⚠️  Documentation may be stale (code updated $AGE_DIFF days after docs)."
    echo "   Consider running: /doc-update"
elif [[ $AGE_DIFF -gt 3 ]]; then
    echo "ℹ️  Documentation was last updated $AGE_DIFF days ago."
elif [[ $AGE_DIFF -eq 0 ]]; then
    echo "✅ Documentation appears up-to-date."
else
    echo "✅ Documentation is fresh (updated $AGE_DIFF days ago)."
fi

# Check for README
if [[ ! -f "$REPO_ROOT/README.md" ]]; then
    echo "⚠️  No README.md found. Run /doc-generate to create it."
fi

# Check for essential docs
ESSENTIAL_DOCS=("ARCHITECTURE.md" "SETUP.md")
MISSING_DOCS=()

for doc in "${ESSENTIAL_DOCS[@]}"; do
    if [[ ! -f "$REPO_ROOT/docs/$doc" ]]; then
        MISSING_DOCS+=("$doc")
    fi
done

if [[ ${#MISSING_DOCS[@]} -gt 0 ]]; then
    echo "ℹ️  Missing recommended docs: ${MISSING_DOCS[*]}"
    echo "   Run: /doc-generate to create them."
fi

exit 0
