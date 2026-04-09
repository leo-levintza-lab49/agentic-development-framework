#!/usr/bin/env bash
# Example Usage Script for Template Engine
# Demonstrates various ways to use the template engine library

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/template-engine.sh"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Template Engine - Example Usage"
echo "=========================================="
echo ""

# Create temporary workspace
TEMP_WORKSPACE=$(mktemp -d)
echo -e "${BLUE}Workspace: ${TEMP_WORKSPACE}${NC}"
echo ""

# -----------------------------------------------------------------------------
# Example 1: Generate a Java Controller
# -----------------------------------------------------------------------------
echo -e "${GREEN}Example 1: Generate Java Controller${NC}"
echo "----------------------------------------"

JAVA_FILE="src/main/java/com/example/user/controller/UserController.java"
echo "Generating: $JAVA_FILE"

generate_file \
    "$JAVA_FILE" \
    "$TEMP_WORKSPACE/user-service" \
    "user-service" \
    "Add user management endpoints" \
    "feature/user-crud" | head -2

echo -e "${YELLOW}Generated file preview:${NC}"
head -20 "$TEMP_WORKSPACE/user-service/$JAVA_FILE"
echo "..."
echo ""

# -----------------------------------------------------------------------------
# Example 2: Generate a React Component
# -----------------------------------------------------------------------------
echo -e "${GREEN}Example 2: Generate React Component${NC}"
echo "----------------------------------------"

REACT_FILE="src/components/UserProfile.tsx"
echo "Generating: $REACT_FILE"

generate_file \
    "$REACT_FILE" \
    "$TEMP_WORKSPACE/user-ui" \
    "user-ui" \
    "Add user profile component" \
    "feature/user-profile" | head -2

echo -e "${YELLOW}Generated file preview:${NC}"
head -15 "$TEMP_WORKSPACE/user-ui/$REACT_FILE"
echo ""

# -----------------------------------------------------------------------------
# Example 3: Generate a Node.js Service
# -----------------------------------------------------------------------------
echo -e "${GREEN}Example 3: Generate Node.js Service${NC}"
echo "----------------------------------------"

NODE_FILE="src/services/product.service.ts"
echo "Generating: $NODE_FILE"

generate_file \
    "$NODE_FILE" \
    "$TEMP_WORKSPACE/product-api" \
    "product-api" \
    "Add product service layer" \
    "feature/product-service" | head -2

echo -e "${YELLOW}Generated file preview:${NC}"
head -20 "$TEMP_WORKSPACE/product-api/$NODE_FILE"
echo "..."
echo ""

# -----------------------------------------------------------------------------
# Example 4: Generate SQL Migration
# -----------------------------------------------------------------------------
echo -e "${GREEN}Example 4: Generate SQL Migration${NC}"
echo "----------------------------------------"

SQL_FILE="migrations/001_create_users_table.sql"
echo "Generating: $SQL_FILE"

generate_file \
    "$SQL_FILE" \
    "$TEMP_WORKSPACE/database" \
    "user-service" \
    "Create users table" \
    "feature/user-schema" | head -2

echo -e "${YELLOW}Generated file preview:${NC}"
head -25 "$TEMP_WORKSPACE/database/$SQL_FILE"
echo "..."
echo ""

# -----------------------------------------------------------------------------
# Example 5: Generate Kubernetes Deployment
# -----------------------------------------------------------------------------
echo -e "${GREEN}Example 5: Generate Kubernetes Deployment${NC}"
echo "----------------------------------------"

K8S_FILE="k8s/deployment.yaml"
echo "Generating: $K8S_FILE"

generate_file \
    "$K8S_FILE" \
    "$TEMP_WORKSPACE/user-service" \
    "user-service" \
    "Add Kubernetes deployment" \
    "feature/k8s-deploy" | head -2

echo -e "${YELLOW}Generated file preview:${NC}"
head -30 "$TEMP_WORKSPACE/user-service/$K8S_FILE"
echo "..."
echo ""

# -----------------------------------------------------------------------------
# Example 6: Generate Terraform Module
# -----------------------------------------------------------------------------
echo -e "${GREEN}Example 6: Generate Terraform RDS Module${NC}"
echo "----------------------------------------"

TF_FILE="infrastructure/rds.tf"
echo "Generating: $TF_FILE"

generate_file \
    "$TF_FILE" \
    "$TEMP_WORKSPACE/infrastructure" \
    "infrastructure" \
    "Add RDS PostgreSQL instance" \
    "feature/rds" | head -2

echo -e "${YELLOW}Generated file preview:${NC}"
head -40 "$TEMP_WORKSPACE/infrastructure/$TF_FILE"
echo "..."
echo ""

# -----------------------------------------------------------------------------
# Example 7: Batch Generate Files from PR Config
# -----------------------------------------------------------------------------
echo -e "${GREEN}Example 7: Generate Multiple Files from PR Config${NC}"
echo "----------------------------------------"

# Create a sample PR config
PR_CONFIG="$TEMP_WORKSPACE/pr-config.json"
cat > "$PR_CONFIG" <<'EOF'
{
  "title": "Add order management feature",
  "branch": "feature/order-management",
  "repo": "order-service",
  "files": [
    "src/main/java/controller/OrderController.java",
    "src/main/java/service/OrderService.java",
    "src/main/java/service/OrderServiceImpl.java",
    "src/main/java/repository/OrderRepository.java",
    "src/main/java/entity/OrderEntity.java",
    "src/test/java/OrderControllerTest.java"
  ]
}
EOF

echo "PR Config:"
cat "$PR_CONFIG"
echo ""

echo "Generating files..."
generate_pr_code \
    "999" \
    "$PR_CONFIG" \
    "$TEMP_WORKSPACE/order-service"

echo ""
echo "Generated files:"
find "$TEMP_WORKSPACE/order-service" -type f | sort
echo ""

# -----------------------------------------------------------------------------
# Example 8: Variable Extraction Demo
# -----------------------------------------------------------------------------
echo -e "${GREEN}Example 8: Variable Extraction${NC}"
echo "----------------------------------------"

echo "Extracting variables from: UserController.java"
echo ""
extract_variables \
    "UserController.java" \
    "user-service" \
    "Add user endpoints" \
    "feature/user" | head -15

echo ""

# -----------------------------------------------------------------------------
# Example 9: Template Selection Demo
# -----------------------------------------------------------------------------
echo -e "${GREEN}Example 9: Template Selection${NC}"
echo "----------------------------------------"

TEST_FILES=(
    "UserController.java"
    "UserProfile.tsx"
    "product.service.ts"
    "001_create_table.sql"
    "deployment.yaml"
    "vpc.tf"
)

echo "Template selection for various file types:"
for file in "${TEST_FILES[@]}"; do
    template=$(select_template "$file" 2>/dev/null || echo "NONE")
    template_name=$(basename "$template" 2>/dev/null || echo "N/A")
    echo "  $file -> $template_name"
done

echo ""

# -----------------------------------------------------------------------------
# Cleanup and Summary
# -----------------------------------------------------------------------------
echo "=========================================="
echo "Summary"
echo "=========================================="
echo "All examples completed successfully!"
echo ""
echo "Generated files in: $TEMP_WORKSPACE"
echo ""
echo "To inspect generated files:"
echo "  cd $TEMP_WORKSPACE"
echo "  find . -type f"
echo ""
echo "To clean up:"
echo "  rm -rf $TEMP_WORKSPACE"
echo ""

# Optional: Keep workspace for inspection
read -p "Delete temporary workspace? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$TEMP_WORKSPACE"
    echo "Workspace cleaned up."
else
    echo "Workspace preserved for inspection."
fi
