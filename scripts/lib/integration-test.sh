#!/usr/bin/env bash
# Integration Test for Template Engine
# Tests end-to-end file generation with PR configs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/template-engine.sh"

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test workspace
TEST_WORKSPACE=$(mktemp -d)
trap "rm -rf $TEST_WORKSPACE" EXIT

echo "=========================================="
echo "Template Engine Integration Tests"
echo "=========================================="
echo "Test workspace: $TEST_WORKSPACE"
echo ""

# Test helper
run_test() {
    local test_name="$1"
    local test_func="$2"

    ((TESTS_RUN++))
    echo -n "Test $TESTS_RUN: $test_name ... "

    if $test_func > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Test 1: Generate Java files
# -----------------------------------------------------------------------------
test_java_generation() {
    local repo_path="$TEST_WORKSPACE/java-service"

    generate_file \
        "src/main/java/UserController.java" \
        "$repo_path" \
        "user-service" \
        "Add user controller" \
        "feature/user"

    [[ -f "$repo_path/src/main/java/UserController.java" ]] || return 1

    # Check that placeholders were replaced
    local content=$(cat "$repo_path/src/main/java/UserController.java")
    [[ "$content" =~ "UserController" ]] || return 1
    [[ ! "$content" =~ "{{" ]] || return 1  # No unreplaced placeholders

    return 0
}

# -----------------------------------------------------------------------------
# Test 2: Generate TypeScript files
# -----------------------------------------------------------------------------
test_typescript_generation() {
    local repo_path="$TEST_WORKSPACE/ts-service"

    generate_file \
        "src/services/product.service.ts" \
        "$repo_path" \
        "product-service" \
        "Add product service" \
        "feature/product"

    [[ -f "$repo_path/src/services/product.service.ts" ]] || return 1

    local content=$(cat "$repo_path/src/services/product.service.ts")
    [[ "$content" =~ "Product" ]] || return 1
    [[ ! "$content" =~ "{{" ]] || return 1

    return 0
}

# -----------------------------------------------------------------------------
# Test 3: Generate React components
# -----------------------------------------------------------------------------
test_react_generation() {
    local repo_path="$TEST_WORKSPACE/react-app"

    generate_file \
        "src/components/OrderList.tsx" \
        "$repo_path" \
        "order-ui" \
        "Add order list component" \
        "feature/orders"

    [[ -f "$repo_path/src/components/OrderList.tsx" ]] || return 1

    local content=$(cat "$repo_path/src/components/OrderList.tsx")
    [[ "$content" =~ "OrderList" ]] || return 1
    [[ "$content" =~ "React.FC" ]] || return 1
    [[ ! "$content" =~ "{{" ]] || return 1

    return 0
}

# -----------------------------------------------------------------------------
# Test 4: Generate database migrations
# -----------------------------------------------------------------------------
test_database_generation() {
    local repo_path="$TEST_WORKSPACE/database"

    generate_file \
        "migrations/001_create_products_table.sql" \
        "$repo_path" \
        "product-service" \
        "Create products table" \
        "feature/schema"

    [[ -f "$repo_path/migrations/001_create_products_table.sql" ]] || return 1

    local content=$(cat "$repo_path/migrations/001_create_products_table.sql")
    [[ "$content" =~ "CREATE TABLE" ]] || return 1
    [[ ! "$content" =~ "{{" ]] || return 1

    return 0
}

# -----------------------------------------------------------------------------
# Test 5: Generate Kubernetes manifests
# -----------------------------------------------------------------------------
test_kubernetes_generation() {
    local repo_path="$TEST_WORKSPACE/k8s"

    generate_file \
        "k8s/deployment.yaml" \
        "$repo_path" \
        "payment-service" \
        "Add deployment manifest" \
        "feature/k8s"

    [[ -f "$repo_path/k8s/deployment.yaml" ]] || return 1

    local content=$(cat "$repo_path/k8s/deployment.yaml")
    [[ "$content" =~ "kind: Deployment" ]] || return 1
    [[ "$content" =~ "payment" ]] || return 1
    [[ ! "$content" =~ "{{" ]] || return 1

    return 0
}

# -----------------------------------------------------------------------------
# Test 6: Generate Terraform modules
# -----------------------------------------------------------------------------
test_terraform_generation() {
    local repo_path="$TEST_WORKSPACE/terraform"

    generate_file \
        "infrastructure/vpc.tf" \
        "$repo_path" \
        "infrastructure" \
        "Add VPC module" \
        "feature/vpc"

    [[ -f "$repo_path/infrastructure/vpc.tf" ]] || return 1

    local content=$(cat "$repo_path/infrastructure/vpc.tf")
    [[ "$content" =~ "resource" ]] || return 1
    [[ "$content" =~ "vpc" ]] || return 1
    [[ ! "$content" =~ "{{" ]] || return 1

    return 0
}

# -----------------------------------------------------------------------------
# Test 7: Generate from PR config
# -----------------------------------------------------------------------------
test_pr_config_generation() {
    local repo_path="$TEST_WORKSPACE/pr-test"
    local config_file="$TEST_WORKSPACE/pr-test-config.json"

    # Create PR config
    cat > "$config_file" <<'EOF'
{
  "title": "Add invoice management",
  "branch": "feature/invoice",
  "repo": "invoice-service",
  "files": [
    "src/main/java/InvoiceController.java",
    "src/main/java/InvoiceService.java",
    "src/main/java/InvoiceRepository.java"
  ]
}
EOF

    generate_pr_code "1" "$config_file" "$repo_path"

    # Verify all files were created
    [[ -f "$repo_path/src/main/java/InvoiceController.java" ]] || return 1
    [[ -f "$repo_path/src/main/java/InvoiceService.java" ]] || return 1
    [[ -f "$repo_path/src/main/java/InvoiceRepository.java" ]] || return 1

    # Verify content
    local controller=$(cat "$repo_path/src/main/java/InvoiceController.java")
    [[ "$controller" =~ "InvoiceController" ]] || return 1
    [[ "$controller" =~ "Invoice" ]] || return 1

    return 0
}

# -----------------------------------------------------------------------------
# Test 8: Variable extraction accuracy
# -----------------------------------------------------------------------------
test_variable_extraction() {
    local vars=$(extract_variables \
        "PaymentController.java" \
        "payment-service" \
        "Add Payment API" \
        "feature/payment")

    # Check key variables are present and correct
    [[ "$vars" =~ "ENTITY_NAME=Payment" ]] || return 1
    [[ "$vars" =~ "CONTROLLER_NAME=PaymentController" ]] || return 1
    [[ "$vars" =~ "SERVICE_NAME=PaymentService" ]] || return 1
    [[ "$vars" =~ "REPO_NAME=payment-service" ]] || return 1
    [[ "$vars" =~ "PACKAGE_NAME=com.example.payment" ]] || return 1

    return 0
}

# -----------------------------------------------------------------------------
# Test 9: Template selection accuracy
# -----------------------------------------------------------------------------
test_template_selection() {
    local template

    # Java Controller
    template=$(select_template "UserController.java")
    [[ "$template" =~ "controller.java.template" ]] || return 1

    # React Component
    template=$(select_template "UserProfile.tsx")
    [[ "$template" =~ "component.tsx.template" ]] || return 1

    # Node Service
    template=$(select_template "user.service.ts")
    [[ "$template" =~ "service.ts.template" ]] || return 1

    # SQL Migration
    template=$(select_template "001_create_users.sql")
    [[ "$template" =~ "create-table.sql.template" ]] || return 1

    # Terraform
    template=$(select_template "rds.tf")
    [[ "$template" =~ "rds.tf.template" ]] || return 1

    # Kubernetes
    template=$(select_template "deployment.yaml")
    [[ "$template" =~ "deployment.yaml.template" ]] || return 1

    return 0
}

# -----------------------------------------------------------------------------
# Test 10: Multiple file types in one PR
# -----------------------------------------------------------------------------
test_mixed_file_types() {
    local repo_path="$TEST_WORKSPACE/mixed-pr"
    local config_file="$TEST_WORKSPACE/mixed-config.json"

    # Create PR config with mixed file types
    cat > "$config_file" <<'EOF'
{
  "title": "Add user feature with full stack",
  "branch": "feature/user-fullstack",
  "repo": "user-service",
  "files": [
    "src/main/java/UserController.java",
    "src/components/UserList.tsx",
    "migrations/001_create_users.sql",
    "k8s/deployment.yaml",
    "infrastructure/rds.tf"
  ]
}
EOF

    generate_pr_code "2" "$config_file" "$repo_path"

    # Verify all different file types were created
    [[ -f "$repo_path/src/main/java/UserController.java" ]] || return 1
    [[ -f "$repo_path/src/components/UserList.tsx" ]] || return 1
    [[ -f "$repo_path/migrations/001_create_users.sql" ]] || return 1
    [[ -f "$repo_path/k8s/deployment.yaml" ]] || return 1
    [[ -f "$repo_path/infrastructure/rds.tf" ]] || return 1

    # Verify each has appropriate content
    local java_content=$(cat "$repo_path/src/main/java/UserController.java")
    [[ "$java_content" =~ "UserController" ]] || return 1

    local react_content=$(cat "$repo_path/src/components/UserList.tsx")
    [[ "$react_content" =~ "UserList" ]] || return 1
    [[ "$react_content" =~ "React.FC" ]] || return 1

    local sql_content=$(cat "$repo_path/migrations/001_create_users.sql")
    [[ "$sql_content" =~ "CREATE TABLE" ]] || return 1

    return 0
}

# Run all tests
echo "Running integration tests..."
echo ""

run_test "Java file generation" test_java_generation
run_test "TypeScript file generation" test_typescript_generation
run_test "React component generation" test_react_generation
run_test "Database migration generation" test_database_generation
run_test "Kubernetes manifest generation" test_kubernetes_generation
run_test "Terraform module generation" test_terraform_generation
run_test "PR config-based generation" test_pr_config_generation
run_test "Variable extraction accuracy" test_variable_extraction
run_test "Template selection accuracy" test_template_selection
run_test "Mixed file types in PR" test_mixed_file_types

echo ""
echo "=========================================="
echo "Integration Test Results"
echo "=========================================="
echo "Total Tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}All integration tests passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}Some integration tests failed.${NC}"
    exit 1
fi
