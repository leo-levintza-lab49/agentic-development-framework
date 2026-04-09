# Getting Started with Terraform Templates

This guide will walk you through using these Terraform templates to deploy AWS infrastructure.

## Prerequisites

### Required Software
- [ ] Terraform >= 1.5.0 ([Download](https://www.terraform.io/downloads))
- [ ] AWS CLI >= 2.0 ([Download](https://aws.amazon.com/cli/))
- [ ] Git ([Download](https://git-scm.com/downloads))
- [ ] Text editor (VS Code, Vim, etc.)

### Required AWS Resources
- [ ] AWS Account with appropriate permissions
- [ ] IAM user or role with admin access (for initial setup)
- [ ] S3 bucket for Terraform state (recommended)
- [ ] DynamoDB table for state locking (recommended)

### Verify Installation

```bash
# Check Terraform version
terraform version

# Check AWS CLI version
aws --version

# Verify AWS credentials
aws sts get-caller-identity
```

## Step 1: Prepare Your Environment

### Create Project Directory

```bash
# Create project directory
mkdir -p ~/projects/my-infrastructure
cd ~/projects/my-infrastructure

# Create subdirectories
mkdir -p {modules,environments/{dev,staging,prod}}
```

### Set Up AWS Credentials

```bash
# Option 1: Using AWS CLI configuration
aws configure

# Option 2: Using environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Option 3: Using AWS profiles
export AWS_PROFILE="your-profile-name"
```

## Step 2: Copy Templates

### Copy All Templates

```bash
# Copy all templates to your project
cp /path/to/templates/code-generation/terraform/*.template .

# Remove .template extension
for file in *.template; do
  mv "$file" "${file%.template}"
done
```

### Or Copy Selectively

```bash
# Copy only what you need
cp /path/to/templates/code-generation/terraform/main.tf.template ./main.tf
cp /path/to/templates/code-generation/terraform/variables.tf.template ./variables.tf
cp /path/to/templates/code-generation/terraform/outputs.tf.template ./outputs.tf
cp /path/to/templates/code-generation/terraform/vpc.tf.template ./vpc.tf
```

## Step 3: Configure Backend (Recommended)

### Create S3 Bucket for State

```bash
# Create S3 bucket
aws s3 mb s3://my-terraform-state-bucket --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket my-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket my-terraform-state-bucket \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Block public access
aws s3api put-public-access-block \
  --bucket my-terraform-state-bucket \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

### Create DynamoDB Table for Locking

```bash
# Create DynamoDB table
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

## Step 4: Replace Placeholders

### Method 1: Manual Replacement

Open each `.tf` file and search for `{{` to find placeholders. Replace them with your values.

### Method 2: Using Sed (Bash)

```bash
#!/bin/bash

# Define your values
PROJECT_NAME="my-application"
ENVIRONMENT="dev"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
VPC_NAME="my-vpc"
CIDR_BLOCK="10.0.0.0/16"
CLUSTER_NAME="my-cluster"
DB_NAME="myapp-db"

# Replace in all .tf files
for file in *.tf; do
  sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$file"
  sed -i.bak "s/{{ENVIRONMENT}}/$ENVIRONMENT/g" "$file"
  sed -i.bak "s/{{REGION}}/$REGION/g" "$file"
  sed -i.bak "s/{{ACCOUNT_ID}}/$ACCOUNT_ID/g" "$file"
  sed -i.bak "s/{{VPC_NAME}}/$VPC_NAME/g" "$file"
  sed -i.bak "s/{{CIDR_BLOCK}}/$CIDR_BLOCK/g" "$file"
  sed -i.bak "s/{{CLUSTER_NAME}}/$CLUSTER_NAME/g" "$file"
  sed -i.bak "s/{{DB_NAME}}/$DB_NAME/g" "$file"
done

# Remove backup files
rm *.bak

echo "Placeholders replaced successfully!"
```

### Method 3: Using Python

```python
#!/usr/bin/env python3

import glob
import subprocess

# Get AWS account ID
account_id = subprocess.check_output(
    ["aws", "sts", "get-caller-identity", "--query", "Account", "--output", "text"]
).decode().strip()

# Define replacements
replacements = {
    "{{PROJECT_NAME}}": "my-application",
    "{{ENVIRONMENT}}": "dev",
    "{{REGION}}": "us-east-1",
    "{{ACCOUNT_ID}}": account_id,
    "{{VPC_NAME}}": "my-vpc",
    "{{CIDR_BLOCK}}": "10.0.0.0/16",
    "{{CLUSTER_NAME}}": "my-cluster",
    "{{DB_NAME}}": "myapp-db",
    "{{TERRAFORM_STATE_BUCKET}}": "my-terraform-state-bucket",
    "{{TERRAFORM_LOCK_TABLE}}": "terraform-state-lock",
}

# Process all .tf files
for filepath in glob.glob("*.tf"):
    with open(filepath, 'r') as f:
        content = f.read()
    
    for old, new in replacements.items():
        content = content.replace(old, new)
    
    with open(filepath, 'w') as f:
        f.write(content)

print("Placeholders replaced successfully!")
```

### Verify Placeholders Replaced

```bash
# Check if any placeholders remain
grep -rn "{{" *.tf

# If nothing is returned, all placeholders are replaced!
```

## Step 5: Customize Configuration

### Review and Modify

1. **main.tf:** Review provider configuration and module calls
2. **variables.tf:** Adjust default values for your needs
3. **vpc.tf:** Verify CIDR blocks don't conflict with existing networks
4. **eks.tf:** Choose appropriate instance types and node counts
5. **rds.tf:** Select database instance class and storage
6. **security-group.tf:** Review security rules for your requirements

### Example Customizations

```hcl
# In variables.tf, change defaults
variable "instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.large"  # Changed from t3.medium
}

# In vpc.tf, adjust CIDR
locals {
  vpc_cidr = "172.16.0.0/16"  # Changed from 10.0.0.0/16
}

# In rds.tf, adjust backup retention
backup_retention_period = 14  # Changed from 7
```

## Step 6: Initialize Terraform

```bash
# Initialize Terraform
terraform init

# Expected output:
# Terraform has been successfully initialized!
```

### Troubleshooting Init

**Issue:** Backend configuration error
```bash
# Check S3 bucket and DynamoDB table exist
aws s3 ls s3://my-terraform-state-bucket
aws dynamodb describe-table --table-name terraform-state-lock
```

**Issue:** Provider download error
```bash
# Use specific provider versions
terraform init -upgrade
```

## Step 7: Validate and Plan

### Validate Configuration

```bash
# Validate Terraform syntax
terraform validate

# Expected output: Success! The configuration is valid.
```

### Format Code

```bash
# Format all .tf files
terraform fmt -recursive
```

### Create Execution Plan

```bash
# Generate and review plan
terraform plan -out=tfplan

# Save plan to file for review
terraform show tfplan > plan.txt
```

### Review the Plan

Look for:
- [ ] All expected resources will be created
- [ ] No unexpected deletions or changes
- [ ] Correct number of subnets, AZs, etc.
- [ ] Security groups have appropriate rules
- [ ] Tags are applied correctly
- [ ] Costs seem reasonable

## Step 8: Deploy Infrastructure

### Apply Configuration

```bash
# Apply the plan (this creates real resources!)
terraform apply tfplan

# Or apply with auto-approve (use with caution)
terraform apply -auto-approve
```

### Monitor Deployment

- EKS cluster creation: ~15-20 minutes
- RDS instance creation: ~10-15 minutes
- VPC and networking: ~2-5 minutes
- ALB creation: ~2-3 minutes

### Verify Deployment

```bash
# List all created resources
terraform state list

# Show specific resource
terraform state show aws_vpc.main

# Get outputs
terraform output

# Get specific output
terraform output vpc_id
```

## Step 9: Test Infrastructure

### Test VPC

```bash
# Verify VPC exists
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)

# Check subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

### Test EKS

```bash
# Update kubeconfig
aws eks update-kubeconfig \
  --region $(terraform output -raw region) \
  --name $(terraform output -raw cluster_id)

# Verify cluster
kubectl get nodes
kubectl get pods -A
```

### Test RDS

```bash
# Get RDS endpoint
terraform output db_instance_endpoint

# Test connection (if in VPC)
psql -h $(terraform output -raw db_instance_address) \
     -U admin \
     -d $(terraform output -raw db_name)
```

### Test ALB

```bash
# Get ALB DNS name
terraform output alb_dns_name

# Test HTTP (should redirect to HTTPS)
curl -I http://$(terraform output -raw alb_dns_name)

# Test HTTPS
curl -I https://$(terraform output -raw alb_dns_name)
```

## Step 10: Set Up Monitoring

### CloudWatch Dashboards

```bash
# List CloudWatch log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/$(terraform output -raw project_name)"
```

### Set Up Alarms

The templates include CloudWatch alarms for:
- RDS CPU utilization
- RDS free storage space
- RDS database connections
- ALB target response time
- ALB unhealthy hosts
- ALB 5XX errors
- S3 bucket size

Configure SNS topics for alarm notifications:

```bash
# Create SNS topic
aws sns create-topic --name my-app-alerts

# Subscribe email to topic
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:123456789012:my-app-alerts \
  --protocol email \
  --notification-endpoint your-email@example.com
```

## Step 11: Document Your Deployment

### Create Architecture Diagram

Use tools like:
- [draw.io](https://draw.io)
- [Lucidchart](https://www.lucidchart.com)
- [CloudCraft](https://www.cloudcraft.co/)

Or generate from Terraform:

```bash
# Generate graph
terraform graph | dot -Tpng > architecture.png
```

### Document Resources

Create a `RESOURCES.md` file:

```markdown
# Infrastructure Resources

## VPC
- VPC ID: vpc-xxxxx
- CIDR: 10.0.0.0/16
- Subnets: 9 (3 public, 3 private, 3 database)

## EKS Cluster
- Name: my-cluster
- Version: 1.28
- Endpoint: https://xxxxx.eks.us-east-1.amazonaws.com

## RDS Database
- Identifier: myapp-db
- Engine: PostgreSQL 15.4
- Endpoint: myapp-db.xxxxx.us-east-1.rds.amazonaws.com:5432

## Load Balancer
- Name: myapp-alb
- DNS: myapp-alb-xxxxx.us-east-1.elb.amazonaws.com
```

## Common Post-Deployment Tasks

### 1. Configure DNS

```bash
# Create Route53 record for ALB
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456789 \
  --change-batch file://dns-record.json
```

### 2. Set Up SSL Certificates

```bash
# Request ACM certificate
aws acm request-certificate \
  --domain-name example.com \
  --subject-alternative-names '*.example.com' \
  --validation-method DNS
```

### 3. Deploy Applications to EKS

```bash
# Deploy sample application
kubectl apply -f k8s-manifests/
```

### 4. Configure Backups

```bash
# RDS backups are automatic (configured in template)
# For additional backups, use AWS Backup

aws backup create-backup-plan --backup-plan file://backup-plan.json
```

### 5. Set Up Log Aggregation

```bash
# Ship logs to CloudWatch Logs Insights
# Or integrate with external logging (Datadog, Splunk, etc.)
```

## Cleanup (Development Only)

### Destroy Infrastructure

```bash
# Review what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Or destroy specific resources
terraform destroy -target=aws_eks_cluster.main
```

### Delete Backend Resources

```bash
# Empty S3 bucket
aws s3 rm s3://my-terraform-state-bucket --recursive

# Delete S3 bucket
aws s3 rb s3://my-terraform-state-bucket

# Delete DynamoDB table
aws dynamodb delete-table --table-name terraform-state-lock
```

## Next Steps

1. **Production Readiness:**
   - [ ] Enable Multi-AZ for all services
   - [ ] Set up monitoring and alerting
   - [ ] Configure automated backups
   - [ ] Implement disaster recovery
   - [ ] Set up CI/CD pipelines

2. **Security Hardening:**
   - [ ] Enable GuardDuty
   - [ ] Set up Security Hub
   - [ ] Configure AWS Config rules
   - [ ] Implement least privilege IAM
   - [ ] Enable encryption everywhere

3. **Cost Optimization:**
   - [ ] Set up AWS Budgets
   - [ ] Enable Cost Explorer
   - [ ] Configure Reserved Instances/Savings Plans
   - [ ] Implement auto-scaling
   - [ ] Clean up unused resources

4. **Automation:**
   - [ ] Set up Terraform Cloud/Enterprise
   - [ ] Implement GitOps workflows
   - [ ] Configure automated testing
   - [ ] Set up change management
   - [ ] Document runbooks

## Troubleshooting

### Common Issues

**Issue:** Insufficient IAM permissions
```bash
# Check IAM permissions
aws iam get-user
aws iam list-attached-user-policies --user-name your-username
```

**Issue:** Resource quota limits
```bash
# Check service quotas
aws service-quotas list-service-quotas --service-code vpc
aws service-quotas list-service-quotas --service-code ec2
```

**Issue:** State lock
```bash
# Force unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

**Issue:** Plan shows unwanted changes
```bash
# Refresh state
terraform refresh

# Import existing resources
terraform import aws_vpc.main vpc-xxxxx
```

## Getting Help

- **Terraform Documentation:** https://www.terraform.io/docs
- **AWS Provider Docs:** https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Community Support:** https://discuss.hashicorp.com/
- **AWS Support:** https://console.aws.amazon.com/support/

## Additional Resources

- [README.md](./README.md) - Comprehensive template documentation
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Quick reference guide
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
