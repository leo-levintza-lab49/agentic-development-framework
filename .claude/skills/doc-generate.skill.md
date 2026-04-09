# Skill: Generate Documentation

## Metadata
- **Name**: doc-generate
- **Aliases**: generate-docs, create-docs
- **Category**: Documentation
- **Team**: All teams

## Description

Generate comprehensive documentation for a repository or organization by analyzing source code and creating professional markdown documentation with diagrams.

## How It Works

1. Parse command arguments (org, repo, or "all")
2. Invoke doc-architect agent with target specification
3. Agent orchestrates:
   - Code analysis (Opus-powered doc-analyzer)
   - Documentation generation (Sonnet-powered doc-writer)
   - PR creation with labels and assignments
4. Report results to user

## Usage

###Syntax

```
/doc-generate [target] [options]
```

### Parameters

- `target`: Organization name, repository name, or "all"
- `--dry-run`: Preview what would be generated without creating PRs
- `--force`: Regenerate even if docs exist
- `--skip-pr`: Generate docs but don't create PR

### Examples

**Generate docs for entire polybase-poc organization:**
```
/doc-generate polybase-poc
```

**Generate docs for single repository:**
```
/doc-generate user-service
```

**Generate docs for omnibase monorepo:**
```
/doc-generate omnibase-poc
```

**Dry run (preview only):**
```
/doc-generate user-service --dry-run
```

**Force regeneration:**
```
/doc-generate user-service --force
```

**Generate without PR:**
```
/doc-generate user-service --skip-pr
```

## Prerequisites

- Git repository must exist locally
- Repository must have code (not empty)
- GitHub CLI (`gh`) must be authenticated
- Current user must have push access to repository

## Validation Rules

- Target repository/org must exist
- Repository must be accessible
- If --dry-run not specified, user must confirm PR creation

## Expected Outcomes

**Success**:
- Analysis report generated
- Documentation files created in docs/ directory
- Mermaid diagrams included where appropriate
- PR created (unless --skip-pr)
- Code owners assigned to PR
- Labels applied (documentation, automated, {team})

**Output**:
```
Documentation Generation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository: polybase-poc/user-service
Team: backend

Analysis Complete:
✓ Architecture pattern identified: Layered (Spring Boot)
✓ 5 components mapped
✓ 3 integration points found
✓ 12 API endpoints discovered

Documentation Generated:
✓ README.md (updated)
✓ docs/ARCHITECTURE.md (created)
✓ docs/API.md (created)
✓ docs/SETUP.md (created)
✓ docs/DEPLOYMENT.md (created)
✓ docs/CONTRIBUTING.md (created)

Diagrams Created:
✓ Architecture overview (Mermaid)
✓ Authentication sequence (Mermaid)
✓ User data model ERD (Mermaid)

Pull Request:
✓ Created: https://github.com/polybase-poc/user-service/pull/123
✓ Branch: docs/automated-20260409-user-service
✓ Labels: documentation, automated, backend
✓ Assigned to: @backend-lead

Status: ✅ Complete
```

**Failure Scenarios**:
- Repository not found → Error with suggestion
- No code in repository → Skip with message
- GitHub API error → Retry then report error
- Merge conflict → Create PR with conflict notice

## Implementation Notes

This skill invokes the `doc-architect` agent:

```javascript
Agent({
  name: "doc-generator",
  subagent_type: "doc-architect",
  prompt: `Generate documentation for ${target}.
  
Parameters:
- Target: ${target}
- Dry run: ${dryRun}
- Force: ${force}
- Skip PR: ${skipPR}

Configuration:
- Config dir: /Users/leo.levintza/wrk/first-agentic-ai/config
- Polybase org: polybase-poc
- Omnibase org: omnibase-poc
- Base dir: /Users/leo.levintza/wrk

Execute the full documentation generation workflow.`
})
```

## Tips

💡 **Start small**: Test on a single repo before running on entire org

💡 **Review PRs**: Always review auto-generated docs before merging

💡 **Update regularly**: Run monthly or after major features

💡 **Team coordination**: Notify teams before generating docs org-wide

## Related Skills

- `/doc-update` - Update existing documentation incrementally
- `/doc-check` - Verify documentation is up-to-date
- `/commit` - Commit documentation changes manually

## Maintenance

This skill is maintained by the Platform SRE team and uses:
- doc-architect agent
- doc-analyzer agent (Opus)
- doc-writer agent (Sonnet)

---

**Version**: 1.0  
**Last Updated**: 2026-04-09  
**Maintained By**: Platform SRE Team
