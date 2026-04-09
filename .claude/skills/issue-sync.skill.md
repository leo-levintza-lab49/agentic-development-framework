# Skill: Issue Sync

## Metadata
- **Name**: issue-sync
- **Aliases**: sync-issues, sync-task
- **Category**: Project Management
- **Team**: All teams

## Description

Synchronize Claude Code tasks with GitHub Issues to maintain consistent tracking across local work and GitHub Projects.

## How It Works

1. Parses command arguments (task ID or "all")
2. Invokes issue-sync agent with task specification
3. Agent creates/updates GitHub Issue
4. Agent adds issue to GitHub Project
5. Agent reports results

## Usage

### Syntax

```
/issue-sync [task-id|all] [options]
```

### Parameters

- `task-id`: Specific task ID to sync (e.g., "5")
- `all`: Sync all tasks in current session
- `--repo`: Override auto-detected repository
- `--dry-run`: Preview what would be synced without creating issues

### Examples

**Sync specific task**:
```
/issue-sync 5
```

**Sync all tasks**:
```
/issue-sync all
```

**Dry run for preview**:
```
/issue-sync 5 --dry-run
```

**Override repository**:
```
/issue-sync 5 --repo polybase-poc/user-service
```

## Prerequisites

- GitHub CLI (`gh`) must be authenticated
- Current user must have write access to target repository
- Repository must exist and be accessible

## Validation Rules

- Task ID must be valid
- Repository must be detectable or specified
- User must have GitHub permissions

## Expected Outcomes

**Success**:
```
✅ Issue Sync Complete

Task: #5 - Migrate core structure to control repo
Repository: leo-levintza-lab49/agentic-development-framework
Action: Created
Issue: leo-levintza-lab49/agentic-development-framework#12
Project: Added to Agentic Development Framework Roadmap

View: https://github.com/leo-levintza-lab49/agentic-development-framework/issues/12
```

**Multiple tasks**:
```
✅ Batch Sync Complete

Synced: 8/10 tasks
├─ Created: 5 issues
├─ Updated: 2 issues
└─ Skipped: 1 issue (already synced)

Failed: 2 tasks
├─ Task #3: Repository not found
└─ Task #7: Permission denied

Success Rate: 80%
```

## Error Handling

- **Repository not found**: Reports error with suggestion
- **Authentication failure**: Prompts to run `gh auth login`
- **Rate limiting**: Waits and retries automatically
- **Permission denied**: Reports access issue

## Tips

💡 **Auto-sync**: Enable TaskCompleted hook for automatic sync

💡 **Batch sync**: Use `/issue-sync all` at end of session to sync all work

💡 **Dry run first**: Preview with `--dry-run` before creating issues

💡 **Check status**: View synced issues on GitHub Project board

## Related Skills

- `/roadmap-sync` - Update GitHub Projects roadmap
- `/agent-handoff` - Create handoff issue for next agent

## Implementation

This skill invokes the `issue-sync` agent:

```javascript
Agent({
  name: "issue-sync-task",
  subagent_type: "issue-sync",
  prompt: `Sync task(s) to GitHub Issues.

Parameters:
- Task ID: ${taskId || 'all'}
- Repository: ${repo || 'auto-detect'}
- Dry run: ${dryRun || false}

Auto-detect repository from current working directory.
Create or update GitHub Issue for task.
Add issue to GitHub Project if exists.
Report results.`
})
```

## Maintenance

This skill is maintained by the Platform SRE team and uses:
- issue-sync agent (Sonnet)
- GitHub CLI (`gh`)
- Claude Code task system

---

**Version**: 1.0  
**Last Updated**: 2026-04-09  
**Maintained By**: Platform SRE Team
