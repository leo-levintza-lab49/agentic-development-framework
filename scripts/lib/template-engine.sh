#!/usr/bin/env bash
# Template Engine Library
# Handles code generation from templates with placeholder replacement

set -euo pipefail

# Script directory for locating templates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_BASE_DIR="${SCRIPT_DIR}/../../templates/code-generation"

# -----------------------------------------------------------------------------
# Template Selection Functions
# -----------------------------------------------------------------------------

# Select template based on file path
# Args: file_path
# Returns: template_path (echoes to stdout)
select_template() {
    local file_path="$1"
    local filename=$(basename "$file_path")
    local extension="${filename##*.}"
    local file_type="${filename%.*}"

    # Handle double extensions (e.g., .test.ts, .config.ts)
    if [[ "$file_type" =~ \. ]]; then
        local sub_extension="${file_type##*.}"
        file_type="${file_type%.*}"
    fi

    local template_path=""

    # Template mapping based on file patterns
    case "$filename" in
        # Java Spring Boot patterns
        *Controller.java)
            template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/controller.java.template"
            ;;
        *Service.java|*ServiceImpl.java)
            if [[ "$filename" == *Impl.java ]]; then
                template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/service-impl.java.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/service-interface.java.template"
            fi
            ;;
        *Repository.java)
            template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/repository.java.template"
            ;;
        *Entity.java)
            template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/entity.java.template"
            ;;
        *Request.java|*Response.java|*DTO.java|*Dto.java)
            if [[ "$filename" == *Response.java ]]; then
                template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/dto-response.java.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/dto.java.template"
            fi
            ;;
        *Mapper.java)
            template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/mapper.java.template"
            ;;
        *Configuration.java|*Config.java)
            template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/configuration.java.template"
            ;;
        *Exception.java)
            template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/custom-exceptions.java.template"
            ;;
        *ControllerTest.java)
            template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/controller-test.java.template"
            ;;
        *ServiceTest.java)
            template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/service-test.java.template"
            ;;
        pom.xml)
            template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/pom.xml.template"
            ;;
        application.yml|application.yaml)
            template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/application.yml.template"
            ;;

        # Node.js/TypeScript patterns (check first for more specific patterns)
        *.controller.ts)
            template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/controller.ts.template"
            ;;
        *.service.ts)
            if [[ "$filename" == *test.ts || "$filename" == *spec.ts ]]; then
                template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/service.test.ts.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/service.ts.template"
            fi
            ;;
        *.model.ts)
            template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/model.ts.template"
            ;;
        *.route.ts|*.routes.ts)
            if [[ "$filename" == *test.ts || "$filename" == *spec.ts ]]; then
                template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/route.test.ts.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/route.ts.template"
            fi
            ;;
        *.middleware.ts)
            template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/middleware.ts.template"
            ;;
        app.ts)
            template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/app.ts.template"
            ;;
        index.ts)
            if [[ "$file_path" =~ /src/index\.ts$ ]]; then
                template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/index.ts.template"
            fi
            ;;
        config.ts)
            template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/config.ts.template"
            ;;
        Dockerfile)
            if [[ "$file_path" =~ node ]]; then
                template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/Dockerfile.template"
            fi
            ;;

        # React/TypeScript patterns
        *.tsx)
            if [[ "$filename" == *test.tsx || "$filename" == *spec.tsx ]]; then
                template_path="${TEMPLATE_BASE_DIR}/react-typescript/component.test.tsx.template"
            elif [[ "$filename" == *Page.tsx || "$filename" == *page.tsx ]]; then
                template_path="${TEMPLATE_BASE_DIR}/react-typescript/page.tsx.template"
            elif [[ "$filename" == *Form.tsx || "$filename" == *form.tsx ]]; then
                template_path="${TEMPLATE_BASE_DIR}/react-typescript/form-component.tsx.template"
            elif [[ "$filename" == *Context.tsx || "$filename" == *context.tsx ]]; then
                template_path="${TEMPLATE_BASE_DIR}/react-typescript/context.tsx.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/react-typescript/component.tsx.template"
            fi
            ;;
        *.styles.ts)
            template_path="${TEMPLATE_BASE_DIR}/react-typescript/component.styles.ts.template"
            ;;
        use*.ts)
            template_path="${TEMPLATE_BASE_DIR}/react-typescript/use-hook.ts.template"
            ;;
        *types.ts|*Types.ts)
            template_path="${TEMPLATE_BASE_DIR}/react-typescript/types.ts.template"
            ;;
        *api*.ts|*Api*.ts|*service*.ts|*Service*.ts)
            if [[ "$file_path" =~ /services?/ || "$file_path" =~ /api/ ]]; then
                template_path="${TEMPLATE_BASE_DIR}/react-typescript/api-service.ts.template"
            fi
            ;;
        vite.config.ts)
            template_path="${TEMPLATE_BASE_DIR}/react-typescript/vite.config.ts.template"
            ;;

        # Database patterns
        *.sql)
            if [[ "$filename" =~ migration.*up ]]; then
                template_path="${TEMPLATE_BASE_DIR}/database/migration-up.sql.template"
            elif [[ "$filename" =~ migration.*down ]]; then
                template_path="${TEMPLATE_BASE_DIR}/database/migration-down.sql.template"
            elif [[ "$filename" =~ create.*table || "$filename" =~ [0-9]{3}_create ]]; then
                template_path="${TEMPLATE_BASE_DIR}/database/create-table.sql.template"
            elif [[ "$filename" =~ create.*index || "$filename" =~ add.*index ]]; then
                template_path="${TEMPLATE_BASE_DIR}/database/create-index.sql.template"
            elif [[ "$filename" =~ foreign.*key || "$filename" =~ add.*fk ]]; then
                template_path="${TEMPLATE_BASE_DIR}/database/add-foreign-key.sql.template"
            elif [[ "$filename" =~ seed ]]; then
                template_path="${TEMPLATE_BASE_DIR}/database/seed-data.sql.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/database/create-table.sql.template"
            fi
            ;;
        db.changelog*.xml)
            template_path="${TEMPLATE_BASE_DIR}/database/db.changelog-master.xml.template"
            ;;
        changeset*.xml)
            template_path="${TEMPLATE_BASE_DIR}/database/changeset.xml.template"
            ;;
        database.yml)
            template_path="${TEMPLATE_BASE_DIR}/database/database.yml.template"
            ;;

        # Kubernetes patterns
        deployment.yaml|deployment.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/deployment.yaml.template"
            ;;
        service.yaml|service.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/service.yaml.template"
            ;;
        ingress.yaml|ingress.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/ingress.yaml.template"
            ;;
        configmap.yaml|configmap.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/configmap.yaml.template"
            ;;
        secret.yaml|secret.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/secret.yaml.template"
            ;;
        hpa.yaml|hpa.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/hpa.yaml.template"
            ;;
        cronjob.yaml|cronjob.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/cronjob.yaml.template"
            ;;
        job.yaml|job.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/job.yaml.template"
            ;;
        statefulset.yaml|statefulset.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/statefulset.yaml.template"
            ;;
        daemonset.yaml|daemonset.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/daemonset.yaml.template"
            ;;
        namespace.yaml|namespace.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/namespace.yaml.template"
            ;;
        pvc.yaml|pvc.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/pvc.yaml.template"
            ;;
        values.yaml|values.yml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/values.yaml.template"
            ;;
        Chart.yaml)
            template_path="${TEMPLATE_BASE_DIR}/kubernetes/Chart.yaml.template"
            ;;

        # Terraform patterns
        *.tf)
            if [[ "$filename" == main.tf ]]; then
                template_path="${TEMPLATE_BASE_DIR}/terraform/main.tf.template"
            elif [[ "$filename" == variables.tf ]]; then
                template_path="${TEMPLATE_BASE_DIR}/terraform/variables.tf.template"
            elif [[ "$filename" == outputs.tf ]]; then
                template_path="${TEMPLATE_BASE_DIR}/terraform/outputs.tf.template"
            elif [[ "$filename" =~ vpc ]]; then
                template_path="${TEMPLATE_BASE_DIR}/terraform/vpc.tf.template"
            elif [[ "$filename" =~ rds ]]; then
                template_path="${TEMPLATE_BASE_DIR}/terraform/rds.tf.template"
            elif [[ "$filename" =~ s3 ]]; then
                template_path="${TEMPLATE_BASE_DIR}/terraform/s3.tf.template"
            elif [[ "$filename" =~ eks ]]; then
                template_path="${TEMPLATE_BASE_DIR}/terraform/eks.tf.template"
            elif [[ "$filename" =~ alb || "$filename" =~ lb ]]; then
                template_path="${TEMPLATE_BASE_DIR}/terraform/alb.tf.template"
            elif [[ "$filename" =~ security.*group || "$filename" =~ sg ]]; then
                template_path="${TEMPLATE_BASE_DIR}/terraform/security-group.tf.template"
            elif [[ "$filename" =~ iam ]]; then
                template_path="${TEMPLATE_BASE_DIR}/terraform/iam-role.tf.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/terraform/main.tf.template"
            fi
            ;;

        # Package/Config files
        package.json)
            if [[ "$file_path" =~ react || "$file_path" =~ frontend || "$file_path" =~ ui ]]; then
                template_path="${TEMPLATE_BASE_DIR}/react-typescript/package.json.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/package.json.template"
            fi
            ;;
        tsconfig.json)
            if [[ "$file_path" =~ react || "$file_path" =~ frontend ]]; then
                template_path="${TEMPLATE_BASE_DIR}/react-typescript/tsconfig.json.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/tsconfig.json.template"
            fi
            ;;
        .eslintrc.json)
            if [[ "$file_path" =~ react || "$file_path" =~ frontend ]]; then
                template_path="${TEMPLATE_BASE_DIR}/react-typescript/eslintrc.json.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/.eslintrc.json.template"
            fi
            ;;
        .prettierrc.json)
            if [[ "$file_path" =~ react || "$file_path" =~ frontend ]]; then
                template_path="${TEMPLATE_BASE_DIR}/react-typescript/.prettierrc.json.template"
            else
                template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/.prettierrc.json.template"
            fi
            ;;
        *)
            # Default fallback based on extension
            case "$extension" in
                java)
                    template_path="${TEMPLATE_BASE_DIR}/java-spring-boot/entity.java.template"
                    ;;
                ts)
                    template_path="${TEMPLATE_BASE_DIR}/nodejs-typescript/service.ts.template"
                    ;;
                tsx)
                    template_path="${TEMPLATE_BASE_DIR}/react-typescript/component.tsx.template"
                    ;;
                sql)
                    template_path="${TEMPLATE_BASE_DIR}/database/create-table.sql.template"
                    ;;
                tf)
                    template_path="${TEMPLATE_BASE_DIR}/terraform/main.tf.template"
                    ;;
                yaml|yml)
                    template_path="${TEMPLATE_BASE_DIR}/kubernetes/deployment.yaml.template"
                    ;;
            esac
            ;;
    esac

    # Verify template exists
    if [[ -n "$template_path" ]] && [[ -f "$template_path" ]]; then
        echo "$template_path"
    else
        echo "ERROR: No template found for: $file_path" >&2
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Variable Extraction Functions
# -----------------------------------------------------------------------------

# Extract variables from context (filename, repo name, PR title, branch)
# Args: filename, repo_name, pr_title, branch_name
# Returns: Variables as KEY=VALUE format (one per line)
extract_variables() {
    local filename="$1"
    local repo_name="${2:-unknown-repo}"
    local pr_title="${3:-}"
    local branch_name="${4:-}"

    # Extract base name without extension
    local basename=$(basename "$filename")
    local name_without_ext="${basename%.*}"

    # Initialize empty variables
    local CONTROLLER_NAME=""
    local ENTITY_NAME=""
    local SERVICE_NAME=""
    local BASE_PATH=""
    local REPOSITORY_NAME=""
    local TABLE_NAME=""
    local CLASS_NAME=""
    local COMPONENT_NAME=""
    local PROPS=""
    local HOOK_NAME=""
    local MODEL_NAME=""
    local BACKEND_URL=""
    local PACKAGE_NAME=""
    local FEATURE_NAME=""
    local REPO_NAME=""
    local AUTHOR="Generated"
    local VERSION="1.0.0"
    local ENVIRONMENT="production"
    local PROJECT=""
    local DB_NAME=""
    local NAMESPACE="default"
    local APP_NAME=""
    local IMAGE_NAME=""
    local REPLICAS="3"
    local VPC_ID="vpc-xxxxx"
    local SUBNET_IDS='["subnet-xxxxx", "subnet-yyyyy"]'

    # Handle Java class names (Controller, Service, etc.)
    if [[ "$basename" =~ Controller\.java$ ]]; then
        local entity="${name_without_ext%Controller}"
        CONTROLLER_NAME="$name_without_ext"
        ENTITY_NAME="$entity"
        SERVICE_NAME="${entity}Service"
        BASE_PATH="/api/v1/$(echo "$entity" | sed 's/\([A-Z]\)/-\1/g' | sed 's/^-//' | tr '[:upper:]' '[:lower:]')s"
    elif [[ "$basename" =~ Service\.java$ ]] || [[ "$basename" =~ ServiceImpl\.java$ ]]; then
        local entity="${name_without_ext%Service}"
        entity="${entity%Impl}"
        SERVICE_NAME="$name_without_ext"
        ENTITY_NAME="$entity"
        REPOSITORY_NAME="${entity}Repository"
    elif [[ "$basename" =~ Repository\.java$ ]]; then
        local entity="${name_without_ext%Repository}"
        REPOSITORY_NAME="$name_without_ext"
        ENTITY_NAME="$entity"
    elif [[ "$basename" =~ Entity\.java$ ]]; then
        local entity="${name_without_ext%Entity}"
        ENTITY_NAME="$name_without_ext"
        TABLE_NAME=$(echo "$entity" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//' | tr '[:upper:]' '[:lower:]')s
    elif [[ "$basename" =~ \.java$ ]]; then
        CLASS_NAME="$name_without_ext"
        ENTITY_NAME="$name_without_ext"
    fi

    # Handle TypeScript/React components
    if [[ "$basename" =~ \.tsx$ ]]; then
        local component="$name_without_ext"
        component="${component%.test}"
        component="${component%.spec}"
        COMPONENT_NAME="$component"
        PROPS="// Add props here"
    elif [[ "$basename" =~ ^use.*\.ts$ ]]; then
        HOOK_NAME="$name_without_ext"
    fi

    # Handle TypeScript service files
    if [[ "$basename" =~ \.service\.ts$ ]]; then
        local service="${name_without_ext%.service}"
        SERVICE_NAME="$(capitalize_first "$service")"
        MODEL_NAME="$(capitalize_first "$service")"
        BACKEND_URL="$(echo "$service" | tr '[:lower:]' '[:upper:]')_BACKEND_URL"
    fi

    # Handle SQL migration files - extract table name
    if [[ "$basename" =~ \.sql$ ]]; then
        # Try to extract table name from filename patterns like:
        # 001_create_users_table.sql -> users
        # create_products_table.sql -> products
        # add_user_schema.sql -> user
        if [[ "$basename" =~ create_([a-z_]+)_table ]]; then
            TABLE_NAME="${BASH_REMATCH[1]}"
        elif [[ "$basename" =~ ([a-z_]+)_table ]]; then
            TABLE_NAME="${BASH_REMATCH[1]}"
        elif [[ "$pr_title" =~ ([A-Z][a-z]+).*table ]]; then
            TABLE_NAME=$(echo "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')s
        fi

        # Extract entity name from table name if available
        if [[ -n "$TABLE_NAME" ]] && [[ -z "$ENTITY_NAME" ]]; then
            # Remove trailing 's' for entity name and capitalize
            local entity_base="${TABLE_NAME%s}"
            ENTITY_NAME="$(to_pascal_case "$entity_base")"
        fi
    fi

    # Extract from repo name
    local service_name=$(echo "$repo_name" | sed 's/-service$//' | sed 's/-api$//' | sed 's/-ui$//')
    REPO_NAME="$repo_name"
    [[ -z "$SERVICE_NAME" ]] && SERVICE_NAME="$(capitalize_first "$service_name")"

    # Extract package name for Java
    if [[ "$basename" =~ \.java$ ]] && [[ -z "$PACKAGE_NAME" ]]; then
        PACKAGE_NAME="com.example.$(echo "$service_name" | tr '-' '.')"
    fi

    # Extract entity name from PR title if not set
    if [[ -n "$pr_title" ]] && [[ -z "$ENTITY_NAME" ]]; then
        # Look for patterns like "Add user", "Update product", "Create order"
        if [[ "$pr_title" =~ (Add|Create|Update|Implement|Build)\ ([A-Z][a-z]+) ]]; then
            ENTITY_NAME="${BASH_REMATCH[2]}"
        fi
    fi

    # Extract from branch name
    if [[ -n "$branch_name" ]]; then
        if [[ "$branch_name" =~ feature/([^/]+) ]]; then
            FEATURE_NAME="${BASH_REMATCH[1]}"
            [[ -z "$ENTITY_NAME" ]] && ENTITY_NAME="$(capitalize_first "$FEATURE_NAME")"
        fi
    fi

    # Set remaining defaults
    PROJECT="${repo_name}"
    DB_NAME="${service_name}_db"
    [[ -z "$TABLE_NAME" ]] && TABLE_NAME="items"
    APP_NAME="${service_name}"
    IMAGE_NAME="${service_name}"

    # SQL-specific defaults
    local COLUMNS="${COLUMNS:-name VARCHAR(255) NOT NULL,\n    description TEXT,\n    status VARCHAR(50) DEFAULT 'active'}"
    local DESCRIPTION="${DESCRIPTION:-Auto-generated table for $TABLE_NAME}"
    local INDEX_NAME="${INDEX_NAME:-idx_${TABLE_NAME}_name}"
    local CONSTRAINT_NAME="${CONSTRAINT_NAME:-fk_${TABLE_NAME}_ref}"

    # Kubernetes-specific defaults
    local IMAGE="${IMAGE:-${service_name}:latest}"
    local IMAGE_PULL_POLICY="${IMAGE_PULL_POLICY:-IfNotPresent}"
    local IMAGE_PULL_SECRETS="${IMAGE_PULL_SECRETS:-}"
    local CONTAINER_PORT="${CONTAINER_PORT:-8080}"
    local LOG_LEVEL="${LOG_LEVEL:-info}"
    local ADDITIONAL_ENV_VARS="${ADDITIONAL_ENV_VARS:-}"
    local CPU_REQUEST="${CPU_REQUEST:-100m}"
    local CPU_LIMIT="${CPU_LIMIT:-500m}"
    local MEMORY_REQUEST="${MEMORY_REQUEST:-128Mi}"
    local MEMORY_LIMIT="${MEMORY_LIMIT:-512Mi}"
    local SERVICE_PORT="${SERVICE_PORT:-80}"
    local TARGET_PORT="${TARGET_PORT:-8080}"
    local LIVENESS_PATH="${LIVENESS_PATH:-/health}"
    local LIVENESS_INITIAL_DELAY="${LIVENESS_INITIAL_DELAY:-30}"
    local LIVENESS_PERIOD="${LIVENESS_PERIOD:-10}"
    local LIVENESS_TIMEOUT="${LIVENESS_TIMEOUT:-5}"
    local LIVENESS_FAILURE_THRESHOLD="${LIVENESS_FAILURE_THRESHOLD:-3}"
    local READINESS_PATH="${READINESS_PATH:-/ready}"
    local READINESS_INITIAL_DELAY="${READINESS_INITIAL_DELAY:-10}"
    local READINESS_PERIOD="${READINESS_PERIOD:-5}"
    local READINESS_TIMEOUT="${READINESS_TIMEOUT:-3}"
    local READINESS_FAILURE_THRESHOLD="${READINESS_FAILURE_THRESHOLD:-3}"
    local RUN_AS_USER="${RUN_AS_USER:-1000}"
    local FS_GROUP="${FS_GROUP:-2000}"
    local VOLUMES="${VOLUMES:-}"
    local VOLUME_MOUNTS="${VOLUME_MOUNTS:-}"

    # Terraform-specific defaults
    local REGION="${REGION:-us-east-1}"
    local AVAILABILITY_ZONES="${AVAILABILITY_ZONES:-[\"us-east-1a\", \"us-east-1b\", \"us-east-1c\"]}"
    local VPC_NAME="${VPC_NAME:-${service_name}-vpc}"
    local CIDR_BLOCK="${CIDR_BLOCK:-10.0.0.0/16}"
    local INSTANCE_TYPE="${INSTANCE_TYPE:-t3.medium}"
    local KEY_NAME="${KEY_NAME:-${service_name}-key}"

    # Output as KEY=VALUE format
    echo "CONTROLLER_NAME=$CONTROLLER_NAME"
    echo "ENTITY_NAME=$ENTITY_NAME"
    echo "SERVICE_NAME=$SERVICE_NAME"
    echo "BASE_PATH=$BASE_PATH"
    echo "REPOSITORY_NAME=$REPOSITORY_NAME"
    echo "TABLE_NAME=$TABLE_NAME"
    echo "CLASS_NAME=$CLASS_NAME"
    echo "COMPONENT_NAME=$COMPONENT_NAME"
    echo "PROPS=$PROPS"
    echo "HOOK_NAME=$HOOK_NAME"
    echo "MODEL_NAME=$MODEL_NAME"
    echo "BACKEND_URL=$BACKEND_URL"
    echo "PACKAGE_NAME=$PACKAGE_NAME"
    echo "FEATURE_NAME=$FEATURE_NAME"
    echo "REPO_NAME=$REPO_NAME"
    echo "AUTHOR=$AUTHOR"
    echo "VERSION=$VERSION"
    echo "ENVIRONMENT=$ENVIRONMENT"
    echo "PROJECT=$PROJECT"
    echo "DB_NAME=$DB_NAME"
    echo "NAMESPACE=$NAMESPACE"
    echo "APP_NAME=$APP_NAME"
    echo "IMAGE_NAME=$IMAGE_NAME"
    echo "REPLICAS=$REPLICAS"
    echo "VPC_ID=$VPC_ID"
    echo "SUBNET_IDS=$SUBNET_IDS"
    echo "COLUMNS=$COLUMNS"
    echo "DESCRIPTION=$DESCRIPTION"
    echo "INDEX_NAME=$INDEX_NAME"
    echo "CONSTRAINT_NAME=$CONSTRAINT_NAME"
    echo "IMAGE=$IMAGE"
    echo "IMAGE_PULL_POLICY=$IMAGE_PULL_POLICY"
    echo "IMAGE_PULL_SECRETS=$IMAGE_PULL_SECRETS"
    echo "CONTAINER_PORT=$CONTAINER_PORT"
    echo "LOG_LEVEL=$LOG_LEVEL"
    echo "ADDITIONAL_ENV_VARS=$ADDITIONAL_ENV_VARS"
    echo "CPU_REQUEST=$CPU_REQUEST"
    echo "CPU_LIMIT=$CPU_LIMIT"
    echo "MEMORY_REQUEST=$MEMORY_REQUEST"
    echo "MEMORY_LIMIT=$MEMORY_LIMIT"
    echo "SERVICE_PORT=$SERVICE_PORT"
    echo "TARGET_PORT=$TARGET_PORT"
    echo "LIVENESS_PATH=$LIVENESS_PATH"
    echo "LIVENESS_INITIAL_DELAY=$LIVENESS_INITIAL_DELAY"
    echo "LIVENESS_PERIOD=$LIVENESS_PERIOD"
    echo "LIVENESS_TIMEOUT=$LIVENESS_TIMEOUT"
    echo "LIVENESS_FAILURE_THRESHOLD=$LIVENESS_FAILURE_THRESHOLD"
    echo "READINESS_PATH=$READINESS_PATH"
    echo "READINESS_INITIAL_DELAY=$READINESS_INITIAL_DELAY"
    echo "READINESS_PERIOD=$READINESS_PERIOD"
    echo "READINESS_TIMEOUT=$READINESS_TIMEOUT"
    echo "READINESS_FAILURE_THRESHOLD=$READINESS_FAILURE_THRESHOLD"
    echo "RUN_AS_USER=$RUN_AS_USER"
    echo "FS_GROUP=$FS_GROUP"
    echo "VOLUMES=$VOLUMES"
    echo "VOLUME_MOUNTS=$VOLUME_MOUNTS"
    echo "REGION=$REGION"
    echo "AVAILABILITY_ZONES=$AVAILABILITY_ZONES"
    echo "VPC_NAME=$VPC_NAME"
    echo "CIDR_BLOCK=$CIDR_BLOCK"
    echo "INSTANCE_TYPE=$INSTANCE_TYPE"
    echo "KEY_NAME=$KEY_NAME"
}

# Capitalize first letter
capitalize_first() {
    local str="$1"
    echo "$(echo "${str:0:1}" | tr '[:lower:]' '[:upper:]')${str:1}"
}

# Convert camelCase or PascalCase to snake_case
to_snake_case() {
    local str="$1"
    echo "$str" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//' | tr '[:upper:]' '[:lower:]'
}

# Convert snake_case to PascalCase
to_pascal_case() {
    local str="$1"
    # First capitalize the first letter, then capitalize letters after underscores and remove underscores
    echo "$str" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1' OFS=''
}

# -----------------------------------------------------------------------------
# Template Application Functions
# -----------------------------------------------------------------------------

# Apply template with variable substitution
# Args: template_path, output_path, vars_str (KEY=VALUE format)
apply_template() {
    local template_path="$1"
    local output_path="$2"
    local vars_str="$3"

    if [[ ! -f "$template_path" ]]; then
        echo "ERROR: Template not found: $template_path" >&2
        return 1
    fi

    # Read template content
    local content=$(cat "$template_path")

    # Parse variables from KEY=VALUE format and replace placeholders
    while IFS='=' read -r key value; do
        if [[ -n "$key" ]]; then
            # Escape special characters in value for sed (handle empty values too)
            local escaped_value=$(echo "$value" | sed 's/[\/&]/\\&/g')
            content=$(echo "$content" | sed "s/{{${key}}}/${escaped_value}/g")
        fi
    done <<< "$vars_str"

    # Create output directory if it doesn't exist
    local output_dir=$(dirname "$output_path")
    mkdir -p "$output_dir"

    # Write output
    echo "$content" > "$output_path"

    echo "Generated: $output_path"
}

# Generate code for a single file
# Args: file_path, repo_path, repo_name, pr_title, branch_name
generate_file() {
    local file_path="$1"
    local repo_path="$2"
    local repo_name="$3"
    local pr_title="${4:-}"
    local branch_name="${5:-}"

    echo "Generating file: $file_path"

    # Select appropriate template
    local template_path
    template_path=$(select_template "$file_path") || return 1

    echo "  Using template: $template_path"

    # Extract variables
    local vars_str
    vars_str=$(extract_variables "$file_path" "$repo_name" "$pr_title" "$branch_name")

    # Apply template
    local output_path="${repo_path}/${file_path}"
    apply_template "$template_path" "$output_path" "$vars_str"
}

# -----------------------------------------------------------------------------
# PR Code Generation Functions
# -----------------------------------------------------------------------------

# Generate code for all files in a PR
# Args: pr_id, pr_config_file, repo_path
generate_pr_code() {
    local pr_id="$1"
    local pr_config_file="$2"
    local repo_path="$3"

    if [[ ! -f "$pr_config_file" ]]; then
        echo "ERROR: PR config file not found: $pr_config_file" >&2
        return 1
    fi

    echo "Generating code for PR #${pr_id}"

    # Parse PR config (JSON format expected)
    local pr_title=$(jq -r '.title' "$pr_config_file")
    local branch_name=$(jq -r '.branch' "$pr_config_file")
    local repo_name=$(jq -r '.repo' "$pr_config_file")
    local files=$(jq -r '.files[]' "$pr_config_file")

    echo "  Title: $pr_title"
    echo "  Branch: $branch_name"
    echo "  Repository: $repo_name"
    echo "  Files to generate: $(echo "$files" | wc -l)"

    # Generate each file
    local success_count=0
    local fail_count=0

    while IFS= read -r file; do
        if generate_file "$file" "$repo_path" "$repo_name" "$pr_title" "$branch_name"; then
            ((success_count++))
        else
            echo "  WARNING: Failed to generate: $file" >&2
            ((fail_count++))
        fi
    done <<< "$files"

    echo ""
    echo "Summary for PR #${pr_id}:"
    echo "  Successfully generated: $success_count files"
    echo "  Failed: $fail_count files"

    return 0
}

# Generate code for multiple PRs
# Args: pr_config_dir, repo_path
generate_all_prs() {
    local pr_config_dir="$1"
    local repo_path="$2"

    if [[ ! -d "$pr_config_dir" ]]; then
        echo "ERROR: PR config directory not found: $pr_config_dir" >&2
        return 1
    fi

    echo "Generating code for all PRs in: $pr_config_dir"
    echo ""

    local total_prs=0
    local success_prs=0

    # Find all PR config files
    for pr_config in "$pr_config_dir"/pr-*.json; do
        if [[ -f "$pr_config" ]]; then
            local pr_id=$(basename "$pr_config" | sed 's/pr-\([0-9]*\).*/\1/')

            if generate_pr_code "$pr_id" "$pr_config" "$repo_path"; then
                ((success_prs++))
            fi
            ((total_prs++))

            echo ""
        fi
    done

    echo "=========================================="
    echo "All PRs Generation Complete"
    echo "=========================================="
    echo "Total PRs processed: $total_prs"
    echo "Successfully generated: $success_prs"
    echo "Failed: $((total_prs - success_prs))"
}

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------

# List all available templates
list_templates() {
    echo "Available templates in: $TEMPLATE_BASE_DIR"
    echo ""

    for category in java-spring-boot react-typescript nodejs-typescript kubernetes terraform database; do
        local category_dir="${TEMPLATE_BASE_DIR}/${category}"
        if [[ -d "$category_dir" ]]; then
            echo "[$category]"
            find "$category_dir" -name "*.template" -type f | while read -r template; do
                echo "  - $(basename "$template" .template)"
            done
            echo ""
        fi
    done
}

# Test template selection
test_template_selection() {
    local test_files=(
        "src/main/java/com/example/controller/UserController.java"
        "src/main/java/com/example/service/UserService.java"
        "src/components/UserProfile.tsx"
        "src/services/api.service.ts"
        "src/hooks/useAuth.ts"
        "migrations/001_create_users_table.sql"
        "infrastructure/vpc.tf"
        "k8s/deployment.yaml"
        "package.json"
        "pom.xml"
    )

    echo "Testing template selection:"
    echo ""

    for file in "${test_files[@]}"; do
        echo -n "  $file -> "
        if template=$(select_template "$file" 2>/dev/null); then
            echo "$(basename "$template")"
        else
            echo "NO TEMPLATE"
        fi
    done
}

# Export functions for use in other scripts
export -f select_template
export -f extract_variables
export -f apply_template
export -f generate_file
export -f generate_pr_code
export -f generate_all_prs
export -f list_templates
export -f test_template_selection
export -f capitalize_first
export -f to_snake_case
export -f to_pascal_case
