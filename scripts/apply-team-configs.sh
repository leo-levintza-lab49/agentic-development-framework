#!/bin/bash
set -euo pipefail

# Apply team-specific configurations to a repository
# Usage: ./apply-team-configs.sh <repo_path> <team_name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$PROJECT_ROOT/templates/team-configs"

if [ $# -ne 2 ]; then
    echo "Usage: $0 <repo_path> <team_name>"
    echo "Example: $0 ~/wrk/polybase/user-service backend"
    exit 1
fi

REPO_PATH="$1"
TEAM_NAME="$2"

if [ ! -d "$REPO_PATH" ]; then
    echo "Error: Repository path does not exist: $REPO_PATH"
    exit 1
fi

if [ ! -d "$TEMPLATES_DIR/$TEAM_NAME" ]; then
    echo "Error: Team configuration not found: $TEAM_NAME"
    echo "Available teams: data-platform, backend, bff, frontend, mobile, platform-sre"
    exit 1
fi

echo "========================================="
echo "Applying $TEAM_NAME configuration to:"
echo "  $REPO_PATH"
echo "========================================="

cd "$REPO_PATH"

# 1. Copy CODEOWNERS
echo "→ Copying CODEOWNERS..."
mkdir -p .github
cp "$TEMPLATES_DIR/$TEAM_NAME/.github/CODEOWNERS.template" .github/CODEOWNERS
echo "  ✓ .github/CODEOWNERS created"

# 2. Copy CI workflow
echo "→ Copying CI workflow..."
mkdir -p .github/workflows
WORKFLOW_FILE=$(find "$TEMPLATES_DIR/$TEAM_NAME/.github/workflows" -name "*.yml" -type f | head -n 1)
if [ -n "$WORKFLOW_FILE" ]; then
    cp "$WORKFLOW_FILE" .github/workflows/ci.yml
    echo "  ✓ .github/workflows/ci.yml created"
fi

# 3. Copy Claude rules
echo "→ Copying Claude rules..."
mkdir -p .claude/rules
cp -r "$TEMPLATES_DIR/$TEAM_NAME/.claude/rules/"* .claude/rules/
echo "  ✓ .claude/rules/ populated"

# 4. Copy team guide
echo "→ Copying team guide..."
mkdir -p docs
if [ -f "$TEMPLATES_DIR/$TEAM_NAME/docs/TEAM_GUIDE.md" ]; then
    cp "$TEMPLATES_DIR/$TEAM_NAME/docs/TEAM_GUIDE.md" docs/TEAM_GUIDE.md
    echo "  ✓ docs/TEAM_GUIDE.md created"
fi

# 5. Create initial commit if changes exist
if [ -n "$(git status --porcelain)" ]; then
    echo "→ Committing configuration changes..."
    git add .github .claude docs 2>/dev/null || true
    git commit -m "chore: add $TEAM_NAME team configuration

- Add CODEOWNERS for code review requirements
- Add CI/CD workflow for automated testing
- Add Claude rules for branch naming and commits
- Add team guide documentation

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>" || echo "  ⚠ Nothing to commit or commit failed"
    echo "  ✓ Changes committed"
fi

echo ""
echo "✅ Configuration applied successfully!"
echo ""
