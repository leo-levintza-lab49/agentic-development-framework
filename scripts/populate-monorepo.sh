#!/bin/bash
# Main script to populate enterprise monorepo with services and configuration

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/scaffolding.sh"
source "$SCRIPT_DIR/lib/monorepo-scaffolding.sh"

# Configuration
MONOREPO_PATH="/Users/leo.levintza/wrk/omnybase/enterprise-monorepo"

# Main execution
main() {
    print_header "Enterprise Monorepo Population"
    echo "Target: $MONOREPO_PATH"
    echo ""

    # Validate environment
    if [ ! -d "$MONOREPO_PATH" ]; then
        print_error "Monorepo directory not found: $MONOREPO_PATH"
        exit 1
    fi

    cd "$MONOREPO_PATH"

    # Phase 1: Generate root workspace configuration
    print_header "Phase 1: Root Workspace Configuration"
    generate_monorepo_workspace "$MONOREPO_PATH"

    # Phase 2: Generate shared libraries
    print_header "Phase 2: Shared Libraries"
    generate_shared_libraries "$MONOREPO_PATH"

    # Phase 3: Generate Maven parent POMs for Java teams
    print_header "Phase 3: Maven Parent POMs"
    generate_maven_parent_pom "$MONOREPO_PATH" "user-services"
    generate_maven_parent_pom "$MONOREPO_PATH" "business-services"

    # Phase 4: Generate documentation
    print_header "Phase 4: Documentation"
    generate_monorepo_docs "$MONOREPO_PATH"

    # Phase 5: Generate CI/CD workflows
    print_header "Phase 5: CI/CD Workflows"
    generate_monorepo_ci "$MONOREPO_PATH"

    # Phase 6: Generate tooling
    print_header "Phase 6: Tooling Scripts"
    generate_monorepo_tooling "$MONOREPO_PATH"

    print_success "======================================"
    print_success "Monorepo foundation setup complete!"
    print_success "======================================"
    echo ""
    echo "Next steps:"
    echo "1. cd $MONOREPO_PATH"
    echo "2. Run: make install"
    echo "3. Populate services using service generation scripts"
    echo ""
}

# Generate documentation
generate_monorepo_docs() {
    local monorepo_path=$1
    print_info "Generating documentation..."

    mkdir -p "$monorepo_path/docs"

    # ARCHITECTURE.md
    cat > "$monorepo_path/docs/ARCHITECTURE.md" <<'EOF'
# Architecture Overview

## Monorepo Structure

This is an enterprise monorepo containing all services organized by team.

### Build System

- **TypeScript/Node/React**: Nx workspace with affected detection
- **Java**: Maven multi-module with parent POMs
- **Orchestration**: Makefile for unified commands

### Teams and Services

- **data-platform**: Database schemas and migrations
- **user-services**: User management (Java/Spring Boot)
- **business-services**: Core business logic (Java/Spring Boot)
- **bff**: Backend-for-Frontend services (Node/TypeScript)
- **web-frontend**: Web applications (React/Vite)
- **mobile**: Mobile applications (iOS/Android)
- **platform**: Infrastructure as Code (Terraform)

### Shared Libraries

- `shared/typescript/common-utils`: Common utilities
- `shared/typescript/domain-models`: Shared data models
- `shared/java/common-lib`: Java common library

### CI/CD

- Affected services detection
- Parallel builds and tests
- Docker containerization
EOF

    # GETTING_STARTED.md
    cat > "$monorepo_path/docs/GETTING_STARTED.md" <<'EOF'
# Getting Started

## Prerequisites

- Node.js 18+
- Java 17+
- Maven 3.8+
- Docker & Docker Compose

## Setup

1. Clone the repository
2. Install dependencies: `make install`
3. Start local services: `make dev`
4. Build all: `make build`
5. Run tests: `make test`

## Common Commands

- `make build` - Build all services
- `make test` - Run all tests
- `make affected` - Build/test only affected services
- `make lint` - Lint all code
- `make clean` - Clean build artifacts

## Development Workflow

1. Create feature branch
2. Make changes
3. Run affected tests: `make affected`
4. Commit with conventional commits
5. Create pull request
EOF

    # SERVICES.md
    cat > "$monorepo_path/docs/SERVICES.md" <<'EOF'
# Service Registry

## Data Platform Team

### db-schemas
- **Tech**: Database schemas
- **Path**: teams/data-platform/db-schemas

### db-migrations
- **Tech**: Liquibase migrations
- **Path**: teams/data-platform/db-migrations

## User Services Team

### user-service
- **Tech**: Java 17, Spring Boot 3.2
- **Port**: 8081
- **Path**: teams/user-services/user-service

### auth-service
- **Tech**: Java 17, Spring Boot 3.2
- **Port**: 8082
- **Path**: teams/user-services/auth-service

## Business Services Team

### order-service
- **Tech**: Java 17, Spring Boot 3.2
- **Port**: 8083
- **Path**: teams/business-services/order-service

### payment-service
- **Tech**: Java 17, Spring Boot 3.2
- **Port**: 8084
- **Path**: teams/business-services/payment-service

### notification-service
- **Tech**: Java 17, Spring Boot 3.2
- **Port**: 8085
- **Path**: teams/business-services/notification-service

## BFF Team

### web-bff
- **Tech**: Node 18, TypeScript, Express
- **Port**: 3001
- **Path**: teams/bff/web-bff

### mobile-bff
- **Tech**: Node 18, TypeScript, Express
- **Port**: 3002
- **Path**: teams/bff/mobile-bff

### graphql-gateway
- **Tech**: Node 18, TypeScript, GraphQL
- **Port**: 4000
- **Path**: teams/bff/graphql-gateway

## Frontend Team

### web-app
- **Tech**: React 18, Vite
- **Port**: 3000
- **Path**: teams/web-frontend/web-app

### component-library
- **Tech**: React 18, Storybook
- **Path**: teams/web-frontend/component-library

## Mobile Team

### ios-app
- **Tech**: Swift, SwiftUI
- **Path**: teams/mobile/ios-app

### android-app
- **Tech**: Kotlin, Jetpack Compose
- **Path**: teams/mobile/android-app

### mobile-shared
- **Tech**: React Native
- **Path**: teams/mobile/mobile-shared

## Platform Team

### terraform-aws-infrastructure
- **Tech**: Terraform
- **Path**: teams/platform/terraform-aws-infrastructure

### grafana-dashboards
- **Tech**: Grafana config
- **Path**: teams/platform/grafana-dashboards

### prometheus-alerts
- **Tech**: Prometheus config
- **Path**: teams/platform/prometheus-alerts
EOF

    print_success "Documentation generated"
}

# Generate CI/CD workflows
generate_monorepo_ci() {
    local monorepo_path=$1
    print_info "Generating CI/CD workflows..."

    mkdir -p "$monorepo_path/.github/workflows"

    # Affected services CI
    cat > "$monorepo_path/.github/workflows/ci-affected.yml" <<'EOF'
name: CI - Affected Services

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  affected:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run affected builds
        run: npm run affected:build

      - name: Run affected tests
        run: npm run affected:test
EOF

    # CODEOWNERS
    cat > "$monorepo_path/.github/CODEOWNERS" <<'EOF'
# Enterprise Monorepo Code Owners

# Team ownership
/teams/data-platform/       @omnibase-poc/data-platform-team
/teams/user-services/       @omnibase-poc/backend-engineers
/teams/business-services/   @omnibase-poc/backend-engineers
/teams/bff/                 @omnibase-poc/bff-team
/teams/web-frontend/        @omnibase-poc/frontend-engineers
/teams/mobile/              @omnibase-poc/mobile-engineers
/teams/platform/            @omnibase-poc/platform-sre

# Shared code requires multiple approvals
/shared/                    @omnibase-poc/backend-engineers @omnibase-poc/bff-team

# Root configuration
/nx.json                    @omnibase-poc/platform-sre
/package.json               @omnibase-poc/platform-sre
/Makefile                   @omnibase-poc/platform-sre
EOF

    print_success "CI/CD workflows generated"
}

# Generate tooling scripts
generate_monorepo_tooling() {
    local monorepo_path=$1
    print_info "Generating tooling scripts..."

    mkdir -p "$monorepo_path/tools/scripts"

    # Affected services detection script
    cat > "$monorepo_path/tools/scripts/affected-services.sh" <<'EOF'
#!/bin/bash
# Detect affected services using Nx

echo "Detecting affected services..."
npx nx affected:apps --base=origin/main --head=HEAD
EOF

    chmod +x "$monorepo_path/tools/scripts/affected-services.sh"

    # Run tests script
    cat > "$monorepo_path/tools/scripts/run-tests.sh" <<'EOF'
#!/bin/bash
# Run tests for a specific service or all affected

SERVICE=$1

if [ -z "$SERVICE" ]; then
    echo "Running tests for affected services..."
    npm run affected:test
elif [ "$SERVICE" = "all" ]; then
    echo "Running all tests..."
    npm test
else
    echo "Running tests for $SERVICE..."
    npm test --scope="$SERVICE"
fi
EOF

    chmod +x "$monorepo_path/tools/scripts/run-tests.sh"

    print_success "Tooling scripts generated"
}

# Execute main
main "$@"
