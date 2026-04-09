#!/usr/bin/env bash
# Test script for template engine

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/template-engine.sh"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test function
test_case() {
    local test_name="$1"
    shift

    ((TOTAL_TESTS++))

    echo -n "Testing: $test_name ... "

    if "$@" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED_TESTS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAILED_TESTS++))
        return 1
    fi
}

# Test template selection
test_template_selection_case() {
    local file_path="$1"
    local expected_pattern="$2"

    local result=$(select_template "$file_path" 2>/dev/null || echo "")

    if [[ -n "$result" ]] && [[ "$result" =~ $expected_pattern ]]; then
        return 0
    else
        echo "Expected pattern: $expected_pattern, got: $result" >&2
        return 1
    fi
}

# Test variable extraction
test_variable_extraction() {
    local filename="$1"
    local var_name="$2"
    local expected_value="$3"

    local vars_str=$(extract_variables "$filename" "test-service" "Add User Feature" "feature/user")

    local actual_value=$(echo "$vars_str" | grep "^${var_name}=" | cut -d'=' -f2-)

    if [[ "$actual_value" == "$expected_value" ]]; then
        return 0
    else
        echo "Expected: $expected_value, got: $actual_value" >&2
        return 1
    fi
}

# Test file generation
test_file_generation() {
    local test_file="$1"
    local temp_repo=$(mktemp -d)

    generate_file "$test_file" "$temp_repo" "test-service" "Add Test" "feature/test" > /dev/null 2>&1
    local result=$?

    rm -rf "$temp_repo"
    return $result
}

echo "=========================================="
echo "Template Engine Test Suite"
echo "=========================================="
echo ""

# Test 1: Template Selection Tests
echo "--- Template Selection Tests ---"
test_case "Java Controller" test_template_selection_case \
    "src/main/java/UserController.java" "controller.java.template"

test_case "Java Service" test_template_selection_case \
    "src/main/java/UserService.java" "service-interface.java.template"

test_case "Java ServiceImpl" test_template_selection_case \
    "src/main/java/UserServiceImpl.java" "service-impl.java.template"

test_case "Java Repository" test_template_selection_case \
    "src/main/java/UserRepository.java" "repository.java.template"

test_case "Java Entity" test_template_selection_case \
    "src/main/java/UserEntity.java" "entity.java.template"

test_case "React Component" test_template_selection_case \
    "src/components/UserProfile.tsx" "component.tsx.template"

test_case "React Hook" test_template_selection_case \
    "src/hooks/useAuth.ts" "use-hook.ts.template"

test_case "Node Service" test_template_selection_case \
    "src/services/user.service.ts" "service.ts.template"

test_case "Node Controller" test_template_selection_case \
    "src/controllers/user.controller.ts" "controller.ts.template"

test_case "SQL Migration" test_template_selection_case \
    "migrations/001_create_users_table.sql" "create-table.sql.template"

test_case "Terraform VPC" test_template_selection_case \
    "infrastructure/vpc.tf" "vpc.tf.template"

test_case "Terraform RDS" test_template_selection_case \
    "infrastructure/rds.tf" "rds.tf.template"

test_case "K8s Deployment" test_template_selection_case \
    "k8s/deployment.yaml" "deployment.yaml.template"

test_case "K8s Service" test_template_selection_case \
    "k8s/service.yaml" "service.yaml.template"

echo ""

# Test 2: Variable Extraction Tests
echo "--- Variable Extraction Tests ---"
test_case "Extract Entity from Controller" test_variable_extraction \
    "UserController.java" "ENTITY_NAME" "User"

test_case "Extract Service from Controller" test_variable_extraction \
    "UserController.java" "SERVICE_NAME" "UserService"

test_case "Extract Controller Name" test_variable_extraction \
    "UserController.java" "CONTROLLER_NAME" "UserController"

test_case "Extract Component Name" test_variable_extraction \
    "UserProfile.tsx" "COMPONENT_NAME" "UserProfile"

test_case "Extract Service Name from TS" test_variable_extraction \
    "user.service.ts" "SERVICE_NAME" "User"

echo ""

# Test 3: File Generation Tests
echo "--- File Generation Tests ---"
test_case "Generate Java Controller" test_file_generation \
    "src/main/java/UserController.java"

test_case "Generate React Component" test_file_generation \
    "src/components/UserProfile.tsx"

test_case "Generate Node Service" test_file_generation \
    "src/services/user.service.ts"

test_case "Generate SQL Migration" test_file_generation \
    "migrations/001_create_users.sql"

test_case "Generate Terraform" test_file_generation \
    "infrastructure/main.tf"

test_case "Generate K8s Deployment" test_file_generation \
    "k8s/deployment.yaml"

echo ""

# Test 4: Utility Function Tests
echo "--- Utility Function Tests ---"
test_case "Capitalize First Letter" bash -c '[[ "$(capitalize_first "hello")" == "Hello" ]]'
test_case "Snake Case Conversion" bash -c '[[ "$(to_snake_case "UserProfile")" == "user_profile" ]]'
test_case "Pascal Case Conversion" bash -c '[[ "$(to_pascal_case "user_profile")" == "UserProfile" ]]'

echo ""

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
