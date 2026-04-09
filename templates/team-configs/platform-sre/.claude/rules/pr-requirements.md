# Pull Request Requirements - Platform SRE

## Overview

This document defines the requirements for submitting pull requests to Platform SRE repositories. All PRs must meet these standards before approval.

## PR Title Format

```
<type>(env): <brief description>
```

**Examples:**
- `feat(prod): add CloudFront CDN for static assets`
- `fix(staging): correct ALB health check port`
- `security(prod): rotate database credentials`
- `upgrade(dev): upgrade Kubernetes to 1.28`

Keep titles under 72 characters. Use the PR description for details.

## Required PR Sections

Every PR must include these sections in the description:

### 1. Summary
Brief overview of what this PR does and why.

**Example:**
```markdown
## Summary

This PR implements CloudFront CDN for static assets to improve
global content delivery performance and reduce origin load.
```

### 2. Changes Made
Detailed list of changes, organized by file or component.

**Example:**
```markdown
## Changes Made

- Added CloudFront distribution configuration in `terraform/cdn.tf`
- Created S3 bucket for origin with versioning enabled
- Configured WAF rules for DDoS protection
- Added CloudWatch alarms for cache hit rate monitoring
- Updated DNS records in Route53 to point to CloudFront
```

### 3. Testing (Required)
Document all testing performed. Production changes require comprehensive testing.

**Example:**
```markdown
## Testing

### Unit Tests
- ✅ All Terraform validation tests passing
- ✅ Security scan (tfsec, checkov) - no high/critical issues

### Integration Tests
- ✅ Deployed to dev environment
- ✅ Deployed to staging environment
- ✅ Smoke tests passed in both environments

### Load Testing
- ✅ Simulated 10k RPS for 30 minutes
- ✅ Cache hit rate: 85%
- ✅ Origin load reduced by 70%

### Manual Testing
- ✅ Verified content delivery from 5 AWS regions
- ✅ Confirmed SSL certificate working correctly
- ✅ Tested cache invalidation process
```

### 4. Impact Assessment (Required for Prod)
Comprehensive analysis of the impact of these changes.

**Example:**
```markdown
## Impact Assessment

### Performance
- **Latency**: 40-60% reduction for global users
- **Throughput**: Can handle 10x current traffic
- **Cache hit rate**: Expected 80-90%

### Cost
- **Monthly cost**: +$500-700/month for CloudFront
- **Savings**: -$300/month reduced EC2 load
- **Net impact**: +$200-400/month
- **ROI**: Improved user experience justifies cost

### Availability
- **Deployment method**: Blue-green deployment
- **Downtime**: Zero downtime expected
- **Rollback time**: 5 minutes
- **Risk level**: Low

### Dependencies
- **Upstream**: None
- **Downstream**: Web application (needs DNS update)
- **External**: Route53, ACM certificate

### Security
- **WAF enabled**: Yes, protecting against common attacks
- **Encryption**: TLS 1.2+ enforced
- **Access control**: S3 bucket restricted to CloudFront OAI
```

### 5. Rollback Plan (Mandatory for Prod)
Step-by-step procedure to rollback if issues occur.

**Example:**
```markdown
## Rollback Plan

### Quick Rollback (5 minutes)
1. Update Route53 DNS to point back to ALB
2. Wait for TTL propagation (60 seconds)
3. Verify traffic routing to origin
4. Monitor error rates and latency

### Full Rollback (15 minutes)
1. Execute quick rollback steps above
2. Run `terraform destroy` for CloudFront resources
3. Remove S3 bucket (or retain for analysis)
4. Verify all resources cleaned up
5. Update monitoring dashboards

### Rollback Triggers
- Error rate > 1%
- Latency increase > 20%
- Cache hit rate < 50%
- Cost anomaly detected
```

### 6. Security Review Checklist (Required for Prod)
Complete this checklist for all production changes.

**Example:**
```markdown
## Security Review Checklist

- [x] No hardcoded credentials or secrets
- [x] All secrets stored in AWS Secrets Manager
- [x] IAM roles follow least-privilege principle
- [x] Security group rules are restrictive
- [x] Encryption at rest enabled
- [x] Encryption in transit enforced (TLS 1.2+)
- [x] Logging enabled for audit trail
- [x] No public S3 buckets or exposed resources
- [x] Compliance requirements reviewed (SOC2, GDPR)
- [x] Vulnerability scan completed (no high/critical issues)
```

### 7. Disaster Recovery Testing (Required for High-Impact Changes)
Evidence that disaster recovery procedures have been tested.

**Example:**
```markdown
## Disaster Recovery Testing

### Backup Verification
- [x] RDS automated backups confirmed (7-day retention)
- [x] S3 versioning enabled for critical buckets
- [x] EBS snapshots scheduled daily
- [x] Cross-region replication configured

### Recovery Testing
- [x] Successfully restored from backup in staging
- [x] Verified data integrity after restore
- [x] Documented recovery time: 45 minutes (within RTO)
- [x] Tested failover to secondary region

### RTO/RPO Compliance
- **RTO**: 4 hours (meets requirement)
- **RPO**: 1 hour (meets requirement)
```

### 8. Terraform Plan Output (Required)
Include the Terraform plan output showing proposed changes.

**Example:**
```markdown
## Terraform Plan Output

<details>
<summary>Click to expand Terraform plan</summary>

\`\`\`terraform
Terraform will perform the following actions:

  # aws_cloudfront_distribution.main will be created
  + resource "aws_cloudfront_distribution" "main" {
      + arn                            = (known after apply)
      + domain_name                   = (known after apply)
      + enabled                       = true
      + http_version                  = "http2and3"
      + price_class                   = "PriceClass_All"
      ...
    }

Plan: 5 to add, 2 to change, 0 to destroy.
\`\`\`

</details>
```

### 9. Cost Impact Analysis (Required for Resource Changes)
Include Infracost output or manual cost analysis.

**Example:**
```markdown
## Cost Impact Analysis

| Resource | Current | Proposed | Change |
|----------|---------|----------|--------|
| CloudFront | $0 | $500/mo | +$500 |
| EC2 | $1,200/mo | $900/mo | -$300 |
| S3 Storage | $50/mo | $80/mo | +$30 |
| **Total** | **$1,250/mo** | **$1,480/mo** | **+$230/mo** |

### Cost Justification
The additional $230/month is justified by:
- 40-60% improvement in global latency
- 10x capacity increase
- Reduced origin server load
- Improved user experience and conversion rates
```

### 10. Monitoring and Alerting
Describe monitoring setup for these changes.

**Example:**
```markdown
## Monitoring and Alerting

### New CloudWatch Alarms
- Cache hit rate < 70% (warning)
- 4xx error rate > 5% (critical)
- 5xx error rate > 1% (critical)
- Request count anomaly detection

### New Dashboards
- CloudFront performance dashboard
- Origin vs edge latency comparison
- Cost tracking and optimization

### Logging
- CloudFront access logs → S3 → Athena
- WAF logs → CloudWatch Logs
- 7-day retention for analysis
```

## Review Requirements by Environment

### Development
- **Reviewers required**: 1
- **Auto-merge**: After CI passes + 1 approval
- **Rollback plan**: Recommended but not mandatory

### Staging
- **Reviewers required**: 2
- **Required checks**: All CI tests must pass
- **Rollback plan**: Recommended

### Production
- **Reviewers required**: 2 (3 for high-impact changes)
- **Required reviewers**: Platform SRE lead + Security team
- **Required checks**: All CI tests + manual approval
- **Rollback plan**: Mandatory
- **Impact assessment**: Mandatory
- **Disaster recovery testing**: Required for database/storage changes
- **Change control ticket**: Required for major changes

## High-Impact Production Changes

Changes that affect these areas require additional approval:

1. **Database schema changes** (require DBA review)
2. **Network/VPC modifications** (require Network team review)
3. **Security group rules** (require Security team review)
4. **IAM policy changes** (require Security team review)
5. **Multi-region failover** (require DR team review)
6. **Cost impact > $1000/month** (require FinOps approval)

## PR Workflow

1. **Create branch** following naming convention
2. **Make changes** following infrastructure standards
3. **Run local tests** (terraform fmt, validate, plan)
4. **Push to remote** and create draft PR
5. **CI pipeline runs** automatically
6. **Mark PR ready for review** when CI passes
7. **Address review feedback** promptly
8. **Obtain required approvals**
9. **Merge** using squash or rebase (no merge commits)
10. **Monitor deployment** for 1 hour post-merge
11. **Delete branch** after successful merge

## PR Labels

Use these labels to categorize PRs:

### Type Labels
- `type:feature` - New functionality
- `type:fix` - Bug fix
- `type:security` - Security-related
- `type:upgrade` - Version upgrade
- `type:performance` - Performance improvement
- `type:refactor` - Code refactoring

### Environment Labels
- `env:dev` - Development environment
- `env:staging` - Staging environment
- `env:prod` - Production environment

### Priority Labels
- `priority:critical` - Emergency/hotfix
- `priority:high` - Important, needs quick review
- `priority:medium` - Standard priority
- `priority:low` - Nice to have

### Status Labels
- `status:in-progress` - Work in progress
- `status:blocked` - Blocked by dependency
- `status:needs-review` - Ready for review
- `status:needs-changes` - Changes requested

## Automated Checks

All PRs run through automated checks:

### Required Checks (Must Pass)
- ✅ Terraform format check
- ✅ Terraform validate
- ✅ Terraform plan (no errors)
- ✅ Security scan (tfsec, checkov)
- ✅ Kubernetes manifest validation
- ✅ Secret scanning (no leaked credentials)
- ✅ Branch naming convention
- ✅ Commit message format

### Optional Checks (Informational)
- 📊 Cost estimation (Infracost)
- 📊 Code coverage
- 📊 Terraform complexity score

## Common PR Mistakes to Avoid

1. ❌ Missing Terraform plan output
2. ❌ No rollback plan for production changes
3. ❌ Incomplete impact assessment
4. ❌ Skipping security checklist
5. ❌ No testing documentation
6. ❌ Vague PR title or description
7. ❌ Direct commits to main/develop
8. ❌ Large PRs (split into smaller, focused changes)
9. ❌ Hardcoded secrets or credentials
10. ❌ Missing ticket/issue references

## PR Size Guidelines

Keep PRs focused and manageable:

- **Small PR**: < 200 lines changed (ideal)
- **Medium PR**: 200-500 lines changed (acceptable)
- **Large PR**: > 500 lines changed (requires justification)

Large PRs should be split when possible. If unavoidable, provide extra context and documentation.

## Merge Strategies

### Squash and Merge (Preferred)
Use for most PRs to maintain clean history.

### Rebase and Merge
Use for PRs with well-crafted commits worth preserving.

### Merge Commit (Discouraged)
Avoid merge commits unless absolutely necessary.

## Post-Merge Responsibilities

After merging:

1. **Monitor deployment** - Watch for errors/alerts
2. **Verify functionality** - Smoke test critical paths
3. **Update documentation** - If procedures changed
4. **Close related tickets** - Link PR to resolved issues
5. **Communicate changes** - Notify stakeholders if needed
6. **Delete branch** - Clean up merged branches

## Emergency Hotfix Process

For critical production incidents:

1. Create `hotfix/prod/<description>` branch from `main`
2. Make minimal changes to resolve incident
3. Create PR with `priority:critical` label
4. Notify on-call team in Slack
5. Get expedited review (1 approver minimum)
6. Deploy immediately after approval
7. Follow up with post-mortem and permanent fix

## Questions or Issues?

- **General questions**: Ask in #platform-sre Slack channel
- **Review help**: Tag @platform-sre-leads
- **Security concerns**: Tag @security-team
- **Urgent issues**: Page on-call via PagerDuty

## Additional Resources

- [Branch Naming Convention](./branch-naming.md)
- [Commit Message Template](./commit-template.md)
- [Team Guide](../../docs/TEAM_GUIDE.md)
- [Terraform Standards](../../docs/terraform-standards.md)
- [Kubernetes Guidelines](../../docs/kubernetes-guidelines.md)
