# Commit Message Template - Platform SRE

## Standard Format

```
<type>(env): <brief description>

<detailed description>

Impact: <impact assessment>
Rollback: <rollback procedure (required for prod)>
Testing: <testing performed>
Refs: <ticket/issue references>

Co-Authored-By: <co-author name> <<co-author email>>
```

## Commit Types

### feat
New infrastructure resources, services, or capabilities.

**Example:**
```
feat(prod): add CloudFront CDN distribution

- Configure CloudFront distribution with S3 origin
- Enable edge caching with 24h TTL
- Add custom SSL certificate from ACM
- Configure WAF integration for DDoS protection

Impact: Improves global content delivery by 40-60%
Rollback: terraform destroy aws_cloudfront_distribution.main
Testing: Validated edge caching in 5 AWS regions
Refs: INFRA-1234, PERF-567
```

### fix
Bug fixes, configuration corrections, or resource repairs.

**Example:**
```
fix(staging): correct ALB health check configuration

Health check was using wrong port (8080 instead of 8000)
causing false negatives and service disruptions.

- Update health check port from 8080 to 8000
- Increase healthy threshold to 2 consecutive checks
- Reduce interval from 30s to 10s for faster recovery

Impact: Eliminates false positive health check failures
Rollback: Revert to previous health check configuration
Testing: Verified with load test, monitored for 2 hours
Refs: INC-2024-045, JIRA-789
```

### security
Security patches, vulnerability fixes, or compliance updates.

**Example:**
```
security(prod): rotate RDS master password

Routine 90-day password rotation per security policy.

- Generate new 32-character password via AWS Secrets Manager
- Update RDS master password
- Update application connection strings via parameter store
- Verify all applications reconnected successfully

Impact: No service disruption, zero downtime rotation
Rollback: Restore previous password from Secrets Manager version
Testing: Validated DB connectivity from all app instances
Refs: SEC-2024-Q2-ROTATE, COMPLIANCE-890
```

### upgrade
Version upgrades, dependency updates, or platform migrations.

**Example:**
```
upgrade(dev): upgrade Kubernetes cluster to 1.28

- Upgrade control plane from 1.27 to 1.28
- Update worker node AMI to AL2023-based image
- Migrate deprecated APIs (batch/v1beta1 → batch/v1)
- Update add-ons (CoreDNS, kube-proxy, VPC CNI)

Impact: Access to new K8s features, improved performance
Rollback: Snapshot taken, can restore 1.27 cluster from backup
Testing: Ran full test suite, verified all workloads
Refs: INFRA-2345, K8S-UPGRADE-2024-Q2
```

### perf
Performance optimization, cost reduction, or efficiency improvements.

**Example:**
```
perf(prod): implement S3 lifecycle policies for log archival

- Archive logs older than 30 days to Glacier
- Delete logs older than 1 year
- Reduce S3 storage costs by ~70%
- Estimated savings: $2,400/month

Impact: Significant cost reduction, no functionality change
Rollback: Remove lifecycle policies, restore from Glacier if needed
Testing: Verified policy rules in dev, validated restoration
Refs: COST-OPT-2024-Q2, FINOPS-456
```

### refactor
Infrastructure code refactoring, reorganization, or cleanup.

**Example:**
```
refactor(dev): consolidate VPC modules into reusable components

- Extract common VPC configuration into shared module
- Standardize subnet naming conventions
- Remove duplicated NACL rules across environments
- Reduce code duplication by 40%

Impact: Easier maintenance, consistent networking config
Rollback: Git revert to previous module structure
Testing: Plan shows no infrastructure changes, validated in dev
Refs: TECH-DEBT-123
```

### docs
Documentation updates, runbooks, or operational guides.

**Example:**
```
docs(multi): add disaster recovery runbook

- Document RTO/RPO requirements (4h/1h)
- Add step-by-step recovery procedures
- Include failover testing checklist
- Link to monitoring dashboards

Impact: Improved incident response capability
Rollback: N/A (documentation only)
Testing: Reviewed by on-call team
Refs: DR-PLAN-2024
```

### revert
Revert a previous commit or rollback a change.

**Example:**
```
revert(prod): rollback NAT gateway migration

This reverts commit a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6.

NAT gateway migration caused connectivity issues for private
subnets. Reverting to investigate further.

Impact: Restores previous stable state
Rollback: N/A (this is the rollback)
Testing: Verified connectivity restored after revert
Refs: INC-2024-089
```

## Environment Tags

- `(dev)` - Development environment
- `(staging)` - Staging/pre-production environment
- `(prod)` - Production environment
- `(multi)` - Multiple environments affected
- `(all)` - All environments (use sparingly)

## Impact Assessment (Required for Prod)

Describe the impact of the change:
- Performance impact (latency, throughput)
- Cost impact (increase/decrease in AWS spend)
- Service availability (downtime required?)
- Dependencies (what services are affected?)
- Risk level (low/medium/high)

**Example:**
```
Impact: 
- Performance: 20% reduction in API latency
- Cost: +$150/month for larger instances
- Availability: Zero downtime deployment
- Dependencies: Affects API service and background workers
- Risk: Low - can roll back within 5 minutes
```

## Rollback Plan (Mandatory for Prod)

Every production commit must include a rollback procedure.

**Example:**
```
Rollback:
1. Revert this commit: git revert abc123
2. Apply Terraform: terraform apply
3. Verify health checks: curl https://health.example.com
4. Monitor for 15 minutes
5. Estimated rollback time: 10 minutes
```

## Testing Documentation

Document what testing was performed:

**Example:**
```
Testing:
- Unit tests: all passing
- Integration tests: verified API endpoints
- Load tests: sustained 10k RPS for 1 hour
- Canary deployment: monitored for 2 hours
- Smoke tests: all critical paths validated
```

## Commit Message Examples

### Production Database Scaling
```
feat(prod): scale RDS instance for increased load

Upgrade RDS instance from db.r6g.xlarge to db.r6g.2xlarge
to handle 3x traffic increase from new product launch.

- Increase vCPU from 4 to 8
- Increase RAM from 32GB to 64GB
- Enable Performance Insights for monitoring
- Schedule maintenance window: Sunday 2AM-3AM EST

Impact:
- Performance: Handles 3x current load
- Cost: +$450/month
- Availability: 2-3 minute downtime during upgrade
- Risk: Low - automated RDS maintenance process

Rollback:
1. Modify DB instance back to db.r6g.xlarge
2. Estimated rollback time: 3 minutes
3. Monitor query performance for degradation

Testing:
- Load tested with 3x synthetic traffic in staging
- Verified read/write performance improvements
- Confirmed backup and restore procedures

Refs: INFRA-5678, CAPACITY-2024-Q2
```

### Emergency Security Patch
```
security(prod): emergency patch for Log4Shell vulnerability

CRITICAL: Patch Log4Shell (CVE-2021-44228) in EKS workloads.

- Update base images with patched Log4j version 2.17.0
- Restart all affected pods via rolling update
- Scan container images for remaining vulnerabilities
- Block outbound LDAP traffic at security group level

Impact:
- Security: Mitigates critical RCE vulnerability
- Availability: Rolling restart, no downtime
- Performance: No performance impact
- Risk: High if not patched immediately

Rollback:
1. Revert to previous container image tag
2. kubectl rollout undo deployment/<name>
3. Estimated rollback time: 5 minutes

Testing:
- Verified patch with vulnerability scanner
- Tested application functionality in staging
- Confirmed no compatibility issues

Refs: SEC-CRITICAL-001, CVE-2021-44228, INC-2024-EMERGENCY
```

### Infrastructure Cost Optimization
```
perf(prod): implement Reserved Instances for EC2 fleet

Convert 40 on-demand EC2 instances to 1-year Reserved Instances
for 37% cost savings.

- Purchase RIs for predictable workload instances
- Maintain 20% on-demand for burst capacity
- Estimated annual savings: $48,000

Impact:
- Cost: -$48,000/year (37% reduction)
- Availability: No impact to running instances
- Risk: Very low - financial commitment only

Rollback:
N/A - RI commitment, can sell on RI marketplace if needed

Testing:
- Analyzed 6 months of usage patterns
- Verified instance types and AZ distribution
- Confirmed no planned architecture changes

Refs: COST-OPT-2024-Q3, FINOPS-789
```

## Best Practices

1. **Write in imperative mood**: "add feature" not "added feature"
2. **Limit subject line to 72 characters**: Keep it concise
3. **Separate subject from body**: Blank line after subject
4. **Explain why, not just what**: Context is crucial
5. **Reference tickets**: Always link to tracking systems
6. **Include co-authors**: Credit collaborators
7. **Use consistent formatting**: Follow this template
8. **Be specific**: "fix memory leak in cache" not "fix bug"

## What NOT to Do

- Don't use vague descriptions: "fix stuff", "update config"
- Don't skip impact assessment for production changes
- Don't omit rollback procedures for production
- Don't commit without testing documentation
- Don't use WIP commits in main branches
- Don't include sensitive data (passwords, keys)

## Git Commit Signing

All commits must be GPG signed for security:

```bash
git config --global user.signingkey <key-id>
git config --global commit.gpgsign true
```

## Tools and Automation

### Git Commit Template
Set up automatic template:
```bash
git config --local commit.template .claude/rules/commit-template.md
```

### Pre-commit Hooks
We enforce commit message format via pre-commit hooks:
- Subject line length check
- Impact assessment for prod changes
- Rollback plan for prod changes
- Ticket reference validation

## Questions?

Contact Platform SRE team leads or refer to the [TEAM_GUIDE.md](../../docs/TEAM_GUIDE.md).
