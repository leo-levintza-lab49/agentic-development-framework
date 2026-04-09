# PR History Generation Script

## Overview

The `generate-pr-history.sh` script orchestrates the complete PR creation process across multiple repositories, creating realistic PR history with proper dependencies, timestamps, and code generation.

## Features

- **Dependency-Aware**: Automatically resolves PR dependencies and generates them in the correct order
- **Parallel Execution**: Optional parallel generation where dependencies allow
- **Resume Capability**: Can resume from a specific PR ID after failures
- **Dry-Run Mode**: Preview what will be created without making changes
- **Realistic Code Generation**: Uses templates to generate actual code files
- **Proper Timestamps**: Commits and PRs are created with specified timestamps
- **Progress Tracking**: Real-time progress indicators and detailed logging
- **Error Handling**: Comprehensive error checking with rollback capabilities

## Prerequisites

### Required Tools

- **GitHub CLI (`gh`)**: Version 2.0+
  ```bash
  brew install gh
  gh auth login
  ```

- **Git**: Version 2.30+
  ```bash
  brew install git
  ```

- **jq**: JSON processor
  ```bash
  brew install jq
  ```

- **yq** (optional but recommended): YAML processor
  ```bash
  brew install yq
  ```

### Environment Variables

```bash
# Required
export GITHUB_TOKEN="your-github-token"

# Optional (defaults provided)
export POLYBASE_LOCAL_DIR="$HOME/wrk/polybase"
export OMNIBASE_LOCAL_DIR="$HOME/wrk/omnybase"
```

### Repository Structure

Your local workspace should have:

```
~/wrk/
├── polybase/              # Multi-repo organization
│   ├── db-schemas/
│   ├── user-service/
│   ├── web-app/
│   └── ...
└── omnybase/              # Monorepo organization
    └── enterprise-monorepo/
```

## Usage

### Basic Usage

```bash
# Generate all PRs for both organizations
./scripts/generate-pr-history.sh

# Generate PRs for specific organization
./scripts/generate-pr-history.sh --org polybase-poc

# Generate PRs for monorepo
./scripts/generate-pr-history.sh --org omnibase-poc
```

### Advanced Options

```bash
# Dry run (preview without creating)
./scripts/generate-pr-history.sh --dry-run

# Resume from specific PR ID
./scripts/generate-pr-history.sh --resume-from 25

# Parallel execution (faster but less realistic timeline)
./scripts/generate-pr-history.sh --parallel --org polybase-poc

# Create PRs but don't merge them
./scripts/generate-pr-history.sh --skip-merge

# Custom configuration directory
./scripts/generate-pr-history.sh --config-dir /path/to/config

# Custom log file
./scripts/generate-pr-history.sh --log-file /path/to/logfile.log
```

### Command-Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `--dry-run` | Preview without creating PRs | false |
| `--resume-from ID` | Resume from specific PR ID | none |
| `--config-dir DIR` | Directory with PR YAML files | `../config` |
| `--log-file FILE` | Log file path | `../logs/pr-generation.log` |
| `--parallel` | Generate PRs in parallel | false |
| `--org ORG` | Target organization | all |
| `--skip-merge` | Create PRs but don't merge | false |
| `--help` | Show help message | - |

## Configuration Files

### PR Definition YAML Structure

The script reads PR definitions from YAML files in the config directory:

```yaml
metadata:
  phase: foundation
  month: 1-2
  start_date: "2025-10-07"
  end_date: "2025-11-28"
  total_prs: 28

prs:
  - id: 1
    repo: db-schemas
    team: data-platform
    branch: schema/v1.0.0/user-table
    title: "Add user schema with audit fields"
    description: |
      Creates the foundational user table with:
      - Standard user fields
      - Audit columns
      - Soft delete support
    files:
      - schemas/users.sql
      - migrations/001_create_users_table.sql
      - docs/schema-users.md
    dependencies: []
    complexity: mid-level
    created: "2025-10-07T09:00:00Z"
    review_hours: 6
```

### Configuration File Discovery

The script automatically loads:

- **Multi-repo**: `pr-definitions-month*.yaml`
- **Monorepo**: `monorepo-pr-definitions.yaml`

## Workflow

### 1. Initialization

```
✓ Validate prerequisites (gh, git, jq)
✓ Check GitHub authentication
✓ Verify config directory exists
✓ Create log directory
```

### 2. Loading Configuration

```
✓ Parse YAML files
✓ Load PR definitions
✓ Count total PRs
✓ Store in memory structures
```

### 3. Dependency Resolution

```
✓ Build dependency graph
✓ Detect circular dependencies
✓ Topological sort
✓ Calculate execution order
```

### 4. PR Generation (for each PR)

```
1. Check dependencies are met
2. Create feature branch
3. Generate code files from templates
4. Stage files
5. Create commit with timestamp
6. Push branch to remote
7. Create PR via gh CLI
8. Simulate review time (optional)
9. Merge PR
10. Update progress
```

### 5. Completion

```
✓ Print summary report
✓ List created PRs
✓ Show failed PRs (if any)
✓ Save detailed log
```

## Output

### Console Output

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           PR HISTORY GENERATION                           ║
║                                                           ║
║  Orchestrating realistic PR history across repositories  ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

==== Validating Prerequisites ====

ℹ Checking required tools...
✓ All required tools are installed
✓ All prerequisites validated

==== Loading PR Definitions ====

ℹ Found 4 YAML files to process
ℹ Loading: pr-definitions-month1-2.yaml
✓ Loaded 28 PRs from pr-definitions-month1-2.yaml
✓ Total PRs loaded: 132

==== Building Dependency Graph ====

ℹ Registered PR 1: Add user schema with audit fields (deps: none)
ℹ Registered PR 2: Add order schema (deps: 1)
✓ No circular dependencies found

==== Generating PRs Sequentially ====

Progress: [====================] 100% (132/132)

==== PR Generation Summary ====

Total PRs: 132
Completed: 132
Failed: 0

✓ Successfully generated 132 PRs

Sample PRs Created:
  PR 1: Add user schema with audit fields
          https://github.com/polybase-poc/db-schemas/pull/1
  PR 2: Add order schema with status tracking
          https://github.com/polybase-poc/db-schemas/pull/2
  ...

ℹ Full log available at: /path/to/logs/pr-generation.log
```

### Log File

Detailed log saved to `logs/pr-generation.log`:

```
[2025-10-07T09:00:00Z] PR Generation Started
[2025-10-07T09:00:01Z] Loaded 28 PRs from pr-definitions-month1-2.yaml
[2025-10-07T09:00:05Z] Created PR 1: https://github.com/.../pull/1
[2025-10-07T09:00:10Z] Merged PR 1: #1
...
[2025-10-07T10:30:00Z] PR Generation Completed
```

## Error Handling

### Common Errors and Solutions

#### 1. GitHub Authentication Failed

```bash
Error: GitHub CLI not authenticated
Solution: Run 'gh auth login'
```

#### 2. Repository Not Found

```bash
Error: Repository not found: /path/to/repo
Solution: Ensure repositories are cloned locally
```

#### 3. Circular Dependencies

```bash
Error: Circular dependencies detected in PR chain
Solution: Review PR definitions and fix dependency loops
```

#### 4. Merge Conflict

```bash
Error: Failed to merge PR #42
Solution: Manually resolve conflicts and resume with --resume-from 43
```

### Recovery from Failures

If the script fails mid-execution:

```bash
# Resume from the failed PR
./scripts/generate-pr-history.sh --resume-from 42

# Or skip the problematic PR and continue
# Edit the YAML to remove or fix PR 42, then:
./scripts/generate-pr-history.sh --resume-from 43
```

## Performance

### Sequential Mode (Default)

- **Duration**: ~2-3 minutes per PR
- **Timeline**: Realistic (respects dependencies)
- **Resource Usage**: Low
- **Recommended For**: Production, realistic history

### Parallel Mode

- **Duration**: ~30-60 seconds per batch
- **Timeline**: Compressed
- **Resource Usage**: Medium-High
- **Recommended For**: Testing, quick setup

```bash
# Enable parallel mode
./scripts/generate-pr-history.sh --parallel
```

## Customization

### Adding Custom Templates

Add templates to `templates/code-generation/`:

```bash
templates/code-generation/
├── java-spring-boot/
│   ├── controller.java.template
│   └── service.java.template
├── nodejs-typescript/
│   └── service.ts.template
└── database/
    └── schema.sql.template
```

### Modifying PR Definitions

Edit YAML files in `config/`:

```bash
config/
├── pr-definitions-month1-2.yaml
├── pr-definitions-month3-4.yaml
└── monorepo-pr-definitions.yaml
```

## Testing

### Dry Run

Always test with dry-run first:

```bash
./scripts/generate-pr-history.sh --dry-run --org polybase-poc
```

### Validate Configuration

```bash
# Validate YAML files
yq eval . config/pr-definitions-month1-2.yaml

# Check for circular dependencies
./scripts/lib/dependency-resolver.sh --validate config/
```

## Maintenance

### Logs

Logs are stored in `logs/pr-generation.log`:

```bash
# View recent logs
tail -f logs/pr-generation.log

# Search for errors
grep -i error logs/pr-generation.log

# Archive old logs
mv logs/pr-generation.log logs/pr-generation-$(date +%Y%m%d).log
```

### Cleanup

```bash
# Remove local branches created
cd ~/wrk/polybase/db-schemas
git branch | grep -v main | xargs git branch -D

# Reset repository to main
git checkout main
git pull origin main
```

## Troubleshooting

### Debug Mode

Enable verbose logging:

```bash
export DEBUG=1
./scripts/generate-pr-history.sh
```

### Check Dependencies

```bash
# Verify all tools are installed
./scripts/generate-pr-history.sh --help

# Check GitHub authentication
gh auth status

# Verify repository access
gh repo list polybase-poc
```

### Manual PR Creation

If automation fails, create PRs manually:

```bash
cd ~/wrk/polybase/db-schemas
git checkout -b test-branch
# Make changes
git add .
git commit -m "Test commit"
git push -u origin test-branch
gh pr create --title "Test PR" --body "Description"
```

## Best Practices

1. **Always use dry-run first** to preview changes
2. **Test on a single repository** before running on all
3. **Monitor GitHub rate limits** during execution
4. **Keep logs** for audit trail
5. **Use resume capability** for long-running operations
6. **Review generated code** before merging to main
7. **Backup configuration** before making changes

## Examples

### Example 1: Generate First Month of PRs

```bash
# Dry run first
./scripts/generate-pr-history.sh --dry-run --org polybase-poc

# Review output, then execute
./scripts/generate-pr-history.sh --org polybase-poc

# Monitor progress
tail -f logs/pr-generation.log
```

### Example 2: Resume After Failure

```bash
# Initial run fails at PR 25
./scripts/generate-pr-history.sh --org polybase-poc

# Fix the issue, then resume
./scripts/generate-pr-history.sh --org polybase-poc --resume-from 25
```

### Example 3: Fast Testing Setup

```bash
# Create PRs quickly without merging
./scripts/generate-pr-history.sh \
  --parallel \
  --skip-merge \
  --org polybase-poc
```

## Support

For issues or questions:

1. Check the [troubleshooting](#troubleshooting) section
2. Review logs in `logs/pr-generation.log`
3. Consult the [YAML configuration](#configuration-files) documentation
4. Check the [error handling](#error-handling) section

## License

This script is part of the first-agentic-ai project.
