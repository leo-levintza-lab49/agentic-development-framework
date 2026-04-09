# Quick Start Guide

Get started with the Agentic Development Framework in 5 minutes.

## Prerequisites

- **Git**: Version 2.x or higher
- **GitHub CLI**: `gh` authenticated with your account
- **Claude Code**: Installed and configured
- **Direnv** (optional): For automatic environment loading

## Step 1: Clone the Framework

```bash
cd ~/wrk
git clone https://github.com/leo-levintza-lab49/agentic-development-framework.git
cd agentic-development-framework
```

## Step 2: Configure Environment

Create your environment file:

```bash
cp .env.template .env
cp .envrc.template .envrc
```

Edit `.env` with your settings:

```bash
# Required: GitHub authentication
GITHUB_AUTH_TOKEN=ghp_your_token_here
ORG_ADMIN_PAT=ghp_your_org_admin_token_here

# Required: Organization names
MONOREPO_ORG=omnibase-poc
MULTIREPO_ORG=polybase-poc

# Optional: Customize paths
SRE_TOOLS=/path/to/your/sre-tools
```

Load environment:

```bash
# With direnv (automatic)
direnv allow

# Or manually
source .envrc
```

## Step 3: Verify Setup

Check GitHub authentication:

```bash
gh auth status
```

Expected output:
```
✓ Logged in to github.com account your-username
✓ Token scopes: 'repo', 'workflow', ...
```

Check organizations:

```bash
gh repo list polybase-poc --limit 5
gh repo list omnibase-poc --limit 5
```

## Step 4: Explore Available Commands

### Infrastructure Scripts

```bash
# Set up complete GitHub infrastructure
./scripts/setup-github-infrastructure.sh

# Generate service in multi-repo
./scripts/lib/repo-creation.sh create polybase-poc user-service java-service backend

# Generate service in monorepo
./scripts/generate-monorepo-service.sh backend user-service java

# Create historical GitHub issues (one-time migration)
./scripts/create-historical-issues.sh

# Dry run to preview (recommended first)
DRY_RUN=true ./scripts/create-historical-issues.sh
```

### Claude Code Skills

Launch Claude Code in any repository:

```bash
cd ~/wrk/polybase/user-service
claude code
```

Then use these skills:

```
/doc-generate        # Generate comprehensive documentation
/doc-update          # Update existing documentation
/doc-check           # Check documentation freshness

/issue-sync [task]   # Sync task to GitHub Issue
/roadmap-sync [org]  # Update GitHub Projects roadmap
/agent-handoff       # Create handoff for next agent
```

## Step 5: Try an Example

### Example 1: Generate Documentation

```bash
cd ~/wrk/polybase/user-service
claude code
```

In Claude Code:
```
/doc-generate user-service --dry-run
```

Review the analysis, then generate for real:
```
/doc-generate user-service
```

### Example 2: Sync Work to GitHub

After completing tasks in Claude Code:
```
/issue-sync all
```

This creates GitHub Issues for all your work.

### Example 3: Update Roadmap

```
/roadmap-sync polybase-poc
```

This scans all repositories and updates the GitHub Project roadmap.

## Common Workflows

### Starting a New Service

```bash
# Multi-repo approach
cd ~/wrk/agentic-development-framework
./scripts/lib/repo-creation.sh create polybase-poc new-service node-service backend

# Monorepo approach
./scripts/generate-monorepo-service.sh backend new-service nodejs
```

### Daily Development

1. Navigate to service: `cd ~/wrk/polybase/user-service`
2. Start Claude Code: `claude code`
3. Work on features
4. Sync progress: `/issue-sync all`
5. Update roadmap: `/roadmap-sync polybase-poc`

### Agent Handoff

When handing work to another agent:

```
/agent-handoff "Complete authentication tests" --to backend
```

## Directory Structure

```
agentic-development-framework/
├── scripts/              # Infrastructure automation
│   ├── *.sh             # Main orchestration scripts
│   └── lib/             # Reusable library functions
├── templates/           # Service scaffolding templates
│   ├── common/          # Shared configurations
│   ├── team-configs/    # Team-specific configs
│   └── technology/      # Tech stack templates
├── config/              # Metadata (CSV, YAML)
├── .claude/             # Claude Code configuration
│   ├── agents/          # 6 specialized agents
│   ├── skills/          # 6 reusable skills
│   └── scripts/         # Hook scripts
└── docs/                # Framework documentation
```

## Key Configuration Files

### Framework Level

- **config/repositories.csv**: List of all repositories
- **config/teams.csv**: Team definitions and ownership
- **.claude/settings.json**: Claude Code framework settings

### Repository Level

Each repository has:
- `.claude/settings.json`: Repository-specific settings
- `.claude/rules/`: Code quality, security, git workflow rules
- `.github/workflows/`: CI/CD pipelines

## Available Agents

### Documentation Agents

- **doc-writer**: Generate professional markdown documentation
- **doc-architect**: Orchestrate multi-repo documentation generation
- **doc-analyzer**: Deep code analysis with Claude Opus

### GitHub Integration Agents

- **issue-sync**: Sync Claude Code tasks to GitHub Issues
- **roadmap-update**: Update GitHub Projects from work progress
- **agent-handoff**: Create structured handoff issues

## Troubleshooting

### GitHub Authentication Fails

```bash
gh auth login
gh auth refresh
```

### Repository Not Found

```bash
# Verify organization access
gh repo list polybase-poc

# Clone missing repositories
gh repo clone polybase-poc/user-service ~/wrk/polybase/user-service
```

### Claude Code Not Finding Agents

Check `.claude/settings.json` has correct paths:

```json
{
  "agents": {
    "enabled": true,
    "autoDiscover": true,
    "paths": [".claude/agents"]
  }
}
```

### Environment Variables Not Loading

```bash
# Manual load
source .envrc

# Or with direnv
direnv allow
direnv reload
```

## Next Steps

### Learn More

- **[README.md](README.md)**: Framework overview and results
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**: System architecture
- **[docs/SETUP.md](docs/SETUP.md)**: Detailed setup guide
- **[docs/GITHUB_INTEGRATION.md](docs/GITHUB_INTEGRATION.md)**: GitHub Projects integration
- **[docs/AGENT_HANDOFF.md](docs/AGENT_HANDOFF.md)**: Agent collaboration patterns

### Try Advanced Features

1. **Bulk documentation generation**: Document entire organization
2. **Automated PR generation**: Create PRs with historical context
3. **Team-specific workflows**: Customize for each team
4. **Multi-org orchestration**: Work across organizations

### Join the Community

- Report issues: https://github.com/leo-levintza-lab49/agentic-development-framework/issues
- Share feedback: Open a discussion
- Contribute: Fork and submit PRs

---

**Ready to build enterprise-scale systems with Claude Code!** 🚀

---

**Version**: 1.0  
**Last Updated**: 2026-04-09  
**Maintained By**: Platform SRE Team
