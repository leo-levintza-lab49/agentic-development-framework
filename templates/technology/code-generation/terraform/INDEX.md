# Terraform Templates - Complete Index

> **Total Lines of Code:** 5,956  
> **Total Templates:** 10  
> **Documentation:** 3 comprehensive guides  
> **Total Size:** ~176KB

## Quick Navigation

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[GETTING_STARTED.md](GETTING_STARTED.md)** | Step-by-step deployment guide | First time using templates |
| **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** | Commands and cheat sheet | Daily operations |
| **[README.md](README.md)** | Complete documentation | Detailed reference |
| **INDEX.md** (this file) | Navigation hub | Finding what you need |

---

## Infrastructure Templates

### Core Templates (Always Needed)

| Template | Size | Lines | Complexity | Description |
|----------|------|-------|------------|-------------|
| [main.tf.template](main.tf.template) | 13KB | 400 | ⭐⭐ | Provider config, backend, orchestration |
| [variables.tf.template](variables.tf.template) | 13KB | 450 | ⭐⭐ | Input variables with validation |
| [outputs.tf.template](outputs.tf.template) | 15KB | 400 | ⭐ | Output values and data export |

### Networking Templates

| Template | Size | Lines | Complexity | Description |
|----------|------|-------|------------|-------------|
| [vpc.tf.template](vpc.tf.template) | 7KB | 250 | ⭐⭐⭐ | Multi-AZ VPC with subnets, NAT, IGW |
| [security-group.tf.template](security-group.tf.template) | 10KB | 350 | ⭐⭐ | Security groups with common rules |
| [alb.tf.template](alb.tf.template) | 11KB | 400 | ⭐⭐⭐ | Application Load Balancer with HTTPS |

### Compute Templates

| Template | Size | Lines | Complexity | Description |
|----------|------|-------|------------|-------------|
| [eks.tf.template](eks.tf.template) | 9KB | 300 | ⭐⭐⭐⭐ | EKS cluster with managed node groups |

### Storage & Database Templates

| Template | Size | Lines | Complexity | Description |
|----------|------|-------|------------|-------------|
| [rds.tf.template](rds.tf.template) | 10KB | 350 | ⭐⭐⭐ | PostgreSQL RDS with monitoring |
| [s3.tf.template](s3.tf.template) | 10KB | 350 | ⭐⭐ | S3 bucket with security features |

### Security & Access Templates

| Template | Size | Lines | Complexity | Description |
|----------|------|-------|------------|-------------|
| [iam-role.tf.template](iam-role.tf.template) | 10KB | 400 | ⭐⭐⭐ | IAM roles with trust policies |

**Complexity Legend:**
- ⭐ Simple - Easy to understand and modify
- ⭐⭐ Moderate - Requires some Terraform knowledge
- ⭐⭐⭐ Advanced - Requires good understanding of AWS and Terraform
- ⭐⭐⭐⭐ Expert - Complex configurations, review carefully

---

## Usage Patterns

### Pattern 1: Full Stack Deployment

**What:** Complete infrastructure for production application

**Templates Needed:**
1. main.tf.template
2. variables.tf.template
3. outputs.tf.template
4. vpc.tf.template
5. eks.tf.template
6. rds.tf.template
7. alb.tf.template
8. s3.tf.template
9. security-group.tf.template
10. iam-role.tf.template

**Deployment Time:** ~30-40 minutes

**Monthly Cost:** ~$600-700

### Pattern 2: Minimal Development Setup

**What:** Basic infrastructure for development

**Templates Needed:**
1. main.tf.template (with local backend)
2. variables.tf.template
3. outputs.tf.template
4. vpc.tf.template (single NAT)
5. security-group.tf.template

**Deployment Time:** ~5-10 minutes

**Monthly Cost:** ~$50-100

### Pattern 3: Serverless Architecture

**What:** Serverless application infrastructure

**Templates Needed:**
1. main.tf.template
2. variables.tf.template
3. outputs.tf.template
4. s3.tf.template
5. iam-role.tf.template
6. security-group.tf.template

**Deployment Time:** ~5 minutes

**Monthly Cost:** ~$10-50 (usage-based)

### Pattern 4: Database-Only Setup

**What:** Managed database with networking

**Templates Needed:**
1. main.tf.template
2. variables.tf.template
3. outputs.tf.template
4. vpc.tf.template
5. rds.tf.template
6. security-group.tf.template

**Deployment Time:** ~15-20 minutes

**Monthly Cost:** ~$250-350

---

## Template Dependencies

```
main.tf.template (orchestrator)
├── vpc.tf.template
│   ├── Required by: eks.tf, rds.tf, alb.tf
│   └── Creates: Subnets, NAT, IGW, Route Tables
│
├── security-group.tf.template
│   ├── Required by: eks.tf, rds.tf, alb.tf
│   └── Creates: Security groups and rules
│
├── iam-role.tf.template
│   ├── Required by: eks.tf, rds.tf, alb.tf
│   └── Creates: IAM roles and policies
│
├── eks.tf.template
│   ├── Depends on: vpc.tf, security-group.tf, iam-role.tf
│   └── Creates: EKS cluster, node groups, OIDC
│
├── rds.tf.template
│   ├── Depends on: vpc.tf, security-group.tf
│   └── Creates: RDS instance, subnet group, parameter group
│
├── alb.tf.template
│   ├── Depends on: vpc.tf, security-group.tf
│   └── Creates: ALB, target groups, listeners
│
└── s3.tf.template
    ├── Independent (no dependencies)
    └── Creates: S3 buckets, KMS keys, policies

variables.tf.template (defines inputs)
outputs.tf.template (exposes outputs)
```

---

## Placeholder Reference

### Required for All Templates
- `{{PROJECT_NAME}}` - Your project identifier
- `{{ENVIRONMENT}}` - Environment (dev/staging/prod)
- `{{REGION}}` - AWS region

### Template-Specific Placeholders

#### main.tf.template (15 placeholders)
```
{{PROJECT_NAME}}
{{REGION}}
{{SECONDARY_REGION}}
{{ACCOUNT_ID}}
{{ENVIRONMENT}}
{{TERRAFORM_STATE_BUCKET}}
{{TERRAFORM_LOCK_TABLE}}
{{TERRAFORM_KMS_KEY_ID}}
{{REPOSITORY_URL}}
{{TEAM_NAME}}
{{DOMAIN_NAME}}
{{ORG_NAME}}
{{ROLE_NAME}}
{{EXTERNAL_ID}}
{{SERVICE_NAME}}
```

#### vpc.tf.template (4 placeholders)
```
{{VPC_NAME}}
{{CIDR_BLOCK}}
{{ENVIRONMENT}}
{{PROJECT}}
```

#### eks.tf.template (16 placeholders)
```
{{CLUSTER_NAME}}
{{REGION}}
{{KUBERNETES_VERSION}}
{{VPC_ID}}
{{SUBNET_IDS}}
{{ENVIRONMENT}}
{{PROJECT}}
{{INSTANCE_TYPE}}
{{DISK_SIZE}}
{{DESIRED_SIZE}}
{{MAX_SIZE}}
{{MIN_SIZE}}
{{VPC_CNI_VERSION}}
{{KUBE_PROXY_VERSION}}
{{COREDNS_VERSION}}
{{EXTERNAL_ID}}
```

#### rds.tf.template (20 placeholders)
```
{{DB_NAME}}
{{INSTANCE_CLASS}}
{{ENGINE_VERSION}}
{{USERNAME}}
{{VPC_ID}}
{{SUBNET_IDS}}
{{ENVIRONMENT}}
{{PROJECT}}
{{VPC_CIDR_BLOCK}}
{{ALLOCATED_STORAGE}}
{{MAX_ALLOCATED_STORAGE}}
{{IOPS}}
{{THROUGHPUT}}
{{MULTI_AZ}}
{{BACKUP_RETENTION_PERIOD}}
{{DELETION_PROTECTION}}
{{MAX_CONNECTIONS}}
{{PARAMETER_GROUP_FAMILY}}
{{MAJOR_ENGINE_VERSION}}
{{ACCOUNT_ID}}
```

#### s3.tf.template (12 placeholders)
```
{{BUCKET_NAME}}
{{ENVIRONMENT}}
{{PROJECT}}
{{ACCOUNT_ID}}
{{TRANSITION_TO_IA_DAYS}}
{{TRANSITION_TO_GLACIER_DAYS}}
{{TRANSITION_TO_DEEP_ARCHIVE_DAYS}}
{{NONCURRENT_TRANSITION_DAYS}}
{{NONCURRENT_EXPIRATION_DAYS}}
{{ALLOWED_ORIGINS}}
{{BUCKET_SIZE_THRESHOLD}}
{{KMS_KEY_ARN}}
```

#### alb.tf.template (14 placeholders)
```
{{ALB_NAME}}
{{VPC_ID}}
{{SUBNET_IDS}}
{{CERTIFICATE_ARN}}
{{ENVIRONMENT}}
{{PROJECT}}
{{INTERNAL}}
{{DELETION_PROTECTION}}
{{TARGET_PORT}}
{{TARGET_TYPE}}
{{HEALTH_CHECK_PATH}}
{{HOST_HEADER}}
{{LOG_RETENTION_DAYS}}
{{BLUE_WEIGHT}}
{{GREEN_WEIGHT}}
```

#### security-group.tf.template (30+ placeholders)
```
{{SG_NAME}}
{{VPC_ID}}
{{DESCRIPTION}}
{{ENVIRONMENT}}
{{PROJECT}}
{{HTTP_CIDR_BLOCKS}}
{{HTTPS_CIDR_BLOCKS}}
{{APP_PORT}}
{{APP_CIDR_BLOCKS}}
{{SSH_CIDR_BLOCKS}}
{{POSTGRES_CIDR_BLOCKS}}
{{MYSQL_CIDR_BLOCKS}}
{{REDIS_CIDR_BLOCKS}}
{{NFS_CIDR_BLOCKS}}
{{K8S_CIDR_BLOCKS}}
{{FROM_SG_PORT}}
{{SOURCE_SECURITY_GROUP_ID}}
{{TO_SG_PORT}}
{{DEST_SECURITY_GROUP_ID}}
{{PORT_RANGE_START}}
{{PORT_RANGE_END}}
{{PORT_RANGE_CIDR_BLOCKS}}
{{VPC_CIDR_BLOCK}}
{{ICMP_CIDR_BLOCKS}}
{{PREFIX_LIST_ID}}
... and more
```

#### iam-role.tf.template (25+ placeholders)
```
{{ROLE_NAME}}
{{ROLE_DESCRIPTION}}
{{SERVICE}}
{{POLICY_ACTIONS}}
{{RESOURCES}}
{{ENVIRONMENT}}
{{PROJECT}}
{{MAX_SESSION_DURATION}}
{{ACCOUNT_ID}}
{{EXTERNAL_ID}}
{{OIDC_PROVIDER_ARN}}
{{OIDC_PROVIDER_URL}}
{{SERVICE_ACCOUNT}}
{{BUCKET_NAME}}
{{REGION}}
{{TABLE_NAME}}
{{SECRET_NAME}}
{{SERVICE_NAME}}
{{KMS_KEY_ARN}}
{{INLINE_ACTIONS}}
{{INLINE_RESOURCES}}
{{TRUSTED_ACCOUNT_ID}}
{{SAML_PROVIDER_NAME}}
... and more
```

---

## Quick Start Commands

### Complete Setup
```bash
# Copy all templates
cp *.template .
for f in *.template; do mv "$f" "${f%.template}"; done

# Replace placeholders
./scripts/replace-placeholders.sh

# Deploy
terraform init
terraform plan
terraform apply
```

### Individual Resource
```bash
# Copy specific template
cp vpc.tf.template vpc.tf

# Replace placeholders
sed -i 's/{{VPC_NAME}}/my-vpc/g' vpc.tf
sed -i 's/{{CIDR_BLOCK}}/10.0.0.0\/16/g' vpc.tf

# Deploy
terraform init
terraform apply -target=aws_vpc.main
```

---

## Feature Matrix

| Feature | VPC | EKS | RDS | S3 | ALB | SG | IAM |
|---------|-----|-----|-----|----|----|----|----|
| Multi-AZ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | N/A |
| Encryption | ✅ | ✅ | ✅ | ✅ | ✅ | N/A | N/A |
| Monitoring | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | N/A |
| Auto-scaling | N/A | ✅ | ✅ | N/A | ✅ | N/A | N/A |
| Backups | N/A | N/A | ✅ | ✅ | N/A | N/A | N/A |
| High Availability | ✅ | ✅ | ✅ | ✅ | ✅ | N/A | N/A |
| Cost Optimization | ✅ | ✅ | ✅ | ✅ | ✅ | N/A | N/A |

---

## Common Workflows

### Workflow 1: New Project Setup
1. Read [GETTING_STARTED.md](GETTING_STARTED.md)
2. Copy all templates
3. Configure backend
4. Replace placeholders
5. Review [README.md](README.md) for details
6. Deploy infrastructure

### Workflow 2: Add Single Resource
1. Copy specific template
2. Reference [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
3. Replace placeholders
4. Apply changes

### Workflow 3: Modify Existing
1. Check current state
2. Update template
3. Plan changes
4. Apply incrementally

---

## Support & Resources

### Documentation
- **Getting Started:** [GETTING_STARTED.md](GETTING_STARTED.md)
- **Quick Reference:** [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- **Complete Docs:** [README.md](README.md)

### External Resources
- [Terraform Docs](https://www.terraform.io/docs)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Best Practices](https://www.terraform-best-practices.com/)

### Community
- [Terraform Forum](https://discuss.hashicorp.com/)
- [AWS Architecture Blog](https://aws.amazon.com/blogs/architecture/)
- [Terraform Registry](https://registry.terraform.io/)

---

## Version Information

- **Template Version:** 1.0.0
- **Terraform Required:** >= 1.5.0
- **AWS Provider:** ~> 5.0
- **Last Updated:** 2026-04-09

---

## Quick Tips

💡 **Start Small:** Begin with VPC and gradually add components

💡 **Test First:** Use dev environment before prod

💡 **Use Modules:** Convert templates to modules for reusability

💡 **Enable Logs:** CloudWatch logs are your friend

💡 **Tag Everything:** Consistent tagging helps with cost tracking

💡 **Version Control:** Always commit state file location to git

💡 **Review Plans:** Never skip the terraform plan review

💡 **Backup State:** Enable versioning on state bucket

💡 **Least Privilege:** Follow security best practices

💡 **Document Changes:** Keep architecture docs updated

---

**Ready to get started?** → [GETTING_STARTED.md](GETTING_STARTED.md)

**Need a quick command?** → [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

**Want all the details?** → [README.md](README.md)
