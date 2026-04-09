# Terraform Infrastructure Code Generation Templates

This directory contains comprehensive Terraform templates for generating AWS infrastructure code. Each template follows AWS and Terraform best practices including security, high availability, monitoring, and cost optimization.

## Template Overview

| Template | Description | Key Features |
|----------|-------------|--------------|
| `main.tf.template` | Main entry point with provider configuration | S3 backend, multi-region support, module orchestration |
| `variables.tf.template` | Input variables with validation | All variable types, validation rules, optional attributes |
| `outputs.tf.template` | Output values for resources | Comprehensive outputs, sensitive data handling |
| `vpc.tf.template` | VPC with networking components | Multi-AZ, NAT gateways, VPC Flow Logs |
| `eks.tf.template` | EKS cluster with node groups | OIDC provider, managed node groups, add-ons |
| `rds.tf.template` | PostgreSQL RDS instance | Encryption, automated backups, CloudWatch alarms |
| `s3.tf.template` | S3 bucket with security | Versioning, encryption, lifecycle policies |
| `alb.tf.template` | Application Load Balancer | HTTPS, blue/green deployment, access logs |
| `security-group.tf.template` | Security group with rules | Common ports, dynamic rules, VPC integration |
| `iam-role.tf.template` | IAM roles and policies | Trust relationships, policy documents, service roles |

## Quick Start

### 1. Choose a Template

```bash
# Copy the template you need
cp vpc.tf.template my-project/vpc.tf
```

### 2. Replace Placeholders

Search and replace the following placeholders with your values:

**Common Placeholders:**
- `{{PROJECT_NAME}}` - Your project name (e.g., "my-app")
- `{{ENVIRONMENT}}` - Environment (dev, staging, prod)
- `{{REGION}}` - AWS region (e.g., "us-east-1")
- `{{ACCOUNT_ID}}` - Your AWS account ID

**Resource-Specific Placeholders:**
- See individual template sections below for resource-specific placeholders

### 3. Initialize and Apply

```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply configuration
terraform apply
```

## Detailed Template Documentation

### 1. Main Configuration (`main.tf.template`)

**Purpose:** Main entry point for Terraform configuration with provider setup and module orchestration.

**Placeholders:**
- `{{PROJECT_NAME}}` - Project name
- `{{REGION}}` - Primary AWS region
- `{{SECONDARY_REGION}}` - Secondary region for multi-region setup
- `{{ACCOUNT_ID}}` - AWS account ID
- `{{ENVIRONMENT}}` - Environment name
- `{{TERRAFORM_STATE_BUCKET}}` - S3 bucket for state storage
- `{{TERRAFORM_LOCK_TABLE}}` - DynamoDB table for state locking
- `{{TERRAFORM_KMS_KEY_ID}}` - KMS key for state encryption
- `{{REPOSITORY_URL}}` - Git repository URL
- `{{TEAM_NAME}}` - Team or owner name
- `{{DOMAIN_NAME}}` - Domain name for the application

**Features:**
- AWS provider with default tags
- S3 backend with state locking
- Multi-region provider aliases
- Kubernetes and Helm provider configuration
- Common data sources (account, region, AZs)
- Module integration (VPC, EKS, RDS, ALB, S3)
- Local values and naming conventions

**Example:**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "my-app/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### 2. Variables (`variables.tf.template`)

**Purpose:** Comprehensive input variables with validation and documentation.

**Placeholders:**
- `{{VAR_NAME}}` - Variable name
- `{{VAR_TYPE}}` - Variable type
- `{{VAR_DEFAULT}}` - Default value
- `{{VAR_DESCRIPTION}}` - Variable description
- `{{PROJECT_NAME}}` - Project name
- `{{ENVIRONMENT}}` - Environment name
- `{{REGION}}` - AWS region
- `{{AZ1}}`, `{{AZ2}}`, `{{AZ3}}` - Availability zones

**Variable Types Included:**
- String (with regex validation)
- Number (with range validation)
- Boolean
- List (with element validation)
- Map
- Object (simple and nested)
- Set
- Tuple
- Any (use sparingly)
- Optional attributes (Terraform 1.3+)

**Example:**
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

### 3. Outputs (`outputs.tf.template`)

**Purpose:** Output values for created resources with comprehensive documentation.

**Placeholders:**
- `{{OUTPUT_NAME}}` - Output name
- `{{OUTPUT_VALUE}}` - Output value expression
- `{{OUTPUT_DESCRIPTION}}` - Output description
- `{{SENSITIVE_VALUE}}` - Sensitive output value

**Output Categories:**
- VPC (ID, CIDR, subnet IDs)
- EKS (cluster endpoint, OIDC issuer)
- RDS (endpoint, connection string)
- S3 (bucket ARN, domain name)
- ALB (DNS name, target group ARN)
- Security Groups (ID, ARN)
- IAM (role ARN, policy ARN)

**Features:**
- Sensitive output marking
- Conditional outputs
- For expressions
- Map and object outputs
- Formatted strings
- Debug information

### 4. VPC (`vpc.tf.template`)

**Purpose:** Production-ready VPC with multi-AZ networking.

**Placeholders:**
- `{{VPC_NAME}}` - VPC name
- `{{CIDR_BLOCK}}` - VPC CIDR block (e.g., "10.0.0.0/16")
- `{{ENVIRONMENT}}` - Environment name
- `{{PROJECT}}` - Project name

**Features:**
- Multi-AZ deployment (3 AZs by default)
- Public, private, and database subnets
- NAT gateways (one per AZ)
- Internet gateway
- Route tables with proper associations
- VPC Flow Logs to CloudWatch
- Kubernetes subnet tags
- Automatic CIDR calculation

**Resources Created:**
- 1 VPC
- 1 Internet Gateway
- 3 NAT Gateways (with Elastic IPs)
- 9 Subnets (3 public, 3 private, 3 database)
- 5 Route Tables
- VPC Flow Logs
- IAM role for Flow Logs

### 5. EKS Cluster (`eks.tf.template`)

**Purpose:** Production-ready EKS cluster with managed node groups.

**Placeholders:**
- `{{CLUSTER_NAME}}` - EKS cluster name
- `{{REGION}}` - AWS region
- `{{KUBERNETES_VERSION}}` - Kubernetes version (e.g., "1.28")
- `{{VPC_ID}}` - VPC ID
- `{{SUBNET_IDS}}` - List of subnet IDs
- `{{INSTANCE_TYPE}}` - Node instance type
- `{{DESIRED_SIZE}}`, `{{MAX_SIZE}}`, `{{MIN_SIZE}}` - Node group scaling
- `{{DISK_SIZE}}` - Node disk size in GB
- `{{VPC_CNI_VERSION}}`, `{{KUBE_PROXY_VERSION}}`, `{{COREDNS_VERSION}}` - Add-on versions

**Features:**
- EKS cluster with encryption
- Managed node groups
- OIDC provider for IRSA
- IAM roles for cluster and nodes
- Security groups
- CloudWatch logs
- KMS encryption for secrets
- EKS add-ons (VPC CNI, kube-proxy, CoreDNS)
- IAM role for VPC CNI

**Resources Created:**
- 1 EKS cluster
- 1 managed node group
- 2 IAM roles (cluster, nodes)
- 1 OIDC provider
- 1 security group
- 1 KMS key
- 3 EKS add-ons

### 6. RDS Database (`rds.tf.template`)

**Purpose:** Production-ready PostgreSQL RDS instance.

**Placeholders:**
- `{{DB_NAME}}` - Database identifier
- `{{INSTANCE_CLASS}}` - Instance class (e.g., "db.t3.medium")
- `{{ENGINE_VERSION}}` - PostgreSQL version (e.g., "15.4")
- `{{USERNAME}}` - Master username
- `{{VPC_ID}}` - VPC ID
- `{{SUBNET_IDS}}` - List of database subnet IDs
- `{{VPC_CIDR_BLOCK}}` - VPC CIDR for security group
- `{{ALLOCATED_STORAGE}}` - Initial storage in GB
- `{{MAX_ALLOCATED_STORAGE}}` - Max storage for autoscaling
- `{{IOPS}}`, `{{THROUGHPUT}}` - Storage performance
- `{{MULTI_AZ}}` - Multi-AZ deployment (true/false)
- `{{BACKUP_RETENTION_PERIOD}}` - Backup retention in days
- `{{DELETION_PROTECTION}}` - Deletion protection (true/false)
- `{{MAX_CONNECTIONS}}` - Max database connections
- `{{PARAMETER_GROUP_FAMILY}}` - Parameter group family (e.g., "15")
- `{{MAJOR_ENGINE_VERSION}}` - Major engine version (e.g., "15")

**Features:**
- Encrypted storage with KMS
- Random password generation
- Password stored in Secrets Manager
- Automated backups
- Enhanced monitoring
- Performance Insights
- CloudWatch logs
- Parameter group optimization
- Multi-AZ support
- CloudWatch alarms (CPU, storage, connections)

**Resources Created:**
- 1 RDS instance
- 1 DB subnet group
- 1 parameter group
- 1 option group
- 1 security group
- 1 KMS key
- 1 Secrets Manager secret
- 1 IAM role for monitoring
- 3 CloudWatch alarms

### 7. S3 Bucket (`s3.tf.template`)

**Purpose:** Secure S3 bucket with encryption and lifecycle policies.

**Placeholders:**
- `{{BUCKET_NAME}}` - S3 bucket name
- `{{ENVIRONMENT}}` - Environment name
- `{{PROJECT}}` - Project name
- `{{ACCOUNT_ID}}` - AWS account ID
- `{{TRANSITION_TO_IA_DAYS}}` - Days to transition to IA (e.g., 30)
- `{{TRANSITION_TO_GLACIER_DAYS}}` - Days to transition to Glacier (e.g., 90)
- `{{TRANSITION_TO_DEEP_ARCHIVE_DAYS}}` - Days to Deep Archive (e.g., 365)
- `{{NONCURRENT_TRANSITION_DAYS}}` - Days for noncurrent versions (e.g., 30)
- `{{NONCURRENT_EXPIRATION_DAYS}}` - Days to expire old versions (e.g., 90)
- `{{ALLOWED_ORIGINS}}` - CORS allowed origins
- `{{BUCKET_SIZE_THRESHOLD}}` - CloudWatch alarm threshold in bytes

**Features:**
- Server-side encryption with KMS
- Versioning enabled
- Public access blocked
- Access logging
- Lifecycle policies (IA, Glacier, Deep Archive)
- Bucket policy (enforce HTTPS, encryption)
- CORS configuration
- Intelligent-Tiering
- Bucket inventory
- CloudWatch metrics and alarms

**Resources Created:**
- 2 S3 buckets (main + logs)
- 1 KMS key
- Lifecycle rules
- Bucket policies
- Inventory configuration
- CloudWatch alarm

### 8. Application Load Balancer (`alb.tf.template`)

**Purpose:** ALB with HTTPS, listeners, and target groups.

**Placeholders:**
- `{{ALB_NAME}}` - Load balancer name
- `{{VPC_ID}}` - VPC ID
- `{{SUBNET_IDS}}` - List of public subnet IDs
- `{{CERTIFICATE_ARN}}` - ACM certificate ARN
- `{{INTERNAL}}` - Internal or internet-facing (true/false)
- `{{DELETION_PROTECTION}}` - Deletion protection (true/false)
- `{{TARGET_PORT}}` - Target port (e.g., 8080)
- `{{TARGET_TYPE}}` - Target type (ip, instance, lambda)
- `{{HEALTH_CHECK_PATH}}` - Health check path (e.g., "/health")
- `{{HOST_HEADER}}` - Host header for routing
- `{{LOG_RETENTION_DAYS}}` - Access log retention days
- `{{BLUE_WEIGHT}}`, `{{GREEN_WEIGHT}}` - Blue/green deployment weights

**Features:**
- HTTPS listener with SSL
- HTTP to HTTPS redirect
- Access logs to S3
- Multiple target groups
- Path-based routing
- Host-based routing
- Weighted routing (blue/green)
- Health checks with stickiness
- CloudWatch alarms
- Security group

**Resources Created:**
- 1 ALB
- 1 S3 bucket for logs
- 3 target groups (app, blue, green)
- 2 listeners (HTTP, HTTPS)
- Multiple listener rules
- 1 security group
- 3 CloudWatch alarms

### 9. Security Group (`security-group.tf.template`)

**Purpose:** Security group with comprehensive rule examples.

**Placeholders:**
- `{{SG_NAME}}` - Security group name
- `{{VPC_ID}}` - VPC ID
- `{{DESCRIPTION}}` - Security group description
- `{{HTTP_CIDR_BLOCKS}}`, `{{HTTPS_CIDR_BLOCKS}}` - Allowed CIDR blocks
- `{{APP_PORT}}`, `{{APP_CIDR_BLOCKS}}` - Application port and CIDRs
- `{{SSH_CIDR_BLOCKS}}` - SSH allowed CIDRs
- `{{POSTGRES_CIDR_BLOCKS}}` - PostgreSQL allowed CIDRs
- `{{MYSQL_CIDR_BLOCKS}}` - MySQL allowed CIDRs
- `{{REDIS_CIDR_BLOCKS}}` - Redis allowed CIDRs
- `{{FROM_SG_PORT}}`, `{{SOURCE_SECURITY_GROUP_ID}}` - Cross-SG rules
- `{{PORT_RANGE_START}}`, `{{PORT_RANGE_END}}` - Port ranges
- Various other service-specific placeholders

**Features:**
- Common port rules (HTTP, HTTPS, SSH, databases)
- Security group reference rules
- Port ranges
- ICMP support
- Self-referencing rules
- Dynamic rules with for_each
- VPC endpoint support
- Kubernetes NodePort range
- CloudWatch log group

**Rules Included:**
- HTTP (80)
- HTTPS (443)
- SSH (22)
- PostgreSQL (5432)
- MySQL (3306)
- Redis (6379)
- NFS (2049)
- Kubernetes NodePort (30000-32767)
- Custom ports and ranges

### 10. IAM Role (`iam-role.tf.template`)

**Purpose:** IAM roles with trust relationships and policies.

**Placeholders:**
- `{{ROLE_NAME}}` - IAM role name
- `{{ROLE_DESCRIPTION}}` - Role description
- `{{SERVICE}}` - AWS service for trust relationship
- `{{POLICY_ACTIONS}}` - List of allowed actions
- `{{RESOURCES}}` - List of allowed resources
- `{{MAX_SESSION_DURATION}}` - Max session duration in seconds
- `{{ACCOUNT_ID}}` - AWS account ID
- `{{EXTERNAL_ID}}` - External ID for cross-account access
- `{{OIDC_PROVIDER_ARN}}`, `{{OIDC_PROVIDER_URL}}` - OIDC configuration
- `{{SERVICE_ACCOUNT}}` - Kubernetes service account
- Various resource-specific placeholders

**Features:**
- Service principal trust relationships
- Account principal trust
- Federated (OIDC) trust
- SAML federation
- Policy documents with multiple statements
- S3, DynamoDB, Secrets Manager access
- CloudWatch Logs access
- KMS encryption
- EC2 network interface access
- Conditional access
- AWS managed policy attachments
- Inline policies
- Instance profiles
- Service-specific roles (Lambda, ECS, CodeBuild)

**Trust Relationships:**
- AWS Service (Lambda, EC2, ECS, etc.)
- AWS Account (cross-account)
- OIDC Provider (EKS IRSA)
- SAML Federation

## Usage Examples

### Example 1: Creating a Complete Infrastructure

```bash
# 1. Create a new project directory
mkdir my-infra && cd my-infra

# 2. Copy all templates
cp /path/to/templates/*.tf.template .

# 3. Rename templates
for f in *.template; do mv "$f" "${f%.template}"; done

# 4. Replace placeholders (using sed or your editor)
sed -i 's/{{PROJECT_NAME}}/my-app/g' *.tf
sed -i 's/{{ENVIRONMENT}}/prod/g' *.tf
sed -i 's/{{REGION}}/us-east-1/g' *.tf

# 5. Initialize and apply
terraform init
terraform plan
terraform apply
```

### Example 2: Using Individual Templates

```bash
# Copy just the VPC template
cp vpc.tf.template infrastructure/vpc.tf

# Replace placeholders
sed -i 's/{{VPC_NAME}}/my-vpc/g' infrastructure/vpc.tf
sed -i 's/{{CIDR_BLOCK}}/10.0.0.0\/16/g' infrastructure/vpc.tf
```

### Example 3: Module-Based Approach

```bash
# Create module structure
mkdir -p modules/{vpc,eks,rds}

# Copy templates to modules
cp vpc.tf.template modules/vpc/main.tf
cp eks.tf.template modules/eks/main.tf
cp rds.tf.template modules/rds/main.tf

# Copy variables and outputs
cp variables.tf.template modules/vpc/variables.tf
cp outputs.tf.template modules/vpc/outputs.tf
```

## Best Practices

### 1. Security
- Always enable encryption at rest (KMS)
- Enable encryption in transit (HTTPS, SSL)
- Use Secrets Manager for sensitive data
- Block public access to S3 buckets
- Enable VPC Flow Logs
- Use security groups with least privilege
- Enable MFA delete for S3
- Rotate KMS keys annually

### 2. High Availability
- Deploy across multiple AZs (minimum 3)
- Use Multi-AZ for databases
- Deploy NAT gateways per AZ
- Use Auto Scaling for compute
- Configure health checks
- Set up CloudWatch alarms

### 3. Cost Optimization
- Use single NAT gateway for non-production
- Right-size instance types
- Enable S3 lifecycle policies
- Use Intelligent-Tiering for S3
- Set up budget alerts
- Clean up unused resources

### 4. Monitoring
- Enable CloudWatch logs
- Set up CloudWatch alarms
- Use Performance Insights for RDS
- Enable Enhanced Monitoring
- Configure access logs
- Use X-Ray for tracing

### 5. Backup and Recovery
- Enable automated backups
- Set appropriate retention periods
- Enable versioning for S3
- Use cross-region replication
- Test restore procedures
- Document recovery procedures

### 6. Terraform Best Practices
- Use remote state (S3) with locking
- Enable state encryption
- Use workspaces for environments
- Implement proper tagging
- Use modules for reusability
- Pin provider versions
- Use data sources for dynamic values
- Implement variable validation
- Document outputs clearly

## Placeholder Reference

### Common Placeholders

| Placeholder | Description | Example Value |
|-------------|-------------|---------------|
| `{{PROJECT_NAME}}` | Project name | "my-application" |
| `{{ENVIRONMENT}}` | Environment | "prod" |
| `{{REGION}}` | AWS region | "us-east-1" |
| `{{ACCOUNT_ID}}` | AWS account ID | "123456789012" |
| `{{VPC_ID}}` | VPC ID | "vpc-xxxxx" |
| `{{SUBNET_IDS}}` | Subnet IDs | ["subnet-xxx", "subnet-yyy"] |

### Resource-Specific Placeholders

See individual template sections above for comprehensive placeholder lists.

## Customization Guide

### Adding Custom Rules

1. **Security Group Rules:**
```hcl
resource "aws_security_group_rule" "custom" {
  type              = "ingress"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.main.id
}
```

2. **IAM Policies:**
```hcl
statement {
  sid    = "CustomAccess"
  effect = "Allow"
  actions = ["s3:GetObject"]
  resources = ["arn:aws:s3:::my-bucket/*"]
}
```

3. **Lifecycle Rules:**
```hcl
rule {
  id     = "custom-transition"
  status = "Enabled"
  transition {
    days          = 60
    storage_class = "GLACIER"
  }
}
```

## Troubleshooting

### Common Issues

1. **State Lock Error:**
   - Check DynamoDB table exists
   - Verify IAM permissions
   - Release stuck locks manually

2. **Provider Version Conflicts:**
   - Run `terraform init -upgrade`
   - Check required_providers block
   - Pin to specific versions

3. **Placeholder Not Replaced:**
   - Search for `{{` in files
   - Use grep: `grep -r "{{" .`
   - Replace manually or with script

4. **Resource Already Exists:**
   - Import existing resource
   - Use `terraform import`
   - Check state file

## Contributing

To add new templates:

1. Follow existing template structure
2. Include comprehensive comments
3. Use clear placeholder names
4. Add validation where applicable
5. Document all placeholders
6. Include usage examples
7. Add to this README

## Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## Version History

- **1.0.0** (2026-04-09): Initial release with 10 comprehensive templates

## License

These templates are provided as-is for use in your projects. Modify as needed for your requirements.
