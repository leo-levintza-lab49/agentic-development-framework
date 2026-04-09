# Template Engine - Quick Start Guide

## Installation

```bash
# Source the library
source scripts/lib/template-engine.sh
```

## Basic Usage

### 1. Generate a Single File

```bash
generate_file \
    "src/main/java/UserController.java" \
    "/path/to/repo" \
    "user-service" \
    "Add user management" \
    "feature/user"
```

### 2. Generate from PR Configuration

**Create PR config** (`config/pr-123.json`):
```json
{
  "title": "Add user management endpoints",
  "branch": "feature/user",
  "repo": "user-service",
  "files": [
    "src/main/java/controller/UserController.java",
    "src/main/java/service/UserService.java",
    "src/main/java/repository/UserRepository.java"
  ]
}
```

**Generate files**:
```bash
generate_pr_code 123 config/pr-123.json /path/to/repo
```

### 3. Batch Process Multiple PRs

```bash
# Process all PR configs in directory
generate_all_prs config/prs /path/to/repo
```

## Quick Examples

### Java Spring Boot

```bash
# Controller
generate_file "src/main/java/UserController.java" "$REPO" "user-service"

# Service
generate_file "src/main/java/UserService.java" "$REPO" "user-service"

# Entity
generate_file "src/main/java/UserEntity.java" "$REPO" "user-service"
```

### React Components

```bash
# Component
generate_file "src/components/UserProfile.tsx" "$REPO" "user-ui"

# Hook
generate_file "src/hooks/useAuth.ts" "$REPO" "user-ui"

# API Service
generate_file "src/services/api.service.ts" "$REPO" "user-ui"
```

### Node.js TypeScript

```bash
# Service
generate_file "src/services/user.service.ts" "$REPO" "user-api"

# Controller
generate_file "src/controllers/user.controller.ts" "$REPO" "user-api"

# Model
generate_file "src/models/user.model.ts" "$REPO" "user-api"
```

### Database

```bash
# Create table migration
generate_file "migrations/001_create_users_table.sql" "$REPO" "user-service"

# Add index
generate_file "migrations/002_add_user_indexes.sql" "$REPO" "user-service"
```

### Kubernetes

```bash
# Deployment
generate_file "k8s/deployment.yaml" "$REPO" "user-service"

# Service
generate_file "k8s/service.yaml" "$REPO" "user-service"

# Ingress
generate_file "k8s/ingress.yaml" "$REPO" "user-service"
```

### Terraform

```bash
# VPC
generate_file "infrastructure/vpc.tf" "$REPO" "infrastructure"

# RDS
generate_file "infrastructure/rds.tf" "$REPO" "infrastructure"

# S3
generate_file "infrastructure/s3.tf" "$REPO" "infrastructure"
```

## Common Patterns

### Full-Stack Feature

```bash
# Backend (Java)
generate_file "src/main/java/OrderController.java" "$REPO" "order-service"
generate_file "src/main/java/OrderService.java" "$REPO" "order-service"
generate_file "src/main/java/OrderRepository.java" "$REPO" "order-service"

# Frontend (React)
generate_file "src/components/OrderList.tsx" "$UI_REPO" "order-ui"
generate_file "src/services/order.service.ts" "$UI_REPO" "order-ui"

# Database
generate_file "migrations/001_create_orders_table.sql" "$REPO" "order-service"

# Infrastructure
generate_file "k8s/deployment.yaml" "$REPO" "order-service"
```

### Microservice Setup

```bash
REPO="/tmp/payment-service"
SERVICE="payment-service"

# Application layer
generate_file "src/main/java/PaymentController.java" "$REPO" "$SERVICE"
generate_file "src/main/java/PaymentService.java" "$REPO" "$SERVICE"
generate_file "src/main/java/PaymentRepository.java" "$REPO" "$SERVICE"
generate_file "src/main/java/PaymentEntity.java" "$REPO" "$SERVICE"

# Data layer
generate_file "migrations/001_create_payments_table.sql" "$REPO" "$SERVICE"

# Infrastructure
generate_file "k8s/deployment.yaml" "$REPO" "$SERVICE"
generate_file "k8s/service.yaml" "$REPO" "$SERVICE"
generate_file "k8s/configmap.yaml" "$REPO" "$SERVICE"
```

## Testing

### Run Unit Tests
```bash
./scripts/lib/test-template-engine.sh
```

### Run Integration Tests
```bash
./scripts/lib/integration-test.sh
```

### Run Example Demos
```bash
./scripts/lib/example-usage.sh
```

## Utility Functions

### Template Selection
```bash
# Find which template will be used
template=$(select_template "UserController.java")
echo $template
# Output: .../java-spring-boot/controller.java.template
```

### Variable Extraction
```bash
# See what variables will be generated
vars=$(extract_variables "UserController.java" "user-service" "Add users" "feature/user")
echo "$vars" | grep ENTITY_NAME
# Output: ENTITY_NAME=User
```

### List Available Templates
```bash
# Show all available templates
list_templates
```

### Test Template Selection
```bash
# Test template matching for various files
test_template_selection
```

## File Type Support

| Extension | Technology | Example |
|-----------|-----------|---------|
| `.java` | Java Spring Boot | `UserController.java` |
| `.ts` | TypeScript/Node.js | `user.service.ts` |
| `.tsx` | React/TypeScript | `UserProfile.tsx` |
| `.sql` | Database | `001_create_users.sql` |
| `.yaml`, `.yml` | Kubernetes | `deployment.yaml` |
| `.tf` | Terraform | `vpc.tf` |

## Variable Reference

### Java Variables
- `ENTITY_NAME` - User, Product, Order
- `CONTROLLER_NAME` - UserController
- `SERVICE_NAME` - UserService
- `REPOSITORY_NAME` - UserRepository
- `PACKAGE_NAME` - com.example.user
- `BASE_PATH` - /api/v1/users

### TypeScript Variables
- `COMPONENT_NAME` - UserProfile
- `SERVICE_NAME` - User
- `MODEL_NAME` - User
- `HOOK_NAME` - useAuth

### Infrastructure Variables
- `APP_NAME` - user-service
- `IMAGE` - user-service:latest
- `REPLICAS` - 3
- `NAMESPACE` - default
- `VPC_ID` - vpc-xxxxx
- `REGION` - us-east-1

## Troubleshooting

### Template Not Found
```bash
# Check if template exists for file type
select_template "YourFile.ext"
```

### Wrong Variables
```bash
# Debug variable extraction
extract_variables "YourFile.java" "your-service" | grep ENTITY
```

### Unreplaced Placeholders
If you see `{{VARIABLE}}` in output:
1. Check variable name matches template
2. Verify variable is being extracted
3. Ensure variable has a default value

## Performance Tips

1. **Batch Operations**: Use `generate_pr_code` for multiple files
2. **Parallel Processing**: Run multiple `generate_file` in background
3. **Caching**: Template reading is cached per process

## Advanced Usage

### Custom Variables

```bash
# Override extracted variables
generate_file_with_custom_vars() {
    local file="$1"
    local repo="$2"
    
    # Generate base variables
    vars=$(extract_variables "$file" "$repo")
    
    # Add custom variables
    vars+=$'\n'"CUSTOM_VAR=custom_value"
    vars+=$'\n'"SPECIAL_FEATURE=enabled"
    
    # Apply template
    template=$(select_template "$file")
    apply_template "$template" "$repo/$file" "$vars"
}
```

### Conditional Generation

```bash
# Generate different files based on conditions
if [[ "$SERVICE_TYPE" == "rest-api" ]]; then
    generate_file "src/main/java/RestController.java" "$REPO" "$SERVICE"
elif [[ "$SERVICE_TYPE" == "graphql" ]]; then
    generate_file "src/main/java/GraphQLResolver.java" "$REPO" "$SERVICE"
fi
```

## Integration with Git

```bash
# Complete workflow
REPO="/tmp/user-service"
BRANCH="feature/user"

# Generate files
generate_pr_code 123 config/pr-123.json "$REPO"

# Git operations
cd "$REPO"
git checkout -b "$BRANCH"
git add .
git commit -m "Add user management feature"
git push origin "$BRANCH"

# Create PR
gh pr create --title "Add user management" --body "Generated code for user feature"
```

## Next Steps

- Read full documentation: `README-TEMPLATE-ENGINE.md`
- See detailed examples: `example-usage.sh`
- Review templates: `../../templates/code-generation/`
- Integration guide: `TEMPLATE_ENGINE_SUMMARY.md`

## Help

```bash
# List all functions
grep "^[a-z_]*() {" scripts/lib/template-engine.sh

# Show function usage
type generate_file
```

---

**Documentation**: For comprehensive details, see `README-TEMPLATE-ENGINE.md`
