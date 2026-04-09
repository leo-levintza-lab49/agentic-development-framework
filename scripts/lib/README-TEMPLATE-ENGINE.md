# Template Engine Library

Comprehensive code generation library that creates realistic code files from templates with intelligent placeholder replacement.

## Overview

The template engine automatically:
- Selects appropriate templates based on file paths and patterns
- Extracts meaningful variable names from context (filename, repo name, PR title, branch)
- Applies templates with proper variable substitution
- Generates production-ready code for multiple languages and frameworks

## Features

### Supported Technologies

1. **Java Spring Boot**
   - Controllers, Services, Repositories
   - Entities, DTOs, Mappers
   - Configuration classes
   - Unit tests

2. **React/TypeScript**
   - Components (functional, form, page, context)
   - Custom hooks
   - API services
   - Type definitions
   - Styled components

3. **Node.js/TypeScript**
   - Services, Controllers
   - Models, Routes
   - Middleware
   - API clients with retry logic
   - Express applications

4. **Database**
   - SQL migrations (up/down)
   - Table creation
   - Index creation
   - Foreign keys
   - Liquibase changesets
   - Seed data

5. **Kubernetes**
   - Deployments, Services
   - Ingress, ConfigMaps, Secrets
   - StatefulSets, DaemonSets, Jobs
   - HPA, PDB, NetworkPolicy
   - Helm charts and values

6. **Terraform**
   - VPC, RDS, S3, EKS
   - ALB, Security Groups
   - IAM roles
   - Complete infrastructure modules

## Usage

### Basic Usage

```bash
# Source the library
source scripts/lib/template-engine.sh

# Generate a single file
generate_file \
    "src/main/java/UserController.java" \
    "/path/to/repo" \
    "user-service" \
    "Add user management" \
    "feature/user"

# Generate all files for a PR
generate_pr_code \
    "123" \
    "config/pr-123.json" \
    "/path/to/repo"

# Generate code for all PRs
generate_all_prs \
    "config/prs" \
    "/path/to/repo"
```

### Key Functions

#### `select_template(file_path)`
Selects the appropriate template based on file path and naming conventions.

```bash
template=$(select_template "src/controllers/UserController.java")
# Returns: /path/to/templates/java-spring-boot/controller.java.template
```

**Template Selection Logic:**
- Java files: Matches `*Controller.java`, `*Service.java`, `*Repository.java`, etc.
- TypeScript: Matches `*.tsx`, `*.service.ts`, `use*.ts`, etc.
- Database: Matches migration patterns, table creation, etc.
- Infrastructure: Matches Kubernetes and Terraform resource types

#### `extract_variables(filename, repo_name, pr_title, branch_name)`
Extracts contextual variables from inputs.

```bash
vars=$(extract_variables \
    "UserController.java" \
    "user-service" \
    "Add user management" \
    "feature/user")

# Output (KEY=VALUE format):
# ENTITY_NAME=User
# CONTROLLER_NAME=UserController
# SERVICE_NAME=UserService
# BASE_PATH=/api/v1/users
# PACKAGE_NAME=com.example.user
# ...
```

**Variable Extraction Rules:**
- **From filename:**
  - `UserController.java` → ENTITY_NAME=User, SERVICE_NAME=UserService
  - `user.service.ts` → SERVICE_NAME=User, MODEL_NAME=User
  - `UserProfile.tsx` → COMPONENT_NAME=UserProfile

- **From repo name:**
  - `user-service` → SERVICE_NAME=User, PACKAGE_NAME=com.example.user
  - `payment-api` → SERVICE_NAME=Payment

- **From PR title:**
  - "Add User Feature" → ENTITY_NAME=User
  - "Create Product Schema" → ENTITY_NAME=Product

- **From branch:**
  - `feature/user` → ENTITY_NAME=User, FEATURE_NAME=user
  - `feature/payment/gateway` → ENTITY_NAME=Payment

#### `apply_template(template_path, output_path, vars_str)`
Applies template with variable substitution.

```bash
vars=$(extract_variables "UserController.java" "user-service")
apply_template \
    "/path/to/controller.java.template" \
    "/repo/src/UserController.java" \
    "$vars"
```

**Placeholder Format:** `{{VARIABLE_NAME}}`

Example template:
```java
public class {{CONTROLLER_NAME}} {
    private final {{SERVICE_NAME}} service;
    
    @GetMapping("{{BASE_PATH}}")
    public ResponseEntity<List<{{ENTITY_NAME}}>> findAll() {
        // Implementation
    }
}
```

#### `generate_file(file_path, repo_path, repo_name, pr_title, branch_name)`
Complete file generation workflow.

```bash
generate_file \
    "src/main/java/UserController.java" \
    "/tmp/user-service" \
    "user-service" \
    "Add user endpoints" \
    "feature/user"
```

Steps:
1. Select template based on file path
2. Extract variables from context
3. Apply template with substitution
4. Create output directory if needed
5. Write file to disk

#### `generate_pr_code(pr_id, pr_config_file, repo_path)`
Generate all files for a PR from configuration.

**PR Config Format (JSON):**
```json
{
  "title": "Add user management endpoints",
  "branch": "feature/user",
  "repo": "user-service",
  "files": [
    "src/main/java/controller/UserController.java",
    "src/main/java/service/UserService.java",
    "src/main/java/repository/UserRepository.java",
    "src/test/java/UserControllerTest.java"
  ]
}
```

```bash
generate_pr_code \
    "123" \
    "config/prs/pr-123.json" \
    "/tmp/user-service"
```

#### `generate_all_prs(pr_config_dir, repo_path)`
Batch process multiple PRs.

```bash
generate_all_prs \
    "config/prs" \
    "/tmp/user-service"
```

## Utility Functions

### String Transformations

```bash
# Capitalize first letter
capitalize_first "hello"
# Output: Hello

# Convert to snake_case
to_snake_case "UserProfile"
# Output: user_profile

# Convert to PascalCase
to_pascal_case "user_profile"
# Output: UserProfile
```

### Template Listing

```bash
# List all available templates
list_templates

# Output:
# [java-spring-boot]
#   - controller.java
#   - service-impl.java
#   - repository.java
# [react-typescript]
#   - component.tsx
#   - use-hook.ts
# ...
```

### Template Selection Testing

```bash
# Test template selection logic
test_template_selection

# Output:
# src/main/java/UserController.java -> controller.java.template
# src/components/UserProfile.tsx -> component.tsx.template
# ...
```

## Template Variables Reference

### Common Variables (All Templates)
- `AUTHOR` - Code author (default: "Generated")
- `VERSION` - Version number (default: "1.0.0")
- `ENVIRONMENT` - Environment name (default: "production")
- `PROJECT` - Project name (from repo name)
- `REPO_NAME` - Repository name

### Java Spring Boot
- `PACKAGE_NAME` - Java package (e.g., "com.example.user")
- `CLASS_NAME` - Class name
- `ENTITY_NAME` - Entity/domain object name
- `CONTROLLER_NAME` - Controller class name
- `SERVICE_NAME` - Service class name
- `REPOSITORY_NAME` - Repository interface name
- `BASE_PATH` - REST API base path (e.g., "/api/v1/users")
- `TABLE_NAME` - Database table name

### React/TypeScript
- `COMPONENT_NAME` - React component name
- `PROPS` - Component props (placeholder)
- `HOOK_NAME` - Custom hook name

### Node.js/TypeScript
- `SERVICE_NAME` - Service class name
- `MODEL_NAME` - Model/type name
- `BACKEND_URL` - Backend URL environment variable name

### Database
- `DB_NAME` - Database name
- `TABLE_NAME` - Table name
- `COLUMN_NAME` - Column name

### Kubernetes
- `NAMESPACE` - Kubernetes namespace
- `APP_NAME` - Application name
- `IMAGE_NAME` - Container image name
- `REPLICAS` - Number of replicas (default: 3)

### Terraform
- `VPC_ID` - VPC identifier
- `SUBNET_IDS` - Subnet identifiers (JSON array)
- `INSTANCE_CLASS` - Instance class/type
- `ENGINE_VERSION` - Database/service engine version

## Examples

### Example 1: Generate Java Controller

```bash
#!/usr/bin/env bash
source scripts/lib/template-engine.sh

generate_file \
    "src/main/java/com/example/user/controller/UserController.java" \
    "/tmp/user-service" \
    "user-service" \
    "Add user CRUD endpoints" \
    "feature/user-crud"
```

**Generated Output:**
```java
package com.example.user.controller;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {
    private final UserService service;
    
    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> findById(@PathVariable Long id) {
        UserResponse response = service.findById(id);
        return ResponseEntity.ok(response);
    }
    // ... more endpoints
}
```

### Example 2: Generate React Component

```bash
generate_file \
    "src/components/UserProfile.tsx" \
    "/tmp/user-ui" \
    "user-ui" \
    "Add user profile component" \
    "feature/user-profile"
```

**Generated Output:**
```tsx
import React from 'react';

interface UserProfileProps {
  // Add props here
}

export const UserProfile: React.FC<UserProfileProps> = () => {
  return (
    <div className="UserProfile">
      <h2>UserProfile</h2>
      {/* Add component JSX here */}
    </div>
  );
};
```

### Example 3: Generate Terraform Infrastructure

```bash
generate_file \
    "infrastructure/rds.tf" \
    "/tmp/infra" \
    "infrastructure" \
    "Add RDS database" \
    "feature/rds"
```

**Generated Output:** Complete RDS module with encryption, backups, monitoring, etc.

### Example 4: Generate Multiple Files for a PR

**PR Config (`config/prs/pr-123.json`):**
```json
{
  "title": "Add user service layer",
  "branch": "feature/user-service",
  "repo": "user-service",
  "files": [
    "src/main/java/service/UserService.java",
    "src/main/java/service/UserServiceImpl.java",
    "src/test/java/service/UserServiceTest.java"
  ]
}
```

**Generate:**
```bash
generate_pr_code 123 config/prs/pr-123.json /tmp/user-service
```

## Integration with PR Generation

The template engine is designed to work seamlessly with the PR generation workflow:

1. **PR Configuration** defines what files to create
2. **Template Engine** generates realistic code for those files
3. **Git Operations** commit and push changes
4. **GitHub API** creates pull requests

```bash
# In PR generation script
source scripts/lib/template-engine.sh

# For each PR
for pr_config in config/prs/pr-*.json; do
    pr_id=$(basename "$pr_config" | sed 's/pr-\([0-9]*\).json/\1/')
    
    # Generate code
    generate_pr_code "$pr_id" "$pr_config" "$REPO_PATH"
    
    # Commit and push
    git add .
    git commit -m "$(jq -r '.title' "$pr_config")"
    git push origin "$(jq -r '.branch' "$pr_config")"
    
    # Create PR via GitHub API
    gh pr create --title "..." --body "..."
done
```

## Testing

Run the comprehensive test suite:

```bash
./scripts/lib/test-template-engine.sh
```

**Test Coverage:**
- Template selection for all file types (14 tests)
- Variable extraction accuracy (5 tests)
- File generation workflow (6 tests)
- Utility functions (3 tests)

**Total: 28 tests**

## Performance

- **Template Selection**: O(1) - Pattern matching
- **Variable Extraction**: O(n) - String parsing
- **Template Application**: O(m) - Where m is template size
- **File Generation**: ~10-50ms per file (depending on template size)

**Batch Processing:**
- 100 files: ~2-5 seconds
- 1000 files: ~20-50 seconds

## Troubleshooting

### Template Not Found
```bash
ERROR: No template found for: src/unknown/file.xyz
```
**Solution:** Add pattern to `select_template()` function or use fallback extension mapping.

### Missing Variables
Templates with unreplaced `{{VARIABLE}}` placeholders.

**Solution:** 
1. Check variable extraction logic
2. Add default value in `extract_variables()`
3. Update template to use available variables

### Incorrect Variable Values
**Solution:** Debug with:
```bash
extract_variables "YourFile.java" "your-repo" | grep ENTITY_NAME
```

## Advanced Usage

### Custom Variable Extraction

Override variables by wrapping the function:

```bash
custom_extract_variables() {
    local vars=$(extract_variables "$@")
    # Override or add custom variables
    vars=$(echo "$vars" | sed "s/AUTHOR=Generated/AUTHOR=YourTeam/")
    echo "$vars"
    echo "CUSTOM_VAR=custom_value"
}
```

### Template Customization

Add your own templates:
1. Create template file in `templates/code-generation/<category>/`
2. Use `{{VARIABLE}}` placeholders
3. Add pattern to `select_template()` function

### Conditional Logic in Templates

Use shell scripting for complex templates:

```bash
generate_with_conditions() {
    local vars=$(extract_variables "$@")
    
    # Conditional variable setting
    if [[ $(echo "$vars" | grep ENTITY_NAME=User) ]]; then
        vars+=$'\n'"SPECIAL_FEATURE=enabled"
    fi
    
    apply_template "$template" "$output" "$vars"
}
```

## Best Practices

1. **Naming Conventions**: Follow language-specific naming patterns for best template matching
2. **Template Organization**: Keep templates organized by technology/framework
3. **Variable Defaults**: Always provide sensible defaults for all variables
4. **Testing**: Test template selection and generation before batch operations
5. **Validation**: Verify generated code compiles/runs in target environment
6. **Version Control**: Track template changes separately from generated code

## Related Files

- `/Users/leo.levintza/wrk/first-agentic-ai/scripts/lib/template-engine.sh` - Main library
- `/Users/leo.levintza/wrk/first-agentic-ai/scripts/lib/test-template-engine.sh` - Test suite
- `/Users/leo.levintza/wrk/first-agentic-ai/templates/code-generation/` - Template directory

## License

Part of the First Agentic AI project.
