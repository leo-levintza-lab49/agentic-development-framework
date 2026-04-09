# Skill: Check Documentation

## Metadata
- **Name**: doc-check
- **Aliases**: check-docs, verify-docs, audit-docs
- **Category**: Documentation
- **Team**: All teams

## Description

Verify documentation completeness and freshness by comparing current code structure with existing documentation. Identifies gaps, stale content, and provides coverage metrics.

## How It Works

1. Scan repository for code structure
2. Review existing documentation
3. Compare code vs docs:
   - Missing documentation
   - Stale sections (code changed, docs didn't)
   - Orphaned docs (docs exist, code doesn't)
4. Generate coverage report
5. Suggest specific updates needed

## Usage

### Syntax

```
/doc-check [target] [options]
```

### Parameters

- `target`: Repository name, organization, or "all"
- `--verbose`: Show detailed analysis
- `--fix`: Auto-generate fixes for issues found
- `--report <format>`: Output format (terminal, markdown, json)
- `--threshold <percent>`: Fail if coverage below threshold

### Examples

**Check single repository:**
```
/doc-check user-service
```

**Check entire organization:**
```
/doc-check polybase-poc
```

**Verbose output with details:**
```
/doc-check user-service --verbose
```

**Generate markdown report:**
```
/doc-check user-service --report markdown
```

**Check and auto-fix issues:**
```
/doc-check user-service --fix
```

**Fail if coverage below 80%:**
```
/doc-check user-service --threshold 80
```

## Prerequisites

- Repository must exist
- Must have some documentation (README at minimum)

## Validation Rules

- Target must be valid repository or organization
- If --threshold specified, must be 0-100

## Expected Outcomes

**Standard Output**:
```
Documentation Check Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Repository: polybase-poc/user-service
Team: backend
Checked: 2026-04-09 14:30:00

📊 Coverage Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall: 72% (Needs Improvement)

Essential Docs:  ████████░░ 80% (4/5)
API Docs:        ███████░░░ 65% (13/20)
Architecture:    ██████░░░░ 58% (Good diagrams, missing details)
Setup Guide:     ██████████ 95% (Excellent)
Contributing:    ███░░░░░░░ 30% (Minimal)

✅ Well Documented (4)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ README.md - Complete and up-to-date
✓ docs/SETUP.md - Comprehensive setup guide
✓ docs/ARCHITECTURE.md - Good overview with diagrams
✓ docs/DEPLOYMENT.md - Clear deployment steps

⚠️  Issues Found (7)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Missing Documentation:
  ❌ docs/API.md - 7 undocumented endpoints
     - GET /api/v1/users/search
     - POST /api/v1/users/bulk
     - DELETE /api/v1/users/{id}
     - PUT /api/v1/users/{id}/profile
     - GET /api/v1/users/{id}/activity
     - POST /api/v1/users/{id}/reset-password
     - GET /api/v1/users/{id}/permissions
  
  ❌ docs/CONTRIBUTING.md - Minimal content (only 15 lines)
     Needs: PR guidelines, code standards, review process
  
  ❌ docs/TROUBLESHOOTING.md - File doesn't exist
     Common issues should be documented

Stale Documentation:
  ⚠️  docs/ARCHITECTURE.md (line 45-67)
     - Documents old authentication flow
     - Code changed 14 days ago, docs not updated
     - Affected: JWT token generation moved to auth-service
  
  ⚠️  README.md (line 23)
     - Lists 8 features, code has 12
     - Missing: User search, bulk operations, activity tracking, audit logs
  
  ⚠️  docs/SETUP.md (line 89)
     - References PostgreSQL 13, code requires PostgreSQL 14+
     - Updated in pom.xml 21 days ago

Orphaned Documentation:
  ⚠️  docs/API.md (line 156-178)
     - Documents DELETE /api/v1/users/purge
     - Endpoint removed in commit abc123f 7 days ago

📈 Metrics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total API Endpoints:     20
Documented Endpoints:    13 (65%)
Undocumented:           7 (35%)

Total Components:        12
Documented Components:   9 (75%)

Code Changes (30 days):  23 commits
Doc Updates (30 days):   3 commits
Staleness Risk:         Medium

Last Doc Update:        7 days ago
Last Code Update:       2 days ago

🎯 Recommendations
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. High Priority:
   - Document 7 missing API endpoints
   - Update stale authentication flow in ARCHITECTURE.md
   - Remove documentation for deleted purge endpoint

2. Medium Priority:
   - Expand CONTRIBUTING.md with guidelines
   - Update README feature list
   - Fix PostgreSQL version in SETUP.md

3. Low Priority:
   - Add TROUBLESHOOTING.md
   - Add more architecture diagrams
   - Document error codes

💡 Quick Fix
Run: /doc-update user-service --since 30d

Status: ⚠️  Needs Attention (Coverage: 72%)
```

**Verbose Output**:
Includes:
- File-by-file analysis
- Line-by-line diff of stale sections
- Commit history showing when code/docs changed
- Specific code examples that need documentation

**Markdown Report**:
Generates `doc-check-report.md` with full analysis in markdown format for sharing.

**JSON Output**:
```json
{
  "repository": "polybase-poc/user-service",
  "checked_at": "2026-04-09T14:30:00Z",
  "coverage": {
    "overall": 72,
    "essential_docs": 80,
    "api_docs": 65,
    "architecture": 58,
    "setup": 95,
    "contributing": 30
  },
  "issues": {
    "missing": [...],
    "stale": [...],
    "orphaned": [...]
  },
  "metrics": {...},
  "recommendations": [...]
}
```

## Check Logic

The skill analyzes:

**Code Structure**:
- API endpoints (from controllers, routes)
- Services and components
- Data models
- Configuration files
- Entry points

**Existing Docs**:
- README.md
- docs/ARCHITECTURE.md
- docs/API.md
- docs/SETUP.md
- docs/DEPLOYMENT.md
- docs/CONTRIBUTING.md
- docs/TROUBLESHOOTING.md

**Git History**:
- Last modification time for code files
- Last modification time for doc files
- Commits that changed code but not docs

**Coverage Calculation**:
```
API Coverage = (Documented Endpoints / Total Endpoints) * 100
Component Coverage = (Documented Components / Total Components) * 100
Overall = Weighted average based on importance
```

## Coverage Thresholds

| Coverage | Grade | Status |
|----------|-------|--------|
| 90-100% | A | ✅ Excellent |
| 80-89% | B | ✅ Good |
| 70-79% | C | ⚠️  Needs Improvement |
| 60-69% | D | ⚠️  Poor |
| Below 60% | F | ❌ Critical |

## Implementation Notes

This skill invokes the `doc-architect` agent with check mode:

```javascript
Agent({
  name: "doc-checker",
  subagent_type: "doc-architect",
  prompt: `Check documentation for ${target}.

Parameters:
- Target: ${target}
- Verbose: ${verbose}
- Report format: ${reportFormat}
- Threshold: ${threshold}

Workflow:
1. Scan code structure (APIs, components, configs)
2. Review existing documentation
3. Compare code vs docs:
   - Identify undocumented features
   - Find stale sections
   - Detect orphaned docs
4. Calculate coverage metrics
5. Generate report
6. If --fix: Generate update recommendations

Execute documentation verification.`
})
```

## Auto-Fix Mode

With `--fix` flag, the skill:
1. Identifies fixable issues
2. Prompts user to confirm fixes
3. Invokes `/doc-update` to fix issues
4. Re-runs check to verify

Example:
```
/doc-check user-service --fix

Found 7 issues that can be auto-fixed:
- 7 undocumented API endpoints
- 3 stale sections
- 1 orphaned section

Fix these issues? (y/n): y

Invoking /doc-update to fix issues...
[Update process runs]
Re-checking documentation...

Status: ✅ Improved to 89% coverage
```

## Integration with CI/CD

Can be run in CI pipeline:

```yaml
- name: Check Documentation
  run: |
    /doc-check ${{ github.repository }} --threshold 80 --report json
  # Fails build if coverage < 80%
```

## Comparison with Other Skills

| Feature | /doc-check | /doc-generate | /doc-update |
|---------|------------|---------------|-------------|
| **Action** | Verify | Create | Update |
| **Output** | Report | Full docs | Incremental |
| **Speed** | Fast | Slow | Medium |
| **Creates PR** | No (unless --fix) | Yes | Yes |
| **Use Case** | Audit | Initial setup | Maintenance |

## Tips

💡 **Run regularly**: Check docs weekly or in CI

💡 **Use thresholds**: Enforce minimum coverage in CI

💡 **Review before fix**: Check report before running --fix

💡 **Track trends**: Save reports to track improvement over time

## Scheduled Checks

Use with cron for automated monitoring:

```bash
# Check all repos daily
0 1 * * * /doc-check polybase-poc --report markdown > daily-doc-report.md
```

## Related Skills

- `/doc-generate` - Generate missing documentation
- `/doc-update` - Update stale documentation
- `/commit` - Commit manual documentation fixes

## Maintenance

This skill is maintained by the Platform SRE team.

---

**Version**: 1.0  
**Last Updated**: 2026-04-09  
**Maintained By**: Platform SRE Team
