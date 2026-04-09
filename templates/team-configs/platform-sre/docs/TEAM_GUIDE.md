# Platform SRE Team Guide

Welcome to the Platform SRE team! This guide covers our infrastructure standards, processes, and best practices.

## Table of Contents

1. [Team Overview](#team-overview)
2. [Infrastructure as Code Standards](#infrastructure-as-code-standards)
3. [Change Management Process](#change-management-process)
4. [Incident Response Procedures](#incident-response-procedures)
5. [Tools and Technologies](#tools-and-technologies)
6. [On-Call Responsibilities](#on-call-responsibilities)
7. [Disaster Recovery](#disaster-recovery)
8. [Security and Compliance](#security-and-compliance)
9. [Cost Optimization](#cost-optimization)
10. [Best Practices](#best-practices)

---

## Team Overview

### Mission
Build and maintain reliable, scalable, and secure infrastructure that enables the engineering organization to deliver value to customers.

### Core Responsibilities
- Infrastructure provisioning and management
- Cloud platform operations (AWS, Azure, GCP)
- Kubernetes cluster management
- CI/CD pipeline maintenance
- Monitoring and observability
- Incident response and on-call rotation
- Disaster recovery planning and testing
- Cost optimization and FinOps
- Security hardening and compliance

### Team Structure
- **Platform SRE Lead**: Strategic direction and technical oversight
- **Senior SREs**: Complex infrastructure design, mentoring
- **SREs**: Day-to-day operations, automation, on-call
- **Junior SREs**: Learning, supporting, contributing

### Communication Channels
- **Slack**: #platform-sre (general), #platform-sre-oncall (urgent)
- **Email**: platform-sre@polybase-poc.com
- **PagerDuty**: On-call escalation
- **Jira**: Project tracking and change requests
- **Confluence**: Documentation and runbooks

---

## Infrastructure as Code Standards

### Philosophy
All infrastructure must be defined as code. No manual changes in production.

### Terraform Standards

#### Directory Structure
```
terraform/
├── modules/              # Reusable modules
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   └── monitoring/
├── environments/         # Environment-specific configs
│   ├── dev/
│   ├── staging/
│   └── production/
├── global/              # Cross-environment resources
│   ├── iam/
│   ├── route53/
│   └── s3/
└── scripts/             # Helper scripts
```

#### Module Requirements
- **README**: Clear documentation with examples
- **Variables**: All inputs via variables, no hardcoding
- **Outputs**: Export important resource attributes
- **Versions**: Pin provider versions
- **Validation**: Input validation where applicable

#### Example Module
```hcl
# modules/vpc/main.tf
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Must be dev, staging, or production."
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}
```

#### State Management
- **Backend**: S3 with DynamoDB locking
- **State files**: One per environment
- **Encryption**: Server-side encryption enabled
- **Versioning**: S3 versioning enabled for rollback

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "polybase-terraform-state"
    key            = "environments/production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

#### Naming Conventions
- Resources: `{environment}-{service}-{resource-type}`
- Tags: Always include `Name`, `Environment`, `ManagedBy`, `Owner`
- Variables: Use descriptive names with type constraints

### Kubernetes Standards

#### Manifest Organization
```
k8s/
├── base/                # Base configurations (Kustomize)
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── overlays/           # Environment overlays
    ├── dev/
    ├── staging/
    └── production/
```

#### Resource Requirements
All deployments must specify:
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

#### Labels and Annotations
Required labels:
```yaml
labels:
  app: myapp
  version: v1.2.3
  environment: production
  team: platform-sre
  cost-center: engineering
```

#### Health Checks
Always define:
```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

---

## Change Management Process

### Change Categories

#### Standard Change
- Low risk, well-understood changes
- Pre-approved by Platform SRE Lead
- Examples: Scaling resources, minor config updates

**Process:**
1. Create Jira ticket
2. Submit PR with required documentation
3. Get 1 peer review
4. Deploy during business hours
5. Monitor for 1 hour

#### Normal Change
- Moderate risk requiring review
- Most infrastructure changes fall here

**Process:**
1. Create Jira ticket with impact assessment
2. Submit PR with full documentation
3. Get 2 peer reviews
4. Schedule deployment window
5. Deploy with rollback plan ready
6. Monitor for 4 hours

#### Major Change
- High risk, significant impact
- Examples: Database migrations, network changes, multi-region failover

**Process:**
1. Create Change Advisory Board (CAB) ticket
2. Submit detailed change proposal
3. CAB review and approval (weekly meeting)
4. Create PR with comprehensive documentation
5. Get 3 reviews (SRE Lead + Security + Peer)
6. Schedule maintenance window
7. Communicate to stakeholders
8. Deploy with full team availability
9. Monitor for 24 hours

#### Emergency Change
- Critical incident resolution
- Security vulnerabilities

**Process:**
1. Page on-call team
2. Create incident ticket
3. Make minimal changes to resolve
4. Expedited review (1 approver)
5. Deploy immediately
6. Post-incident review within 48 hours
7. Follow up with permanent fix

### Deployment Windows

- **Development**: Anytime
- **Staging**: Business hours (9 AM - 5 PM ET)
- **Production Standard**: Tue-Thu, 10 AM - 2 PM ET
- **Production Major**: Sundays, 2 AM - 6 AM ET
- **Emergency**: Anytime

### Change Freeze Periods
No production changes during:
- Black Friday week (ecommerce)
- End of quarter (last 3 days)
- Major product launches (announced in advance)
- Active incidents (SEV-1 or SEV-2)

---

## Incident Response Procedures

### Severity Levels

#### SEV-1 (Critical)
- **Impact**: Complete service outage
- **Response time**: 15 minutes
- **Examples**: Production database down, API completely unavailable

**Response:**
1. Page on-call SRE and Engineering Lead
2. Create incident channel (#incident-YYYY-MM-DD-NNN)
3. Assign incident commander
4. Start incident bridge
5. Provide status updates every 15 minutes
6. Engage vendor support if needed
7. Document all actions in incident doc

#### SEV-2 (High)
- **Impact**: Significant degradation
- **Response time**: 30 minutes
- **Examples**: High error rate, slow response times

**Response:**
1. Page on-call SRE
2. Create incident channel
3. Investigate and resolve
4. Update status page
5. Status updates every 30 minutes

#### SEV-3 (Medium)
- **Impact**: Minor degradation
- **Response time**: 4 hours
- **Examples**: Non-critical service issues

**Response:**
1. Create Jira ticket
2. Assign to on-call SRE
3. Resolve during business hours
4. No customer notification needed

#### SEV-4 (Low)
- **Impact**: Minimal or no impact
- **Response time**: Next business day
- **Examples**: Monitoring false positives, cosmetic issues

### Incident Response Roles

#### Incident Commander (IC)
- Owns incident response
- Makes decisions and delegates tasks
- Communicates with stakeholders
- Cannot also be primary responder

#### Primary Responder
- Investigates and resolves technical issues
- Reports findings to IC
- Implements fixes

#### Communications Lead
- Updates status page
- Sends customer communications
- Coordinates with support team

#### Scribe
- Documents timeline
- Records decisions and actions
- Maintains incident doc

### Incident Response Checklist

**During Incident:**
- [ ] Incident severity determined
- [ ] Incident channel created
- [ ] Roles assigned (IC, responder, comms)
- [ ] Incident bridge started
- [ ] Customer impact assessed
- [ ] Status page updated
- [ ] Stakeholders notified
- [ ] All actions documented
- [ ] Resolution implemented
- [ ] Verification completed
- [ ] Status page updated (resolved)

**Post-Incident:**
- [ ] Post-mortem scheduled (within 48 hours)
- [ ] Timeline documented
- [ ] Root cause identified
- [ ] Action items created
- [ ] Post-mortem published
- [ ] Follow-up changes implemented

### Post-Mortem Template

**Incident Details:**
- Date/Time: YYYY-MM-DD HH:MM
- Severity: SEV-X
- Duration: X hours Y minutes
- Services Affected: List
- Customer Impact: Description

**Timeline:**
| Time | Event |
|------|-------|
| 14:23 | Alert fired: High error rate |
| 14:25 | On-call paged |
| 14:28 | Investigation started |
| ... | ... |

**Root Cause:**
Detailed explanation of what went wrong and why.

**Resolution:**
How the incident was resolved.

**What Went Well:**
- Fast detection (2 minutes)
- Clear runbooks followed
- Good communication

**What Could Be Improved:**
- Monitoring should catch this earlier
- Rollback took too long
- Documentation was outdated

**Action Items:**
| Action | Owner | Due Date | Priority |
|--------|-------|----------|----------|
| Improve monitoring | @alice | 2024-05-15 | High |
| Automate rollback | @bob | 2024-05-20 | High |
| Update runbook | @charlie | 2024-05-10 | Medium |

---

## Tools and Technologies

### Infrastructure Management
- **Terraform**: Infrastructure as Code
- **Terragrunt**: DRY Terraform configurations
- **Ansible**: Configuration management (legacy)
- **Packer**: Machine image building

### Container Orchestration
- **Kubernetes**: Container orchestration
- **Helm**: Package management
- **Kustomize**: Manifest customization
- **ArgoCD**: GitOps continuous delivery

### Cloud Platforms
- **AWS**: Primary cloud provider
- **Azure**: Secondary for multi-cloud
- **GCP**: Specific workloads

### Monitoring and Observability
- **Datadog**: APM and infrastructure monitoring
- **Prometheus**: Metrics collection
- **Grafana**: Dashboards and visualization
- **ELK Stack**: Log aggregation and analysis
- **Jaeger**: Distributed tracing

### Incident Management
- **PagerDuty**: On-call scheduling and alerting
- **Opsgenie**: Backup alerting system
- **Slack**: Team communication
- **StatusPage**: Customer status communications

### Security
- **Vault**: Secrets management
- **AWS Secrets Manager**: Cloud-native secrets
- **Qualys**: Vulnerability scanning
- **Wiz**: Cloud security posture management

### Cost Management
- **CloudHealth**: Multi-cloud cost management
- **Infracost**: Terraform cost estimation
- **AWS Cost Explorer**: AWS spend analysis

---

## On-Call Responsibilities

### On-Call Schedule
- **Rotation**: 1 week per rotation
- **Coverage**: 24/7
- **Handoff**: Mondays at 10 AM ET
- **Backup**: Secondary on-call for escalation

### On-Call Duties
- Respond to pages within SLA (15 min for SEV-1)
- Investigate and resolve incidents
- Escalate when necessary
- Document all incidents
- Update runbooks if gaps found
- Handoff summary to next on-call

### On-Call Compensation
- Base on-call stipend: $500/week
- Incident pay: $100/hour (outside business hours)
- Comp time: For major incidents > 4 hours

### On-Call Best Practices
1. **Be prepared**: Review recent changes before your rotation
2. **Stay available**: Keep laptop and phone nearby
3. **Communicate**: Update team if you'll be unavailable
4. **Escalate early**: Don't struggle alone
5. **Document**: Record everything in incident doc
6. **Learn**: Use incidents as learning opportunities

### Handoff Checklist
- [ ] Review open incidents from past week
- [ ] Check recent deployments
- [ ] Review upcoming changes
- [ ] Test pager connectivity
- [ ] Verify VPN access
- [ ] Review critical runbooks
- [ ] Introduce yourself in #platform-sre-oncall

---

## Disaster Recovery

### RTO and RPO Targets

| Service | RTO | RPO | Strategy |
|---------|-----|-----|----------|
| API Service | 4 hours | 1 hour | Multi-region active-passive |
| Database | 4 hours | 1 hour | Cross-region replicas |
| Storage | 8 hours | 24 hours | Cross-region replication |
| CI/CD | 24 hours | 24 hours | Rebuild from IaC |

### Backup Strategy

#### Databases
- **Automated backups**: Daily, 7-day retention
- **Manual snapshots**: Before major changes
- **Cross-region**: Replicate to secondary region
- **Testing**: Monthly restore drills

#### File Storage
- **S3 versioning**: Enabled on all critical buckets
- **Cross-region replication**: For production data
- **Lifecycle policies**: Archive old data to Glacier
- **Testing**: Quarterly restore verification

#### Infrastructure State
- **Terraform state**: S3 versioning enabled
- **Configuration**: Git repository backups
- **AMI/Container images**: Multi-region copies

### Failover Procedures

#### Database Failover
```bash
# 1. Verify replica health
aws rds describe-db-instances --db-instance-identifier prod-replica

# 2. Promote replica to primary
aws rds promote-read-replica \
  --db-instance-identifier prod-replica

# 3. Update DNS to point to new primary
# 4. Monitor for replication lag
# 5. Update application connection strings
```

#### Multi-Region Failover
See [DR Runbook](./runbooks/disaster-recovery.md) for detailed procedures.

### DR Testing Schedule
- **Backup restore**: Monthly
- **Database failover**: Quarterly
- **Full DR drill**: Annually
- **Tabletop exercises**: Quarterly

---

## Security and Compliance

### Security Principles
1. **Least privilege**: Minimal required permissions
2. **Defense in depth**: Multiple security layers
3. **Encryption**: At rest and in transit
4. **Secrets management**: Never hardcode secrets
5. **Patch management**: Regular updates
6. **Audit logging**: Comprehensive logging

### Access Management

#### AWS Account Access
- **SSO**: Required for all users
- **MFA**: Mandatory for all accounts
- **Session duration**: Max 12 hours
- **Review**: Quarterly access review

#### Production Access
- **Bastion hosts**: Required for SSH access
- **Just-in-time**: Temporary elevated access
- **Session recording**: All sessions logged
- **Approval required**: 2-person rule for sensitive operations

#### Secrets Management
- Never commit secrets to Git
- Use AWS Secrets Manager or Vault
- Rotate secrets every 90 days
- Use IAM roles instead of static credentials

### Compliance Requirements

#### SOC 2
- Change management documentation
- Access control reviews
- Incident response procedures
- Security awareness training

#### GDPR
- Data retention policies
- Right to erasure procedures
- Data processing agreements
- Privacy by design

#### PCI DSS (if applicable)
- Network segmentation
- Encryption requirements
- Access control
- Regular security testing

### Security Scanning
- **Daily**: Vulnerability scans
- **Per PR**: Infrastructure security scan
- **Weekly**: Penetration testing (automated)
- **Quarterly**: External security audit

---

## Cost Optimization

### Cost Management Principles
1. **Right-sizing**: Match resources to actual needs
2. **Reserved capacity**: Commit for predictable workloads
3. **Spot instances**: Use for fault-tolerant workloads
4. **Auto-scaling**: Scale down when not needed
5. **Storage tiering**: Use appropriate storage classes
6. **Monitor and alert**: Track cost anomalies

### Cost Review Process
- **Daily**: Automated anomaly detection
- **Weekly**: Team cost review
- **Monthly**: Department budget review
- **Quarterly**: FinOps planning session

### Cost Optimization Opportunities

#### Compute
- Use Spot/Preemptible for batch jobs (60-90% savings)
- Right-size instances based on utilization
- Purchase Reserved Instances for base load
- Use Savings Plans for flexible commitments

#### Storage
- S3 Intelligent-Tiering for variable access patterns
- Archive old logs to Glacier
- Delete unused EBS volumes and snapshots
- Use compression for backups

#### Networking
- Use VPC endpoints to avoid NAT costs
- CDN for global content delivery
- Consolidate cross-AZ traffic

### Cost Allocation
- Tag all resources with cost center
- Use separate AWS accounts per team
- Implement showback/chargeback model
- Regular cost attribution reports

---

## Best Practices

### Infrastructure Design
1. **High availability**: Multi-AZ deployments
2. **Scalability**: Auto-scaling configured
3. **Security**: Follow security principles
4. **Observability**: Comprehensive monitoring
5. **Documentation**: Architecture diagrams
6. **Testing**: Regular DR drills

### Operational Excellence
1. **Automation**: Automate repetitive tasks
2. **Documentation**: Keep runbooks updated
3. **Continuous improvement**: Learn from incidents
4. **Knowledge sharing**: Regular team demos
5. **Mentoring**: Help junior team members grow

### Code Review Standards
1. **Terraform plan**: Always review plan output
2. **Security**: Check for exposed resources
3. **Cost impact**: Estimate monthly cost
4. **Naming**: Follow conventions
5. **Documentation**: Update if needed
6. **Testing**: Verify in dev/staging first

### Communication
1. **Be proactive**: Communicate changes early
2. **Be clear**: Use simple, direct language
3. **Be responsive**: Reply within 4 hours
4. **Be respectful**: Assume good intentions
5. **Document decisions**: Don't lose context

### Career Development
- **Learning budget**: $2,000/year per person
- **Conference attendance**: 1-2 per year
- **Certification**: AWS/GCP/CKA encouraged
- **20% time**: Innovation projects
- **Mentorship**: Pairing with senior engineers

---

## Additional Resources

### Internal Documentation
- [Terraform Standards](./terraform-standards.md)
- [Kubernetes Guidelines](./kubernetes-guidelines.md)
- [Runbook Library](./runbooks/)
- [Architecture Docs](./architecture/)

### External Resources
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Google SRE Book](https://sre.google/books/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Kubernetes Production Best Practices](https://learnk8s.io/production-best-practices)

### Training
- AWS Solutions Architect certification
- Certified Kubernetes Administrator (CKA)
- HashiCorp Terraform Associate
- Linux Foundation courses

### Support Channels
- **Slack**: #platform-sre (general questions)
- **Email**: platform-sre@polybase-poc.com
- **Office hours**: Tuesdays/Thursdays 2-3 PM ET
- **Emergency**: Page on-call via PagerDuty

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2024-04-09 | Initial version | Platform SRE Team |

---

**Questions?** Reach out in #platform-sre or during office hours!
