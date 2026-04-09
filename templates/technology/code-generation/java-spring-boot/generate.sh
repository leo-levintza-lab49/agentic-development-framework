#!/bin/bash

###############################################################################
# Java/Spring Boot Code Generation Script
#
# This script generates a complete Spring Boot microservice from templates.
# Usage: ./generate.sh
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# Functions
###############################################################################

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"

    read -p "$prompt [$default]: " value
    eval "$var_name=\"${value:-$default}\""
}

replace_placeholders() {
    local template_file="$1"
    local output_file="$2"

    # Read template
    local content
    content=$(<"$template_file")

    # Replace all placeholders
    content="${content//\{\{PACKAGE_NAME\}\}/$PACKAGE_NAME}"
    content="${content//\{\{ENTITY_NAME\}\}/$ENTITY_NAME}"
    content="${content//\{\{TABLE_NAME\}\}/$TABLE_NAME}"
    content="${content//\{\{REPOSITORY_NAME\}\}/$REPOSITORY_NAME}"
    content="${content//\{\{SERVICE_NAME\}\}/$SERVICE_NAME}"
    content="${content//\{\{CONTROLLER_NAME\}\}/$CONTROLLER_NAME}"
    content="${content//\{\{DTO_NAME\}\}/$DTO_NAME}"
    content="${content//\{\{TEST_CLASS\}\}/$TEST_CLASS}"
    content="${content//\{\{BASE_PATH\}\}/$BASE_PATH}"
    content="${content//\{\{PORT\}\}/$PORT}"
    content="${content//\{\{DB_HOST\}\}/$DB_HOST}"
    content="${content//\{\{DB_PORT\}\}/$DB_PORT}"
    content="${content//\{\{DB_NAME\}\}/$DB_NAME}"
    content="${content//\{\{DB_USERNAME\}\}/$DB_USERNAME}"
    content="${content//\{\{DB_PASSWORD\}\}/$DB_PASSWORD}"
    content="${content//\{\{GROUP_ID\}\}/$GROUP_ID}"
    content="${content//\{\{ARTIFACT_ID\}\}/$ARTIFACT_ID}"
    content="${content//\{\{SERVICE_DESCRIPTION\}\}/$SERVICE_DESCRIPTION}"
    content="${content//\{\{JWT_SECRET\}\}/$JWT_SECRET}"
    content="${content//\{\{DOMAIN\}\}/$DOMAIN}"
    content="${content//\{\{FIELDS\}\}/$FIELDS}"

    # Write to output file
    echo "$content" > "$output_file"
}

generate_jwt_secret() {
    openssl rand -base64 64 | tr -d '\n'
}

###############################################################################
# Main Script
###############################################################################

echo "=============================================="
echo "  Java/Spring Boot Code Generator"
echo "=============================================="
echo ""

# Collect configuration
print_info "Please provide the following information:"
echo ""

# Package and naming
prompt_with_default "Package name (e.g., com.company.service)" "com.example.demo" PACKAGE_NAME
prompt_with_default "Entity name (e.g., Product, Order)" "Product" ENTITY_NAME

# Convert entity name to lowercase with underscores for table name
TABLE_NAME=$(echo "$ENTITY_NAME" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//' | tr '[:upper:]' '[:lower:]')s
prompt_with_default "Table name" "$TABLE_NAME" TABLE_NAME

# Repository, Service, Controller names
REPOSITORY_NAME="${ENTITY_NAME}Repository"
SERVICE_NAME="${ENTITY_NAME}Service"
CONTROLLER_NAME="${ENTITY_NAME}Controller"
DTO_NAME="${ENTITY_NAME}"
TEST_CLASS="${ENTITY_NAME}ServiceTest"

# API configuration
BASE_PATH="/api/v1/$(echo "$ENTITY_NAME" | tr '[:upper:]' '[:lower:]')s"
prompt_with_default "API base path" "$BASE_PATH" BASE_PATH
prompt_with_default "Server port" "8080" PORT

# Database configuration
prompt_with_default "Database host" "localhost" DB_HOST
prompt_with_default "Database port" "5432" DB_PORT
DB_NAME="${ENTITY_NAME,,}_db"
prompt_with_default "Database name" "$DB_NAME" DB_NAME
prompt_with_default "Database username" "dbuser" DB_USERNAME
prompt_with_default "Database password" "dbpassword" DB_PASSWORD

# Maven configuration
GROUP_ID=$(echo "$PACKAGE_NAME" | sed 's/\.[^.]*$//')
ARTIFACT_ID="${ENTITY_NAME,,}-service"
prompt_with_default "Maven Group ID" "$GROUP_ID" GROUP_ID
prompt_with_default "Maven Artifact ID" "$ARTIFACT_ID" ARTIFACT_ID
SERVICE_DESCRIPTION="${ENTITY_NAME} Management Service"
prompt_with_default "Service description" "$SERVICE_DESCRIPTION" SERVICE_DESCRIPTION

# Security
JWT_SECRET=$(generate_jwt_secret)
prompt_with_default "Production domain" "api.example.com" DOMAIN

# Fields (placeholder - user should customize)
read -r -d '' FIELDS << 'EOF' || true
    @Column(name = "name", nullable = false, length = 255)
    @NotBlank(message = "Name cannot be blank")
    @Size(min = 2, max = 255)
    private String name;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
EOF

echo ""
print_info "Configuration complete. Generating code..."
echo ""

# Create output directory structure
OUTPUT_DIR="${SCRIPT_DIR}/generated/${ARTIFACT_ID}"
PACKAGE_PATH=$(echo "$PACKAGE_NAME" | tr '.' '/')

mkdir -p "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/controller"
mkdir -p "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/service/impl"
mkdir -p "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/repository"
mkdir -p "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/domain/entity/base"
mkdir -p "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/dto"
mkdir -p "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/mapper"
mkdir -p "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/exception"
mkdir -p "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/config"
mkdir -p "${OUTPUT_DIR}/src/main/resources"
mkdir -p "${OUTPUT_DIR}/src/test/java/${PACKAGE_PATH}/service"
mkdir -p "${OUTPUT_DIR}/src/test/java/${PACKAGE_PATH}/controller"

# Generate files from templates
print_info "Generating entity files..."
replace_placeholders "${SCRIPT_DIR}/base-entity.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/domain/entity/base/BaseEntity.java"
replace_placeholders "${SCRIPT_DIR}/entity.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/domain/entity/${ENTITY_NAME}.java"

print_info "Generating repository..."
replace_placeholders "${SCRIPT_DIR}/repository.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/repository/${REPOSITORY_NAME}.java"

print_info "Generating service layer..."
replace_placeholders "${SCRIPT_DIR}/service-interface.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/service/${SERVICE_NAME}.java"
replace_placeholders "${SCRIPT_DIR}/service-impl.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/service/impl/${SERVICE_NAME}Impl.java"

print_info "Generating controller..."
replace_placeholders "${SCRIPT_DIR}/controller.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/controller/${CONTROLLER_NAME}.java"

print_info "Generating DTOs..."
replace_placeholders "${SCRIPT_DIR}/dto.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/dto/${DTO_NAME}Request.java"
replace_placeholders "${SCRIPT_DIR}/dto-response.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/dto/${DTO_NAME}Response.java"

print_info "Generating mapper..."
replace_placeholders "${SCRIPT_DIR}/mapper.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/mapper/${ENTITY_NAME}Mapper.java"

print_info "Generating exception handlers..."
replace_placeholders "${SCRIPT_DIR}/custom-exceptions.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/exception/CustomExceptions.java"
replace_placeholders "${SCRIPT_DIR}/error-response.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/exception/ErrorResponse.java"
replace_placeholders "${SCRIPT_DIR}/exception-handler.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/exception/GlobalExceptionHandler.java"

print_info "Generating configuration..."
replace_placeholders "${SCRIPT_DIR}/configuration.java.template" \
    "${OUTPUT_DIR}/src/main/java/${PACKAGE_PATH}/config/ApplicationConfiguration.java"

print_info "Generating tests..."
replace_placeholders "${SCRIPT_DIR}/service-test.java.template" \
    "${OUTPUT_DIR}/src/test/java/${PACKAGE_PATH}/service/${TEST_CLASS}.java"
replace_placeholders "${SCRIPT_DIR}/controller-test.java.template" \
    "${OUTPUT_DIR}/src/test/java/${PACKAGE_PATH}/controller/${CONTROLLER_NAME}Test.java"

print_info "Generating configuration files..."
replace_placeholders "${SCRIPT_DIR}/application.yml.template" \
    "${OUTPUT_DIR}/src/main/resources/application.yml"
replace_placeholders "${SCRIPT_DIR}/pom.xml.template" \
    "${OUTPUT_DIR}/pom.xml"

# Create additional files
print_info "Creating additional project files..."

# .gitignore
cat > "${OUTPUT_DIR}/.gitignore" << 'EOF'
target/
!.mvn/wrapper/maven-wrapper.jar
!**/src/main/**/target/
!**/src/test/**/target/

### STS ###
.apt_generated
.classpath
.factorypath
.project
.settings
.springBeans
.sts4-cache

### IntelliJ IDEA ###
.idea
*.iws
*.iml
*.ipr

### NetBeans ###
/nbproject/private/
/nbbuild/
/dist/
/nbdist/
/.nb-gradle/
build/
!**/src/main/**/build/
!**/src/test/**/build/

### VS Code ###
.vscode/

### Logs ###
logs/
*.log

### OS ###
.DS_Store
Thumbs.db
EOF

# README.md
cat > "${OUTPUT_DIR}/README.md" << EOF
# ${ENTITY_NAME} Service

${SERVICE_DESCRIPTION}

## Overview

This is a Spring Boot microservice for managing ${ENTITY_NAME} entities.

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- PostgreSQL 12+

## Configuration

Update \`src/main/resources/application.yml\` with your environment-specific settings.

## Building

\`\`\`bash
mvn clean install
\`\`\`

## Running

\`\`\`bash
mvn spring-boot:run
\`\`\`

## Testing

\`\`\`bash
mvn test
\`\`\`

## API Documentation

After starting the application, access:

- Swagger UI: http://localhost:${PORT}/api/swagger-ui.html
- OpenAPI Spec: http://localhost:${PORT}/api/api-docs

## Endpoints

- POST ${BASE_PATH} - Create ${ENTITY_NAME}
- GET ${BASE_PATH}/{id} - Get ${ENTITY_NAME} by ID
- GET ${BASE_PATH} - List all ${ENTITY_NAME}s
- PUT ${BASE_PATH}/{id} - Update ${ENTITY_NAME}
- PATCH ${BASE_PATH}/{id} - Partially update ${ENTITY_NAME}
- DELETE ${BASE_PATH}/{id} - Delete ${ENTITY_NAME}

## Database

Database: ${DB_NAME}
Host: ${DB_HOST}:${DB_PORT}

## License

Copyright © $(date +%Y)
EOF

echo ""
print_info "Code generation complete!"
echo ""
echo "Output directory: ${OUTPUT_DIR}"
echo ""
print_warn "Next steps:"
echo "  1. Navigate to the generated project: cd ${OUTPUT_DIR}"
echo "  2. Review and customize the field definitions in entity and DTO files"
echo "  3. Update database credentials in application.yml"
echo "  4. Build the project: mvn clean install"
echo "  5. Run the application: mvn spring-boot:run"
echo ""
print_info "Access the application at: http://localhost:${PORT}/api"
print_info "Swagger UI: http://localhost:${PORT}/api/swagger-ui.html"
echo ""
