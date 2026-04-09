# Quick Start Guide: PR History Generation

## Overview

This guide will help you quickly set up and run the PR history generation script to create realistic PR history across your repositories.

## Prerequisites Check

Run the validation script first:

```bash
cd /Users/leo.levintza/wrk/first-agentic-ai
./scripts/validate-pr-generation.sh
```

This will check:
- ✓ Required tools (gh, git, jq)
- ✓ GitHub authentication
- ✓ Configuration files
- ✓ Repository structure
- ✓ Script syntax

## Quick Setup (5 minutes)

### 1. Install Required Tools

```bash
# GitHub CLI
brew install gh

# jq (JSON processor)
brew install jq

# yq (YAML processor - optional but recommended)
brew install yq

# Authenticate with GitHub
gh auth login
```

### 2. Set Environment Variables

```bash
# Add to your ~/.zshrc or ~/.bashrc
export GITHUB_TOKEN="your-github-token"
export POLYBASE_LOCAL_DIR="$HOME/wrk/polybase"
export OMNIBASE_LOCAL_DIR="$HOME/wrk/omnybase"
```

### 3. Verify Configuration

```bash
# Check that YAML files exist
ls -la config/pr-definitions-*.yaml

# Count total PRs
grep "^  - id:" config/pr-definitions-*.yaml | wc -l
```

## Running the Script

### Option 1: Dry Run (Recommended First)

Preview what will be created without making changes:

```bash
./scripts/generate-pr-history.sh --dry-run --org polybase-poc
```

Review the output to ensure everything looks correct.

### Option 2: Generate PRs for Multi-Repo

Generate all PRs for the polybase-poc organization:

```bash
./scripts/generate-pr-history.sh --org polybase-poc
```

Monitor progress:
```bash
# In another terminal
tail -f logs/pr-generation.log
```

### Option 3: Generate PRs for Monorepo

Generate all PRs for the omnibase-poc organization:

```bash
./scripts/generate-pr-history.sh --org omnibase-poc
```

### Option 4: Fast Testing (Parallel Mode)

For quick testing, use parallel mode:

```bash
./scripts/generate-pr-history.sh --parallel --skip-merge --org polybase-poc
```

This will:
- Generate PRs in parallel where dependencies allow
- Skip the merge step (PRs stay open)
- Complete much faster

## Common Workflows

### Workflow 1: Full Production Run

```bash
# Step 1: Validate
./scripts/validate-pr-generation.sh

# Step 2: Dry run
./scripts/generate-pr-history.sh --dry-run

# Step 3: Execute
./scripts/generate-pr-history.sh

# Step 4: Monitor
tail -f logs/pr-generation.log
```

### Workflow 2: Test Single Organization

```bash
# Test polybase-poc only
./scripts/generate-pr-history.sh --org polybase-poc --skip-merge
```

### Workflow 3: Recovery from Failure

```bash
# If script fails at PR 42
./scripts/generate-pr-history.sh --resume-from 42 --org polybase-poc
```

## Expected Output

### Console Output

```
╔═══════════════════════════════════════════════════════════╗
║           PR HISTORY GENERATION                           ║
╚═══════════════════════════════════════════════════════════╝

==== Validating Prerequisites ====
✓ All prerequisites validated

==== Loading PR Definitions ====
✓ Total PRs loaded: 132

==== Building Dependency Graph ====
✓ No circular dependencies found

==== Generating PRs Sequentially ====
Progress: [====================] 100% (132/132)

==== PR Generation Summary ====
Total PRs: 132
Completed: 132
Failed: 0

✓ Successfully generated 132 PRs
```

### Created PRs

The script will create PRs in your GitHub repositories:
- https://github.com/polybase-poc/db-schemas/pull/1
- https://github.com/polybase-poc/db-schemas/pull/2
- https://github.com/polybase-poc/user-service/pull/1
- ...

### Log File

Detailed log saved to `logs/pr-generation.log`:
```
[2025-10-07T09:00:00Z] PR Generation Started
[2025-10-07T09:00:01Z] Loaded 28 PRs from pr-definitions-month1-2.yaml
[2025-10-07T09:00:05Z] Created PR 1: https://github.com/.../pull/1
...
```

## Time Estimates

| Mode | PRs | Duration | Notes |
|------|-----|----------|-------|
| Sequential | 132 | ~4-6 hours | Realistic timeline, respects dependencies |
| Parallel | 132 | ~1-2 hours | Faster but compressed timeline |
| Dry Run | 132 | ~5 minutes | Preview only, no actual PRs |

## Troubleshooting

### Problem: "GitHub CLI not authenticated"

```bash
# Solution
gh auth login
gh auth status
```

### Problem: "Repository not found"

```bash
# Solution: Clone repositories first
cd ~/wrk/polybase
gh repo clone polybase-poc/db-schemas
gh repo clone polybase-poc/user-service
# ... etc
```

### Problem: "Circular dependency detected"

```bash
# Solution: Check YAML configuration
./scripts/validate-pr-generation.sh
# Review and fix dependency chains in config/*.yaml
```

### Problem: "Failed to merge PR"

```bash
# Solution: Resume from next PR
./scripts/generate-pr-history.sh --resume-from <next-pr-id>
```

## Next Steps

After successful PR generation:

1. **Review Generated PRs**: Check a few PRs to verify quality
   ```bash
   gh pr list --repo polybase-poc/db-schemas
   gh pr view 1 --repo polybase-poc/db-schemas
   ```

2. **Check Repository History**: Verify commit history looks realistic
   ```bash
   cd ~/wrk/polybase/db-schemas
   git log --oneline --graph
   ```

3. **Verify Code Generation**: Review generated code files
   ```bash
   cd ~/wrk/polybase/db-schemas
   cat schemas/users.sql
   ```

4. **Generate Reports**: Create PR summary reports
   ```bash
   gh pr list --repo polybase-poc/db-schemas --state all --json number,title,author,createdAt
   ```

## Advanced Usage

### Custom Configuration Directory

```bash
./scripts/generate-pr-history.sh --config-dir /path/to/custom/config
```

### Custom Log File

```bash
./scripts/generate-pr-history.sh --log-file /path/to/custom.log
```

### Create PRs Without Merging

```bash
./scripts/generate-pr-history.sh --skip-merge
```

This leaves PRs open for manual review and merge.

## Getting Help

### View Full Documentation

```bash
cat scripts/README-PR-GENERATION.md
```

### View Script Help

```bash
./scripts/generate-pr-history.sh --help
```

### Check Logs

```bash
# View recent logs
tail -100 logs/pr-generation.log

# Search for errors
grep -i error logs/pr-generation.log

# View specific PR creation
grep "PR 42" logs/pr-generation.log
```

## Success Indicators

You'll know the script succeeded when you see:

1. ✓ Progress bar reaches 100%
2. ✓ "Successfully generated X PRs" message
3. ✓ No errors in the log file
4. ✓ PRs visible on GitHub
5. ✓ Commit history in repositories

## What Gets Created

For each PR, the script:

1. **Creates a feature branch** with team-specific naming
2. **Generates code files** from templates based on file type
3. **Creates a commit** with proper timestamp and author
4. **Pushes to GitHub** with correct remote tracking
5. **Creates a PR** with title, description, and labels
6. **Merges the PR** (unless --skip-merge is used)
7. **Logs all actions** to log file

## Directory Structure After Generation

```
~/wrk/polybase/
├── db-schemas/
│   ├── schemas/
│   │   ├── users.sql (from PR 1)
│   │   └── orders.sql (from PR 2)
│   └── migrations/
│       ├── 001_create_users_table.sql
│       └── 002_create_orders_table.sql
├── user-service/
│   ├── src/
│   │   └── main/
│   │       └── java/
│   │           └── com/example/
│   │               ├── UserController.java
│   │               └── UserService.java
│   └── pom.xml
└── ...
```

## Best Practices

1. **Always run validation first**: `./scripts/validate-pr-generation.sh`
2. **Use dry-run for testing**: `--dry-run` flag
3. **Monitor logs during execution**: `tail -f logs/pr-generation.log`
4. **Keep backups**: Save logs and configuration
5. **Test on single org first**: Use `--org polybase-poc`
6. **Use resume for long runs**: `--resume-from <id>` if it fails

## Support

- Full documentation: `scripts/README-PR-GENERATION.md`
- Validation script: `scripts/validate-pr-generation.sh`
- Log files: `logs/pr-generation.log`
- Configuration: `config/pr-definitions-*.yaml`

---

**Ready to start?**

```bash
# Run this command to begin
./scripts/validate-pr-generation.sh && \
./scripts/generate-pr-history.sh --dry-run --org polybase-poc
```
