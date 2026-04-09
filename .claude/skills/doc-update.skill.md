# Skill: Update Documentation

## Metadata
- **Name**: doc-update
- **Aliases**: update-docs, refresh-docs
- **Category**: Documentation
- **Team**: All teams

## Description

Update existing documentation based on recent code changes. Performs incremental updates rather than full regeneration, making it faster and more targeted than `/doc-generate`.

## How It Works

1. Identify what code changed recently (git log analysis)
2. Determine which documentation sections are affected
3. Analyze only the changed areas
4. Update relevant documentation sections
5. Create PR with incremental changes

## Usage

### Syntax

```
/doc-update [target] [options]
```

### Parameters

- `target`: Repository name or organization
- `--since <timeframe>`: Look back period (default: 7d)
- `--path <path>`: Only check specific paths
- `--dry-run`: Preview changes without creating PR
- `--section <section>`: Update specific section only

### Examples

**Update docs for user-service based on last 7 days:**
```
/doc-update user-service
```

**Update docs for changes in last 30 days:**
```
/doc-update user-service --since 30d
```

**Update only API documentation:**
```
/doc-update user-service --section api
```

**Update docs for specific path changes:**
```
/doc-update user-service --path src/api/
```

**Update all repos changed recently:**
```
/doc-update polybase-poc --since 7d
```

**Dry run:**
```
/doc-update user-service --dry-run
```

## Prerequisites

- Repository has existing documentation
- Git history is available
- Changes were made in the lookback period

## Validation Rules

- Repository must exist
- Must have git history
- Existing docs must be present (README, docs/)
- If no changes found, skip with message

## Expected Outcomes

**Success (with changes)**:
```
Documentation Update Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository: polybase-poc/user-service
Team: backend
Period: Last 7 days

Recent Changes Detected:
✓ src/main/java/com/example/api/UserController.java
  - Added GET /api/v1/users/search endpoint
  - Modified PUT /api/v1/users/{id} (added validation)
✓ src/main/resources/application.yml
  - Updated database connection pool settings

Affected Documentation:
✓ docs/API.md - New endpoint needs documentation
✓ docs/ARCHITECTURE.md - Configuration changes
✓ README.md - Feature list update

Updates Made:
✓ docs/API.md:
  - Added GET /api/v1/users/search documentation
  - Updated PUT /api/v1/users/{id} request examples
✓ docs/ARCHITECTURE.md:
  - Updated configuration section with new pool settings
✓ README.md:
  - Added user search feature to features list

Pull Request:
✓ Created: https://github.com/polybase-poc/user-service/pull/124
✓ Branch: docs/update-api-20260409
✓ Labels: documentation, automated, backend
✓ Assigned to: @backend-lead

Status: ✅ Complete
```

**Success (no changes needed)**:
```
Documentation Update Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository: polybase-poc/user-service
Period: Last 7 days

No documentation updates required.

Recent Changes Reviewed:
- src/test/java/com/example/UserServiceTest.java (tests only)
- .github/workflows/ci.yml (CI config)

Reason: Changes don't affect public APIs or architecture

Status: ✅ Up to date
```

## Update Logic

The skill determines what to update based on file changes:

| File Pattern | Affects Documentation |
|--------------|----------------------|
| `**/api/**`, `**/controller/**` | docs/API.md |
| `**/service/**`, `**/domain/**` | docs/ARCHITECTURE.md |
| `**/*.yml`, `**/*.yaml`, `**/config/**` | docs/SETUP.md, docs/ARCHITECTURE.md |
| `Dockerfile`, `k8s/**`, `terraform/**` | docs/DEPLOYMENT.md |
| `README.md` changes | May trigger refresh |
| `**/test/**` only | No update needed |

## Implementation Notes

This skill invokes the `doc-architect` agent with update mode:

```javascript
Agent({
  name: "doc-updater",
  subagent_type: "doc-architect",
  prompt: `Update documentation for ${target} based on recent changes.

Parameters:
- Target: ${target}
- Since: ${since}
- Path filter: ${path || 'all'}
- Section: ${section || 'all'}
- Dry run: ${dryRun}

Workflow:
1. Run git log analysis to find changed files
2. Map changes to documentation sections
3. If changes affect docs:
   a. Analyze changed code sections only
   b. Update relevant documentation parts
   c. Create PR with incremental changes
4. If no relevant changes:
   a. Report "No updates needed"
   b. Skip PR creation

Execute incremental documentation update.`
})
```

## Smart Detection

The update process includes intelligent detection:

**API Changes**:
- New endpoints → Add to API.md
- Modified signatures → Update examples
- Deprecated endpoints → Mark as deprecated

**Architecture Changes**:
- New components → Add to component diagram
- Integration changes → Update integration section
- Pattern changes → Update design decisions

**Configuration Changes**:
- New env vars → Update SETUP.md
- Changed defaults → Update configuration docs
- New profiles → Document in deployment guide

## Comparison with /doc-generate

| Feature | /doc-generate | /doc-update |
|---------|---------------|-------------|
| **Speed** | Slower (full analysis) | Faster (targeted) |
| **Scope** | Complete regeneration | Incremental updates |
| **Use Case** | New docs or major rewrites | Routine maintenance |
| **Git Analysis** | No | Yes |
| **Best For** | Initial setup | Continuous updates |

## Tips

💡 **Run after features**: Update docs after merging feature branches

💡 **Automate with hooks**: Use Stop hook to suggest updates

💡 **Review changes**: Check git diff before approving PR

💡 **Combine with CI**: Run in CI after PR merges to main

## Hook Integration

This skill works well with Stop hook:

```json
{
  "hooks": {
    "Stop": [{
      "matcher": "*",
      "hooks": [{
        "type": "prompt",
        "prompt": "Check if code changes in this session affect documentation. If API, architecture, or configuration files were modified, suggest running /doc-update."
      }]
    }]
  }
}
```

## Related Skills

- `/doc-generate` - Full documentation generation
- `/doc-check` - Verify documentation freshness
- `/commit` - Commit changes manually

## Maintenance

This skill is maintained by the Platform SRE team.

---

**Version**: 1.0  
**Last Updated**: 2026-04-09  
**Maintained By**: Platform SRE Team
