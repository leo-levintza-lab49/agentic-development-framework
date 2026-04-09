# Skill: Roadmap Sync

## Metadata
- **Name**: roadmap-sync
- **Aliases**: sync-roadmap, update-roadmap
- **Category**: Project Management
- **Team**: Platform SRE

## Description

Update GitHub Projects roadmaps based on current work progress across repositories. Scans completed work, updates status, and generates progress reports.

## How It Works

1. Parses command arguments (org name or "all")
2. Invokes roadmap-update agent with target org
3. Agent scans repositories for completed work
4. Agent updates GitHub Project items
5. Agent generates progress report

## Usage

### Syntax

```
/roadmap-sync [org] [options]
```

### Parameters

- `org`: Organization name (polybase-poc, omnibase-poc, or "all")
- `--project`: Specific project number (overrides auto-detect)
- `--days`: Time window for updates (default: 7)
- `--report-only`: Generate report without updating

### Examples

**Sync specific organization**:
```
/roadmap-sync polybase-poc
```

**Sync all organizations**:
```
/roadmap-sync all
```

**Custom time window**:
```
/roadmap-sync polybase-poc --days 30
```

**Report only (no updates)**:
```
/roadmap-sync polybase-poc --report-only
```

**Specific project**:
```
/roadmap-sync polybase-poc --project 1
```

## Prerequisites

- GitHub CLI (`gh`) must be authenticated
- User must have write access to GitHub Projects
- Organizations must have GitHub Projects set up

## Validation Rules

- Organization must exist
- Project must be accessible
- User must have appropriate permissions

## Expected Outcomes

**Success**:
```
📊 Roadmap Update Summary

Organization: polybase-poc
Project: Polybase Multi-Repo Development Roadmap
Updated: 2026-04-09 17:30:00

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 Progress (Last 7 Days)

Completed Items: 27
├─ Backend: 12
├─ BFF: 5
├─ Frontend: 6
├─ Mobile: 3
└─ Data Platform: 1

Status Distribution:
├─ ✅ Done: 95 (47%)
├─ 🚧 In Progress: 18 (9%)
├─ 📋 Planned: 62 (31%)
└─ 📦 Backlog: 27 (13%)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Recent Completions

✓ user-service: Add health endpoint (2026-04-09)
✓ auth-service: Implement JWT refresh (2026-04-08)
✓ web-app: Update dashboard UI (2026-04-07)
[... 24 more]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  Attention Needed

Stale Items (No activity >7 days): 5
├─ order-service: Payment integration (14 days)
├─ mobile-bff: GraphQL schema update (10 days)
└─ [3 more...]

Missing Completion Dates: 2
Unassigned Items: 8

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 Timeline Health

Current Phase: Feature Development
On Track: Yes ✓
Estimated Completion: 2026-06-30

Timeline looks healthy. 47% complete with 3 months remaining.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔗 Project URL
https://github.com/orgs/polybase-poc/projects/1
```

**Multi-org sync**:
```
📊 Multi-Organization Sync Complete

Organizations Synced: 2/2

✓ polybase-poc: 27 items updated
✓ omnibase-poc: 19 items updated

Total Updates: 46
Total Time: 1m 23s

View Projects:
- https://github.com/orgs/polybase-poc/projects/1
- https://github.com/orgs/omnibase-poc/projects/1
```

## Error Handling

- **Project not found**: Lists available projects and suggests selection
- **Rate limiting**: Automatically waits and retries
- **Permission denied**: Reports access issue with troubleshooting
- **Partial failure**: Completes successful updates, reports failures

## Tips

💡 **Daily sync**: Run daily to keep roadmaps current

💡 **After bulk work**: Run after completing multiple tasks/PRs

💡 **Report first**: Use `--report-only` to preview before updating

💡 **Team dashboards**: Share reports with teams for visibility

💡 **Automate**: Schedule via cron or CI/CD for hands-free updates

## Related Skills

- `/issue-sync` - Sync individual tasks to GitHub Issues
- `/agent-handoff` - Create handoff for blocked work

## Implementation

This skill invokes the `roadmap-update` agent:

```javascript
Agent({
  name: "roadmap-updater",
  subagent_type: "roadmap-update",
  prompt: `Update GitHub Projects roadmap for ${org}.

Parameters:
- Organization: ${org || 'auto-detect'}
- Project: ${project || 'auto-detect'}
- Time window: ${days || 7} days
- Report only: ${reportOnly || false}

Scan repositories for completed work.
Update project items (status, dates, teams).
Generate comprehensive progress report.`
})
```

## Maintenance

This skill is maintained by the Platform SRE team and uses:
- roadmap-update agent (Sonnet)
- GitHub CLI (`gh`)
- GitHub Projects API

## Performance

Target performance:
- Single org (100 items): ~30 seconds
- Multi org (200 items): ~1 minute
- Report generation: ~5 seconds

---

**Version**: 1.0  
**Last Updated**: 2026-04-09  
**Maintained By**: Platform SRE Team
