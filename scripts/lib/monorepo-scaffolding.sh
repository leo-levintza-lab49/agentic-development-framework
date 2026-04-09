#!/bin/bash
# Monorepo scaffolding library for enterprise monorepo setup

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

# Generate root Nx workspace configuration
generate_nx_config() {
    local monorepo_path=$1

    print_info "Generating Nx workspace configuration..."

    cat > "$monorepo_path/nx.json" << 'EOF'
{
  "$schema": "./node_modules/nx/schemas/nx-schema.json",
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],
      "cache": true
    },
    "test": {
      "cache": true
    },
    "lint": {
      "cache": true
    }
  },
  "affected": {
    "defaultBase": "main"
  },
  "tasksRunnerOptions": {
    "default": {
      "runner": "nx/tasks-runners/default",
      "options": {
        "cacheableOperations": ["build", "test", "lint"],
        "parallel": 3
      }
    }
  },
  "workspaceLayout": {
    "appsDir": "teams",
    "libsDir": "shared"
  }
}
EOF

    print_success "Nx configuration created"
}

# Generate root package.json with workspaces
generate_root_package_json() {
    local monorepo_path=$1

    print_info "Generating root package.json..."

    cat > "$monorepo_path/package.json" << 'EOF'
{
  "name": "enterprise-monorepo",
  "version": "1.0.0",
  "description": "Enterprise unified monorepo with all teams and services",
  "private": true,
  "workspaces": [
    "teams/*/*",
    "shared/*/*"
  ],
  "scripts": {
    "build": "nx run-many --target=build --all",
    "test": "nx run-many --target=test --all",
    "lint": "nx run-many --target=lint --all",
    "affected:build": "nx affected --target=build",
    "affected:test": "nx affected --target=test",
    "affected:lint": "nx affected --target=lint",
    "graph": "nx graph",
    "format": "prettier --write \"**/*.{ts,tsx,js,jsx,json,md}\"",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "@nx/workspace": "^18.0.0",
    "@nx/node": "^18.0.0",
    "@nx/react": "^18.0.0",
    "@nx/jest": "^18.0.0",
    "@nx/eslint": "^18.0.0",
    "@typescript-eslint/eslint-plugin": "^6.19.0",
    "@typescript-eslint/parser": "^6.19.0",
    "eslint": "^8.56.0",
    "eslint-config-prettier": "^9.1.0",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0",
    "jest": "^29.7.0",
    "nx": "^18.0.0",
    "prettier": "^3.2.4",
    "typescript": "^5.3.3"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
EOF

    print_success "Root package.json created"
}

# Generate base TypeScript configuration
generate_tsconfig_base() {
    local monorepo_path=$1

    print_info "Generating base TypeScript configuration..."

    cat > "$monorepo_path/tsconfig.base.json" << 'EOF'
{
  "compileOnSave": false,
  "compilerOptions": {
    "rootDir": ".",
    "sourceMap": true,
    "declaration": false,
    "moduleResolution": "node",
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "importHelpers": true,
    "target": "ES2022",
    "module": "esnext",
    "lib": ["ES2022", "dom"],
    "skipLibCheck": true,
    "skipDefaultLibCheck": true,
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@shared/common-utils": ["shared/typescript/common-utils/src/index.ts"],
      "@shared/domain-models": ["shared/typescript/domain-models/src/index.ts"]
    }
  },
  "exclude": ["node_modules", "tmp", "dist", "build", "target"]
}
EOF

    print_success "Base TypeScript configuration created"
}

# Generate ESLint configuration
generate_eslint_config() {
    local monorepo_path=$1

    print_info "Generating ESLint configuration..."

    cat > "$monorepo_path/.eslintrc.json" << 'EOF'
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module",
    "project": "./tsconfig.base.json"
  },
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "prettier"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "warn",
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "no-console": ["warn", { "allow": ["warn", "error"] }]
  },
  "env": {
    "node": true,
    "es2022": true
  },
  "ignorePatterns": ["node_modules", "dist", "build", "target", "*.js"]
}
EOF

    print_success "ESLint configuration created"
}

# Generate Jest configuration
generate_jest_config() {
    local monorepo_path=$1

    print_info "Generating Jest configuration..."

    cat > "$monorepo_path/jest.config.js" << 'EOF'
module.exports = {
  projects: ['<rootDir>/teams/**/jest.config.js'],
  coverageDirectory: '<rootDir>/coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  collectCoverageFrom: [
    'teams/**/src/**/*.{ts,tsx}',
    'shared/**/src/**/*.{ts,tsx}',
    '!**/*.d.ts',
    '!**/node_modules/**',
    '!**/dist/**'
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    }
  }
};
EOF

    print_success "Jest configuration created"
}

# Generate Makefile
generate_makefile() {
    local monorepo_path=$1

    print_info "Generating Makefile..."

    cat > "$monorepo_path/Makefile" << 'EOF'
.PHONY: help install build test lint clean affected dev

help: ## Show this help message
	@echo "Enterprise Monorepo - Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install all dependencies
	@echo "Installing dependencies..."
	npm install
	@echo "Installing Java dependencies..."
	cd teams/user-services && mvn install -DskipTests || true
	cd teams/business-services && mvn install -DskipTests || true

build: ## Build all services
	@echo "Building TypeScript services..."
	npm run build
	@echo "Building Java services..."
	cd teams/user-services && mvn clean package -DskipTests || true
	cd teams/business-services && mvn clean package -DskipTests || true

test: ## Run all tests
	@echo "Running TypeScript tests..."
	npm test
	@echo "Running Java tests..."
	cd teams/user-services && mvn test || true
	cd teams/business-services && mvn test || true

lint: ## Lint all code
	npm run lint

affected: ## Build and test only affected services
	@echo "Building affected services..."
	npm run affected:build
	@echo "Testing affected services..."
	npm run affected:test

clean: ## Clean build artifacts
	@echo "Cleaning TypeScript builds..."
	find . -name "dist" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "Cleaning Java builds..."
	find . -name "target" -type d -exec rm -rf {} + 2>/dev/null || true

dev: ## Start local development environment
	docker-compose up

stop: ## Stop local development environment
	docker-compose down

logs: ## Show logs from development environment
	docker-compose logs -f
EOF

    chmod +x "$monorepo_path/Makefile"
    print_success "Makefile created"
}

# Generate docker-compose.yml
generate_docker_compose() {
    local monorepo_path=$1

    print_info "Generating docker-compose.yml..."

    cat > "$monorepo_path/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: monorepo-postgres
    environment:
      POSTGRES_USER: devuser
      POSTGRES_PASSWORD: devpass
      POSTGRES_DB: monorepo_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U devuser"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: monorepo-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

volumes:
  postgres_data:
  redis_data:

networks:
  default:
    name: monorepo-network
EOF

    print_success "docker-compose.yml created"
}

# Generate monorepo workspace (root configs)
generate_monorepo_workspace() {
    local monorepo_path=$1

    print_header "Setting up monorepo workspace configuration"

    generate_nx_config "$monorepo_path"
    generate_root_package_json "$monorepo_path"
    generate_tsconfig_base "$monorepo_path"
    generate_eslint_config "$monorepo_path"
    generate_jest_config "$monorepo_path"
    generate_makefile "$monorepo_path"
    generate_docker_compose "$monorepo_path"

    print_success "Monorepo workspace configuration complete"
}

# Generate Maven parent POM
generate_maven_parent_pom() {
    local monorepo_path=$1
    local team=$2

    print_info "Generating Maven parent POM for $team..."

    local team_path="$monorepo_path/teams/$team"
    mkdir -p "$team_path"

    cat > "$team_path/pom.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.omnibasepoc</groupId>
    <artifactId>$team-parent</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <name>$team Parent POM</name>
    <description>Parent POM for $team services</description>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
        <relativePath/>
    </parent>

    <properties>
        <java.version>17</java.version>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <spring-cloud.version>2023.0.0</spring-cloud.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>\${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-maven-plugin</artifactId>
                    <configuration>
                        <excludes>
                            <exclude>
                                <groupId>org.projectlombok</groupId>
                                <artifactId>lombok</artifactId>
                            </exclude>
                        </excludes>
                    </configuration>
                </plugin>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-surefire-plugin</artifactId>
                    <version>3.0.0</version>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>

</project>
EOF

    print_success "Maven parent POM created for $team"
}

# Generate shared TypeScript common utilities library
generate_shared_typescript_common() {
    local monorepo_path=$1
    local lib_path="$monorepo_path/shared/typescript/common-utils"

    print_info "Generating shared TypeScript common utilities..."
    mkdir -p "$lib_path/src"

    # Create package.json
    cat > "$lib_path/package.json" <<'LIBEOF'
{
  "name": "@monorepo/common-utils",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "test": "jest"
  }
}
LIBEOF

    # Create simple utilities
    cat > "$lib_path/src/index.ts" <<'LIBEOF'
export const logger = {
  info: (msg: string) => console.log(`[INFO] ${msg}`),
  error: (msg: string) => console.error(`[ERROR] ${msg}`)
};

export class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}
LIBEOF

    print_success "Shared TypeScript common utils created"
}

# Generate shared TypeScript domain models library
generate_shared_typescript_models() {
    local monorepo_path=$1
    local lib_path="$monorepo_path/shared/typescript/domain-models"

    print_info "Generating shared TypeScript domain models..."
    mkdir -p "$lib_path/src"

    cat > "$lib_path/package.json" <<'LIBEOF'
{
  "name": "@monorepo/domain-models",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts"
}
LIBEOF

    cat > "$lib_path/src/index.ts" <<'LIBEOF'
export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
}

export interface Order {
  id: string;
  userId: string;
  status: string;
  total: number;
}
LIBEOF

    print_success "Shared TypeScript domain models created"
}

# Generate shared Java common library
generate_shared_java_common() {
    local monorepo_path=$1
    local lib_path="$monorepo_path/shared/java/common-lib"

    print_info "Generating shared Java common library..."
    mkdir -p "$lib_path/src/main/java/com/omnibasepoc/common"

    cat > "$lib_path/pom.xml" <<'LIBEOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.omnibasepoc</groupId>
    <artifactId>common-lib</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <properties>
        <java.version>17</java.version>
    </properties>
</project>
LIBEOF

    cat > "$lib_path/src/main/java/com/omnibasepoc/common/BaseEntity.java" <<'LIBEOF'
package com.omnibasepoc.common;

public abstract class BaseEntity {
    private String id;
    private java.time.LocalDateTime createdAt;
    private java.time.LocalDateTime updatedAt;
}
LIBEOF

    print_success "Shared Java common library created"
}

# Generate all shared libraries
generate_shared_libraries() {
    local monorepo_path=$1
    print_header "Generating shared libraries"
    generate_shared_typescript_common "$monorepo_path"
    generate_shared_typescript_models "$monorepo_path"
    generate_shared_java_common "$monorepo_path"
    print_success "All shared libraries generated"
}
