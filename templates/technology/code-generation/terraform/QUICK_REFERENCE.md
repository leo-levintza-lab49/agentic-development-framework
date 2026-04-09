# Terraform Templates Quick Reference

## Template Summary

| File | Size | Lines | Description |
|------|------|-------|-------------|
| `main.tf.template` | 13KB | ~400 | Provider config, backend, modules |
| `variables.tf.template` | 13KB | ~450 | Input variables with validation |
| `outputs.tf.template` | 15KB | ~400 | Output values for all resources |
| `vpc.tf.template` | 7KB | ~250 | VPC with multi-AZ networking |
| `eks.tf.template` | 9KB | ~300 | EKS cluster with node groups |
| `rds.tf.template` | 10KB | ~350 | PostgreSQL RDS with monitoring |
| `s3.tf.template` | 10KB | ~350 | S3 bucket with security features |
| `alb.tf.template` | 11KB | ~400 | ALB with HTTPS and blue/green |
| `security-group.tf.template` | 10KB | ~350 | Security groups with common rules |
| `iam-role.tf.template` | 10KB | ~400 | IAM roles with trust policies |

## Common Commands

```bash
# Find all placeholders
grep -rn "{{" *.tf

# Replace placeholder in all files
sed -i 's/{{PROJECT_NAME}}/my-app/g' *.tf

# Replace placeholder in single file
sed -i 's/{{VPC_NAME}}/my-vpc/g' vpc.tf

# Validate after placeholder replacement
terraform validate

# Format code
terraform fmt -recursive

# Generate dependency graph
terraform graph | dot -Tpng > graph.png
```

## Essential Placeholders by Template

### main.tf.template
```
{{PROJECT_NAME}}
{{REGION}}
{{ACCOUNT_ID}}
{{ENVIRONMENT}}
{{TERRAFORM_STATE_BUCKET}}
{{TERRAFORM_LOCK_TABLE}}
{{DOMAIN_NAME}}
```

### vpc.tf.template
```
{{VPC_NAME}}
{{CIDR_BLOCK}}
{{ENVIRONMENT}}
{{PROJECT}}
```

### eks.tf.template
```
{{CLUSTER_NAME}}
{{REGION}}
{{KUBERNETES_VERSION}}
{{VPC_ID}}
{{SUBNET_IDS}}
{{INSTANCE_TYPE}}
{{DESIRED_SIZE}}
{{MAX_SIZE}}
{{MIN_SIZE}}
```

### rds.tf.template
```
{{DB_NAME}}
{{INSTANCE_CLASS}}
{{ENGINE_VERSION}}
{{USERNAME}}
{{VPC_ID}}
{{SUBNET_IDS}}
{{ALLOCATED_STORAGE}}
{{MULTI_AZ}}
{{BACKUP_RETENTION_PERIOD}}
```

### s3.tf.template
```
{{BUCKET_NAME}}
{{ENVIRONMENT}}
{{PROJECT}}
{{ACCOUNT_ID}}
{{TRANSITION_TO_IA_DAYS}}
{{TRANSITION_TO_GLACIER_DAYS}}
```

### alb.tf.template
```
{{ALB_NAME}}
{{VPC_ID}}
{{SUBNET_IDS}}
{{CERTIFICATE_ARN}}
{{TARGET_PORT}}
{{HEALTH_CHECK_PATH}}
```

### security-group.tf.template
```
{{SG_NAME}}
{{VPC_ID}}
{{DESCRIPTION}}
{{HTTP_CIDR_BLOCKS}}
{{APP_PORT}}
```

### iam-role.tf.template
```
{{ROLE_NAME}}
{{SERVICE}}
{{POLICY_ACTIONS}}
{{RESOURCES}}
{{ACCOUNT_ID}}
```

## Typical Values

```bash
# Project
PROJECT_NAME="my-application"
ENVIRONMENT="prod"
REGION="us-east-1"
ACCOUNT_ID="123456789012"

# VPC
VPC_NAME="my-vpc"
CIDR_BLOCK="10.0.0.0/16"

# EKS
CLUSTER_NAME="my-cluster"
KUBERNETES_VERSION="1.28"
INSTANCE_TYPE="t3.medium"
DESIRED_SIZE=3
MAX_SIZE=5
MIN_SIZE=2

# RDS
DB_NAME="myapp-db"
INSTANCE_CLASS="db.t3.medium"
ENGINE_VERSION="15.4"
ALLOCATED_STORAGE=100
MULTI_AZ=true
BACKUP_RETENTION_PERIOD=7

# S3
BUCKET_NAME="myapp-data-bucket"
TRANSITION_TO_IA_DAYS=30
TRANSITION_TO_GLACIER_DAYS=90

# ALB
ALB_NAME="myapp-alb"
TARGET_PORT=8080
HEALTH_CHECK_PATH="/health"

# Security Group
SG_NAME="myapp-sg"
APP_PORT=8080
```

## Replacement Scripts

### Bash Script
```bash
#!/bin/bash

# Define variables
PROJECT_NAME="my-app"
ENVIRONMENT="prod"
REGION="us-east-1"
ACCOUNT_ID="123456789012"

# Replace in all .tf files
for file in *.tf; do
  sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$file"
  sed -i "s/{{ENVIRONMENT}}/$ENVIRONMENT/g" "$file"
  sed -i "s/{{REGION}}/$REGION/g" "$file"
  sed -i "s/{{ACCOUNT_ID}}/$ACCOUNT_ID/g" "$file"
done

echo "Placeholders replaced successfully!"
```

### Python Script
```python
#!/usr/bin/env python3
import glob
import re

replacements = {
    "{{PROJECT_NAME}}": "my-app",
    "{{ENVIRONMENT}}": "prod",
    "{{REGION}}": "us-east-1",
    "{{ACCOUNT_ID}}": "123456789012",
}

for filepath in glob.glob("*.tf"):
    with open(filepath, 'r') as f:
        content = f.read()
    
    for old, new in replacements.items():
        content = content.replace(old, new)
    
    with open(filepath, 'w') as f:
        f.write(content)

print("Placeholders replaced successfully!")
```

## Resource Costs (Rough Estimates)

| Resource | Configuration | Monthly Cost |
|----------|---------------|--------------|
| VPC | Standard with 3 NAT Gateways | ~$100 |
| EKS | Control Plane | $73 |
| EKS | 3x t3.medium nodes | ~$100 |
| RDS | db.t3.medium, Multi-AZ | ~$200 |
| S3 | 100GB with IA/Glacier | ~$3-10 |
| ALB | Standard usage | ~$20-30 |
| NAT Gateway | 3x with 100GB transfer | ~$100 |
| KMS | 3 keys | ~$3 |
| **Total** | **Production Setup** | **~$600-700/month** |

### Cost Optimization Tips
- Use single NAT gateway for dev/staging
- Use smaller instance types for non-prod
- Enable S3 Intelligent-Tiering
- Use RDS autoscaling storage
- Implement Auto Scaling for compute
- Set up AWS Budgets alerts

## Validation Checklist

### Before Apply
- [ ] All placeholders replaced
- [ ] Backend configuration correct
- [ ] AWS credentials configured
- [ ] Correct AWS account ID
- [ ] VPC CIDR doesn't conflict
- [ ] Subnet calculations correct
- [ ] Security groups reviewed
- [ ] IAM policies reviewed
- [ ] Tags applied consistently

### After Apply
- [ ] VPC and subnets created
- [ ] NAT gateways functional
- [ ] EKS cluster accessible
- [ ] Database connectivity works
- [ ] ALB health checks passing
- [ ] S3 buckets encrypted
- [ ] CloudWatch logs flowing
- [ ] Backups configured
- [ ] Monitoring alarms set
- [ ] Cost allocation tags applied

## Terraform State Commands

```bash
# List resources in state
terraform state list

# Show resource details
terraform state show aws_vpc.main

# Remove resource from state (careful!)
terraform state rm aws_instance.example

# Move resource in state
terraform state mv aws_instance.old aws_instance.new

# Pull remote state
terraform state pull > terraform.tfstate.backup

# Push state (dangerous!)
terraform state push terraform.tfstate
```

## Module Usage Pattern

```hcl
# In root main.tf
module "vpc" {
  source = "./modules/vpc"
  
  vpc_name    = "my-vpc"
  cidr_block  = "10.0.0.0/16"
  environment = "prod"
}

module "eks" {
  source = "./modules/eks"
  
  cluster_name = "my-cluster"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
```

## Import Existing Resources

```bash
# Import VPC
terraform import aws_vpc.main vpc-xxxxx

# Import subnet
terraform import aws_subnet.public[0] subnet-xxxxx

# Import security group
terraform import aws_security_group.main sg-xxxxx

# Import RDS instance
terraform import aws_db_instance.main mydb

# Import S3 bucket
terraform import aws_s3_bucket.main my-bucket
```

## Common Issues & Solutions

### Issue: Cycle Error
**Solution:** Use `depends_on` or restructure dependencies

### Issue: State Lock
**Solution:** 
```bash
terraform force-unlock <LOCK_ID>
```

### Issue: Resource Already Exists
**Solution:** Import the resource or remove from configuration

### Issue: Provider Version Conflict
**Solution:**
```bash
terraform init -upgrade
```

### Issue: Plan Shows Unwanted Changes
**Solution:** Use lifecycle blocks
```hcl
lifecycle {
  ignore_changes = [tags]
}
```

## Security Checklist

- [ ] KMS encryption enabled for all data stores
- [ ] S3 buckets block public access
- [ ] VPC Flow Logs enabled
- [ ] Security groups follow least privilege
- [ ] IAM roles use principle of least privilege
- [ ] Secrets stored in Secrets Manager/Parameter Store
- [ ] HTTPS/TLS enforced
- [ ] Multi-AZ enabled for production databases
- [ ] Automated backups configured
- [ ] CloudWatch alarms set up
- [ ] Access logging enabled
- [ ] State file encrypted
- [ ] No hardcoded credentials in code

## Performance Optimization

1. **VPC:** Use VPC endpoints for AWS services
2. **EKS:** Use cluster autoscaler and HPA
3. **RDS:** Enable Performance Insights, tune parameters
4. **S3:** Use CloudFront for static content
5. **ALB:** Enable connection draining, set proper timeouts
6. **General:** Use caching where possible (ElastiCache)

## Tags Strategy

```hcl
default_tags {
  tags = {
    Project     = "my-app"
    Environment = "prod"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
    Owner       = "platform-team"
    Compliance  = "pci"
    Backup      = "daily"
  }
}
```

## Next Steps After Deployment

1. Configure DNS records in Route53
2. Set up ACM certificates
3. Configure monitoring dashboards
4. Set up log aggregation
5. Implement backup verification
6. Document architecture
7. Create runbooks
8. Set up CI/CD pipelines
9. Implement disaster recovery
10. Conduct security audit

## Resources

- [AWS Pricing Calculator](https://calculator.aws/)
- [Terraform Registry](https://registry.terraform.io/)
- [AWS Well-Architected Tool](https://aws.amazon.com/well-architected-tool/)
- [Terraform Cloud](https://app.terraform.io/)
