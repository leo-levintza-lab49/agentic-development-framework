# Branch Naming Convention - Platform SRE

## Standard Format

```
<type>/<env>/<description>
```

## Branch Types

### feature
New infrastructure capabilities, service additions, or enhancements.

**Examples:**
- `feature/dev/add-cdn-cloudfront`
- `feature/staging/enable-auto-scaling`
- `feature/prod/multi-region-deployment`

### fix
Bug fixes, resource corrections, or configuration repairs.

**Examples:**
- `fix/dev/ec2-instance-sizing`
- `fix/staging/alb-health-check`
- `fix/prod/rds-connection-pool`

### security
Security patches, vulnerability remediations, or compliance updates.

**Examples:**
- `security/dev/patch-openssl`
- `security/staging/rotate-secrets`
- `security/prod/enable-encryption-at-rest`

### upgrade
Version upgrades, dependency updates, or platform migrations.

**Examples:**
- `upgrade/dev/kubernetes-1-28`
- `upgrade/staging/terraform-1-6`
- `upgrade/prod/postgresql-15`

### refactor
Infrastructure code refactoring, reorganization, or optimization.

**Examples:**
- `refactor/dev/module-restructure`
- `refactor/staging/consolidate-vpcs`
- `refactor/prod/optimize-networking`

### hotfix
Emergency fixes for production incidents (bypass normal process).

**Examples:**
- `hotfix/prod/incident-2024-001`
- `hotfix/prod/memory-leak-patch`

## Environments

### dev
Development environment for testing infrastructure changes.
- Low risk
- Frequent deployments
- Single reviewer sufficient

### staging
Pre-production environment mirroring production.
- Medium risk
- Validation before production
- 2 reviewers required

### prod
Production environment serving live traffic.
- High risk
- Change control required
- 2-3 reviewers required
- Rollback plan mandatory

### multi
Changes affecting multiple environments simultaneously.
- Coordinated deployments
- Additional approval required

## Description Guidelines

1. Use lowercase and hyphens (kebab-case)
2. Be specific and descriptive (max 50 characters)
3. Include ticket/issue number if applicable
4. Focus on the "what" not the "how"

### Good Examples
```
feature/prod/add-waf-rules-jira-1234
fix/staging/correct-subnet-cidr
security/prod/enable-guardduty
upgrade/dev/eks-cluster-1-28
```

### Bad Examples
```
feature/new-stuff              # Missing environment
fix-bug                        # Missing environment and vague
feature/prod/update            # Too vague
FEATURE/PROD/ADD-CDN          # Wrong case
feature/prod/make_changes     # Use hyphens, not underscores
```

## Special Branches

### main
Protected production branch. Direct commits not allowed.

### develop
Integration branch for development changes.

### release/v*
Release preparation branches (e.g., `release/v1.2.0`).

### experiment/*
Experimental or proof-of-concept work not intended for production.

**Examples:**
- `experiment/service-mesh-evaluation`
- `experiment/arm-instance-testing`

## Branch Lifecycle

1. Create branch from `develop` (or `main` for hotfixes)
2. Make changes following infrastructure standards
3. Push to remote and create pull request
4. Complete required reviews and checks
5. Merge via squash or rebase (no merge commits)
6. Delete branch after merge

## Protection Rules

### main branch
- Require pull request reviews (2 approvers)
- Require status checks to pass
- Require signed commits
- No force push
- No deletion

### develop branch
- Require pull request reviews (1 approver)
- Require status checks to pass
- No force push

### Production branches (*/prod/*)
- Additional security review required
- Change control ticket required
- Rollback plan documented
- Cost impact analysis completed

## Naming Pattern Validation

We enforce branch naming via CI. Invalid branch names will fail the pipeline.

**Regex Pattern:**
```
^(feature|fix|security|upgrade|refactor|hotfix)/(dev|staging|prod|multi)/[a-z0-9-]+$
```

Or special branches:
```
^(main|develop|release/v[0-9]+\.[0-9]+\.[0-9]+|experiment/.+)$
```

## Tips

- Use tab completion: Set up git aliases for common patterns
- Include ticket numbers: Helps with traceability and automation
- Keep branches short-lived: Merge within 2-3 days when possible
- Delete after merge: Keeps repository clean
- Rebase regularly: Stay up to date with base branch

## Quick Reference

| Change Type | Environment | Example |
|------------|-------------|---------|
| New resource | Dev | `feature/dev/add-redis-cache` |
| Bug fix | Staging | `fix/staging/lb-timeout` |
| Security patch | Prod | `security/prod/rotate-api-keys` |
| Version upgrade | Dev | `upgrade/dev/node-18` |
| Emergency fix | Prod | `hotfix/prod/disk-space-critical` |
| Code cleanup | Dev | `refactor/dev/simplify-modules` |

## Questions?

Contact Platform SRE team leads or refer to the [TEAM_GUIDE.md](../../docs/TEAM_GUIDE.md).
