#!/bin/bash
#
# Scaffolding Generation Functions
#

# Source utilities if not already loaded
if [ -z "$UTILS_LOADED" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/utils.sh"
fi

# Template directory (handle both direct execution and sourcing)
if [ -n "$PROJECT_ROOT" ]; then
    TEMPLATE_DIR="$PROJECT_ROOT/templates"
else
    TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../templates" && pwd)"
fi

# Generate scaffolding based on repository type
generate_scaffolding() {
    local org=$1
    local repo=$2
    local type=$3
    local description=$4
    local team=${5:-all}

    local repo_path=$(get_repo_path "$org" "$repo")

    print_info "Generating scaffolding for $org/$repo (type: $type)..."

    # Create repository directory
    mkdir -p "$repo_path"
    cd "$repo_path" || return 1

    # Generate common files
    generate_common_files "$org" "$repo" "$description" "$team"

    # Generate type-specific files
    case "$type" in
        java-service)
            generate_java_service_files "$org" "$repo" "$description"
            ;;
        node-service)
            generate_node_service_files "$org" "$repo" "$description"
            ;;
        react-app)
            generate_react_app_files "$org" "$repo" "$description"
            ;;
        database)
            generate_database_files "$org" "$repo" "$description"
            ;;
        terraform)
            generate_terraform_files "$org" "$repo" "$description"
            ;;
        mobile-ios)
            generate_ios_files "$org" "$repo" "$description"
            ;;
        mobile-android)
            generate_android_files "$org" "$repo" "$description"
            ;;
        config)
            generate_config_files "$org" "$repo" "$description"
            ;;
        monorepo)
            generate_monorepo_files "$org" "$repo" "$description"
            ;;
        *)
            print_warning "Unknown type: $type, using basic scaffolding"
            ;;
    esac

    print_success "Scaffolding generated for $org/$repo"
    return 0
}

# Generate common files for all repositories
generate_common_files() {
    local org=$1
    local repo=$2
    local description=$3
    local team=$4

    # Create directory structure
    mkdir -p .claude/rules
    mkdir -p .github/workflows

    # Generate README
    generate_readme "$org" "$repo" "$description" "$team"

    # Generate Claude settings
    generate_claude_settings "$org" "$repo" "$team"

    # Copy common Claude rules
    cp "$TEMPLATE_DIR/common/security-rule.md" .claude/rules/security.md
    cp "$TEMPLATE_DIR/common/code-quality-rule.md" .claude/rules/code-quality.md
    cp "$TEMPLATE_DIR/common/git-workflow-rule.md" .claude/rules/git-workflow.md

    # Generate PR template
    cp "$TEMPLATE_DIR/common/PULL_REQUEST_TEMPLATE.md" .github/PULL_REQUEST_TEMPLATE.md

    # Generate .gitignore
    generate_gitignore "$org" "$repo"

    # Generate LICENSE
    generate_license "$org" "$repo"
}

# Generate README.md
generate_readme() {
    local org=$1
    local repo=$2
    local description=$3
    local team=$4

    cat > README.md << EOF
# $repo

$description

## Overview

This repository is part of the $org organization.

## Team

**Owner**: $team

## Getting Started

\`\`\`bash
# Clone the repository
git clone https://github.com/$org/$repo.git
cd $repo
\`\`\`

## Claude Code Configuration

This repository uses Claude Code for AI-assisted development.

\`\`\`bash
# Start Claude Code
claude code
\`\`\`

## Development

See the team-specific documentation for development guidelines.

## License

Proprietary - All Rights Reserved
EOF
}

# Generate Claude settings.json
generate_claude_settings() {
    local org=$1
    local repo=$2
    local team=$3

    cat > .claude/settings.json << EOF
{
  "version": "1.0",
  "projectName": "$repo",
  "organization": "$org",
  "team": "$team",
  "rules": [
    ".claude/rules/security.md",
    ".claude/rules/code-quality.md",
    ".claude/rules/git-workflow.md"
  ],
  "statusline": {
    "enabled": true,
    "format": "[$repo] {branch} {status}"
  },
  "integrations": {
    "github": {
      "enabled": true,
      "org": "$org",
      "repo": "$repo"
    }
  }
}
EOF
}

# Generate .gitignore
generate_gitignore() {
    local org=$1
    local repo=$2

    cat > .gitignore << 'EOF'
# OS files
.DS_Store
Thumbs.db

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# Environment
.env
.env.local
.envrc

# Logs
logs/
*.log

# Dependencies
node_modules/
target/
dist/
build/

# Temporary files
tmp/
temp/
*.tmp
EOF
}

# Generate LICENSE
generate_license() {
    local org=$1
    local repo=$2
    local year=$(date +%Y)

    cat > LICENSE << EOF
Copyright (c) $year $org

All Rights Reserved.

This software is proprietary and confidential.
EOF
}

# Generate Java service files
generate_java_service_files() {
    local org=$1
    local repo=$2
    local description=$3

    print_info "Generating Java service scaffolding..."

    # Create directory structure
    mkdir -p src/main/java/com/${org//-/}/$(echo $repo | tr '-' '_')
    mkdir -p src/main/resources
    mkdir -p src/test/java/com/${org//-/}/$(echo $repo | tr '-' '_')

    # Copy templates
    local package_name=$(echo $repo | tr '-' '_')
    cp "$TEMPLATE_DIR/java-service/pom.xml.template" pom.xml
    sed -i '' "s/{{ORG_NAME}}/${org//-/}/g" pom.xml
    sed -i '' "s/{{REPO_NAME}}/$repo/g" pom.xml
    sed -i '' "s/{{DESCRIPTION}}/$description/g" pom.xml

    # Generate Dockerfile
    cat > Dockerfile << 'EOF'
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

    # Generate GitHub Actions workflow
    generate_java_workflow "$org" "$repo"
}

# Generate Node service files
generate_node_service_files() {
    local org=$1
    local repo=$2
    local description=$3

    print_info "Generating Node.js service scaffolding..."

    # Create directory structure
    mkdir -p src
    mkdir -p tests

    # Copy templates
    cp "$TEMPLATE_DIR/node-service/package.json.template" package.json
    cp "$TEMPLATE_DIR/node-service/tsconfig.json.template" tsconfig.json

    sed -i '' "s/{{REPO_NAME}}/$repo/g" package.json
    sed -i '' "s/{{DESCRIPTION}}/$description/g" package.json
    sed -i '' "s/{{ORG_NAME}}/$org/g" package.json
    sed -i '' "s/{{TEAM_NAME}}/Backend Team/g" package.json

    # Generate basic index.ts
    cat > src/index.ts << 'EOF'
import express from 'express';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

    # Generate Dockerfile
    cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY dist ./dist
EXPOSE 3000
CMD ["npm", "start"]
EOF

    generate_node_workflow "$org" "$repo"
}

# Generate React app files
generate_react_app_files() {
    local org=$1
    local repo=$2
    local description=$3

    print_info "Generating React app scaffolding..."

    mkdir -p src public

    cp "$TEMPLATE_DIR/react-app/package.json.template" package.json
    cp "$TEMPLATE_DIR/react-app/vite.config.ts.template" vite.config.ts

    sed -i '' "s/{{REPO_NAME}}/$repo/g" package.json
    sed -i '' "s/{{DESCRIPTION}}/$description/g" package.json

    # Generate basic App.tsx
    cat > src/App.tsx << 'EOF'
function App() {
  return (
    <div>
      <h1>Welcome</h1>
    </div>
  );
}

export default App;
EOF

    generate_react_workflow "$org" "$repo"
}

# Generate database files
generate_database_files() {
    local org=$1
    local repo=$2
    local description=$3

    print_info "Generating database scaffolding..."

    mkdir -p migrations schemas

    cat > README.md << EOF
# $repo

$description

## Database Migrations

Place Liquibase or Flyway migration scripts in the \`migrations/\` directory.
EOF
}

# Generate terraform files
generate_terraform_files() {
    local org=$1
    local repo=$2
    local description=$3

    print_info "Generating Terraform scaffolding..."

    mkdir -p modules environments/{dev,staging,prod}

    cat > main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
}
EOF
}

# Generate config files
generate_config_files() {
    local org=$1
    local repo=$2
    local description=$3

    print_info "Generating config scaffolding..."
    # Basic scaffolding already created
}

# Generate iOS files
generate_ios_files() {
    local org=$1
    local repo=$2
    local description=$3

    print_info "Generating iOS scaffolding..."
    mkdir -p App
}

# Generate Android files
generate_android_files() {
    local org=$1
    local repo=$2
    local description=$3

    print_info "Generating Android scaffolding..."
    mkdir -p app/src/main
}

# Generate monorepo files
generate_monorepo_files() {
    local org=$1
    local repo=$2
    local description=$3

    print_info "Generating monorepo scaffolding..."

    mkdir -p teams/{data-platform,user-services,business-services,bff,web-frontend,mobile,platform}
    mkdir -p docs/architecture

    cat > README.md << EOF
# $repo

$description

## Structure

This is a monorepo containing all teams and services.

See \`teams/\` directory for individual team workspaces.
EOF
}

# Generate Java workflow
generate_java_workflow() {
    local org=$1
    local repo=$2

    cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Build with Maven
        run: mvn clean install
      - name: Run tests
        run: mvn test
EOF
}

# Generate Node workflow
generate_node_workflow() {
    local org=$1
    local repo=$2

    cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Lint
        run: npm run lint
      - name: Build
        run: npm run build
      - name: Test
        run: npm test
EOF
}

# Generate React workflow
generate_react_workflow() {
    local org=$1
    local repo=$2

    generate_node_workflow "$org" "$repo"  # Same as Node for now
}

export -f generate_scaffolding
export -f generate_common_files
