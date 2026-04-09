# GitHub Integration Guide

Complete guide to using GitHub Projects, Issues, and Roadmaps with the Agentic Development Framework.

## Overview

This framework uses GitHub as the central coordination platform for:
- **Issue Tracking**: Claude Code tasks → GitHub Issues
- **Project Management**: GitHub Projects with roadmap views
- **Agent Collaboration**: Issues as handoff mechanism
- **Progress Visibility**: Real-time status in Projects

## GitHub Projects Structure

### polybase-poc Organization

**Project**: "Polybase Multi-Repo Development Roadmap"

**Repositories** (19 total):
- 5 Java services (user, auth, order, payment, notification)
- 4 Node.js services (web-bff, mobile-bff, graphql-gateway, mobile-shared)
- 2 React apps (web-app, component-library)
- 3 Mobile apps (ios-app, android-app, mobile-shared)
- 3 Infrastructure repos (terraform, grafana, prometheus)
- 2 Database repos (db-schemas, db-migrations)

**Columns**:
1. **Backlog** - Future work not yet prioritized
2. **Planned** - Work scheduled for upcoming phases
3. **In Progress** - Currently being worked on
4. **In Review** - PR created, awaiting review
5. **Done** - Completed and merged

**Custom Fields**:
- **Team**: Backend, BFF, Frontend, Mobile, Data Platform, Platform SRE
- **Repository**: Which repository the work is in
- **Phase**: Foundation, Feature Development, Advanced Features
- **Completion Date**: When the work was completed

**Views**:
- **Roadmap View**: Timeline showing October 2025 - April 2026
- **Team View**: Grouped by Team field
- **Repository View**: Grouped by Repository field
- **Status Board**: Traditional Kanban board

### omnibase-poc Organization

**Project**: "Omnibase Enterprise Monorepo Roadmap"

**Repository**: 1 monorepo (enterprise-monorepo) with 19 services

**Columns**: Same as polybase-poc

**Custom Fields**:
- **Team**: Same 6 teams
- **Service**: Which service within the monorepo
- **Phase**: Foundation, Service Generation, Advanced Features
- **Completion Date**: When completed

**Views**:
- **Roadmap View**: Timeline view
- **Team View**: Grouped by Team
- **Service Type View**: Grouped by technology (Java, Node, React, Mobile, etc.)

## Working with GitHub Issues

### Issue Labels

All issues use consistent labels:

**Type Labels**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `chore`: Maintenance/tooling
- `refactor`: Code refactoring
- `test`: Testing

**Team Labels**:
- `backend`: Backend team
- `bff`: BFF team
- `frontend`: Frontend team
- `mobile`: Mobile team
- `data-platform`: Data Platform team
- `platform-sre`: Platform SRE team

**Status Labels**:
- `claude-task`: Synced from Claude Code
- `handoff`: Agent handoff issue
- `completed`: Closed issue (historical)
- `blocked`: Work is blocked

**Phase Labels**:
- `foundation`: Foundation phase work
- `feature-dev`: Feature development phase
- `advanced`: Advanced features phase

### Creating Issues Manually

```bash
gh issue create \
  --repo polybase-poc/user-service \
  --title "Add health check endpoint" \
  --body "Implement /health endpoint for k8s readiness checks" \
  --label "feat,backend" \
  --assignee @me \
  --project "Polybase Multi-Repo Development Roadmap"
```

### Finding Issues

**All open issues in a repo**:
```bash
gh issue list --repo polybase-poc/user-service
```

**Filter by label**:
```bash
gh issue list --repo polybase-poc/user-service --label "backend"
```

**Search across organization**:
```bash
gh issue list --search "org:polybase-poc is:open label:handoff"
```

**Find Claude-synced tasks**:
```bash
gh issue list --repo polybase-poc/user-service --label "claude-task"
```

## Agent-Based Workflows

### Pattern 1: Automatic Task Sync

When you complete a task in Claude Code, automatically sync it to GitHub:

**Enable automatic sync** (add to `.claude/settings.json`):
```json
{
  "hooks": {
    "TaskCompleted": [{
      "type": "agent",
      "agent": "issue-sync",
      "params": {
        "taskId": "$TASK_ID"
      }
    }]
  }
}
```

**Or sync manually**:
```
/issue-sync 5
```

**Result**: GitHub Issue created and added to Project.

### Pattern 2: Daily Roadmap Updates

Keep GitHub Projects current with daily updates:

**Manual sync**:
```
/roadmap-sync polybase-poc
```

**Scheduled sync** (add to cron or CI/CD):
```bash
#!/bin/bash
# Daily at 6 AM
0 6 * * * cd ~/wrk/agentic-development-framework && claude code --run "/roadmap-sync all"
```

**Result**: All completed work moved to "Done" with completion dates.

### Pattern 3: Agent Handoff

When handing work to another agent:

```
/agent-handoff "Complete authentication tests" --to backend --priority high
```

**What happens**:
1. Handoff issue created with full context
2. Issue labeled with team and "handoff"
3. Issue added to Project in "Planned" status
4. Target team can find via: `is:open label:handoff label:backend`

**Receiving agent**:
```bash
# Find handoff issues
gh issue list --label "handoff,backend" --assignee @me

# Review and accept
gh issue view 142

# Start work
cd ~/wrk/polybase/user-service
git checkout -b feature/auth-tests
# ... do work ...

# Update progress
gh issue comment 142 --body "✅ 50% complete. Unit tests done, integration tests in progress."

# Complete handoff
gh issue close 142 --comment "✅ All authentication tests complete. Coverage: 92%"
```

### Pattern 4: Bulk Work Sync

After completing multiple tasks:

```
/issue-sync all
```

This creates issues for all unsynced tasks in your session.

Then update the roadmap:

```
/roadmap-sync polybase-poc
```

## Working with GitHub Projects

### View Projects

**Via GitHub CLI**:
```bash
gh project list --owner polybase-poc
```

**Via Web**:
- polybase-poc: https://github.com/orgs/polybase-poc/projects/1
- omnibase-poc: https://github.com/orgs/omnibase-poc/projects/1

### Add Issue to Project

```bash
gh project item-add 1 \
  --owner polybase-poc \
  --url https://github.com/polybase-poc/user-service/issues/42
```

### Update Item Status

```bash
# Move to "In Progress"
gh project item-edit \
  --id ITEM_ID \
  --project-id PROJECT_ID \
  --field-id STATUS_FIELD_ID \
  --single-select-option-id IN_PROGRESS_OPTION_ID
```

**Note**: The agents handle this automatically. You rarely need to do it manually.

### Query Project Items

```bash
gh project item-list 1 \
  --owner polybase-poc \
  --format json \
  --limit 100 \
  | jq '.items[] | select(.status=="In Progress")'
```

## Roadmap Timeline Views

### Viewing Timeline

1. Navigate to project: https://github.com/orgs/polybase-poc/projects/1
2. Click "Roadmap" view (or create one)
3. Set date range: October 2025 - April 2026

### Timeline Features

**Milestones**:
- Foundation Phase: October 2025 - December 2025
- Feature Development: January 2026 - March 2026
- Advanced Features: April 2026 - June 2026

**Grouping**:
- By Team: See each team's workload
- By Phase: See progress through phases
- By Repository: See per-repo progress

**Filtering**:
- Status: Show only "In Progress" or "Done"
- Team: Focus on specific team
- Date range: Current month, quarter, etc.

## Advanced Features

### Automated Issue Creation for Historical Work

Create closed issues for past work (preserves history):

```bash
# See scripts/create-historical-issues.sh in plan
# Creates 127 closed issues with proper dates for:
# - 95 multi-repo PRs
# - 19 monorepo services
# - 13 framework enhancements
```

### Issue Templates

Repositories can have issue templates:

```markdown
<!-- .github/ISSUE_TEMPLATE/feature.md -->
---
name: Feature Request
about: Suggest a new feature
labels: feat
---

## Feature Description
[Clear description]

## Use Case
[Why is this needed?]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Technical Notes
[Any technical considerations]
```

### Project Automation

GitHub Projects supports automation rules:

**Auto-move to "In Progress"**:
- When PR linked to issue is opened
- When issue assigned to someone

**Auto-move to "In Review"**:
- When PR is marked ready for review

**Auto-move to "Done"**:
- When PR is merged
- When issue is closed

**Auto-set fields**:
- Set completion date when closed
- Set team from labels

## Integration with CI/CD

### Update Roadmap from CI/CD

Add to `.github/workflows/update-roadmap.yml`:

```yaml
name: Update Roadmap

on:
  schedule:
    - cron: '0 6 * * *'  # Daily at 6 AM
  workflow_dispatch:       # Manual trigger

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Update Roadmap
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          cd ~/agentic-development-framework
          claude code --run "/roadmap-sync polybase-poc"
```

### Create Issue on Deployment

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      # ... deployment steps ...
      
      - name: Record Deployment
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh issue create \
            --repo polybase-poc/user-service \
            --title "Deployment: ${{ github.sha }}" \
            --body "Deployed ${{ github.sha }} to production" \
            --label "deployment,completed"
```

## Best Practices

### For Agents

✅ **Always sync work to GitHub**: Use `/issue-sync` or automatic hooks

✅ **Create detailed handoffs**: Include full context for next agent

✅ **Update progress**: Comment on issues as work progresses

✅ **Close with summaries**: Add completion notes when closing issues

✅ **Link related items**: Connect issues to PRs, docs, designs

### For Humans

✅ **Review auto-generated issues**: Agents are good but not perfect

✅ **Maintain Projects**: Keep views organized and useful

✅ **Use filters effectively**: Find relevant work quickly

✅ **Leverage timeline views**: Visualize roadmap and progress

✅ **Set clear acceptance criteria**: Help agents know when done

### For Teams

✅ **Define label conventions**: Consistent labeling across org

✅ **Create team dashboards**: Filtered views per team

✅ **Regular roadmap reviews**: Weekly check on progress

✅ **Automate where possible**: Hooks, CI/CD, scheduled syncs

✅ **Document processes**: How team uses Issues/Projects

## Troubleshooting

### Issue Not Appearing in Project

**Check**:
```bash
# Is issue in project?
gh project item-list 1 --owner polybase-poc | grep "#42"

# Add manually if needed
gh project item-add 1 --owner polybase-poc --url ISSUE_URL
```

### Roadmap Update Failing

**Check authentication**:
```bash
gh auth status
```

**Check permissions**:
```bash
gh repo view polybase-poc/user-service
```

**Check rate limits**:
```bash
gh api rate_limit
```

### Duplicate Issues Created

**Find duplicates**:
```bash
gh issue list --label "claude-task" --search "Task #5"
```

**Close duplicates**:
```bash
gh issue close DUPLICATE_NUMBER --comment "Duplicate of #ORIGINAL_NUMBER"
```

### Project Fields Not Updating

**List available fields**:
```bash
gh project field-list 1 --owner polybase-poc
```

**Verify field IDs** in agent configuration match actual Project field IDs.

## Reference

### GitHub CLI Commands

```bash
# Issues
gh issue list [--repo ORG/REPO] [--label LABEL] [--assignee USER]
gh issue view NUMBER [--repo ORG/REPO]
gh issue create --repo ORG/REPO --title "..." --body "..." --label "..."
gh issue close NUMBER --comment "..."
gh issue comment NUMBER --body "..."

# Projects
gh project list --owner ORG
gh project view NUMBER --owner ORG
gh project item-list NUMBER --owner ORG
gh project item-add NUMBER --owner ORG --url ISSUE_URL
gh project item-edit --id ID --field "..." --option "..."

# Pull Requests
gh pr list [--repo ORG/REPO] [--state merged]
gh pr view NUMBER
gh pr create --title "..." --body "..." --label "..."
```

### API Endpoints

If you need to use the REST API directly:

```bash
# List issues
gh api repos/polybase-poc/user-service/issues

# Get project
gh api orgs/polybase-poc/projects

# Update project item
gh api graphql -f query='...'
```

## Further Reading

- **GitHub Projects Documentation**: https://docs.github.com/en/issues/planning-and-tracking-with-projects
- **GitHub Issues Guide**: https://docs.github.com/en/issues
- **GitHub CLI Manual**: https://cli.github.com/manual/
- **GraphQL API**: https://docs.github.com/en/graphql

---

**Ready to orchestrate enterprise development through GitHub!** 🚀

---

**Version**: 1.0  
**Last Updated**: 2026-04-09  
**Maintained By**: Platform SRE Team
