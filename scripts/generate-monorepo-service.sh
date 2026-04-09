#!/bin/bash
# Generate a service in the monorepo with sample implementation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

MONOREPO_PATH="/Users/leo.levintza/wrk/omnybase/enterprise-monorepo"

# Usage function
usage() {
    echo "Usage: $0 <team> <service-name> <type>"
    echo ""
    echo "Teams:"
    echo "  data-platform, user-services, business-services,"
    echo "  bff, web-frontend, mobile, platform"
    echo ""
    echo "Types:"
    echo "  java-service, node-service, react-app, database, terraform, mobile-ios, mobile-android, config"
    echo ""
    echo "Example:"
    echo "  $0 user-services user-service java-service"
    exit 1
}

# Validate arguments
if [ $# -ne 3 ]; then
    usage
fi

TEAM=$1
SERVICE=$2
TYPE=$3

SERVICE_PATH="$MONOREPO_PATH/teams/$TEAM/$SERVICE"

# Generate Java service with sample implementation
generate_java_service_sample() {
    local service_path=$1
    local service_name=$2

    print_info "Generating Java service with sample implementation..."

    # Create directory structure
    mkdir -p "$service_path/src/main/java/com/omnibasepoc/$service_name/controller"
    mkdir -p "$service_path/src/main/java/com/omnibasepoc/$service_name/service"
    mkdir -p "$service_path/src/main/java/com/omnibasepoc/$service_name/model"
    mkdir -p "$service_path/src/main/java/com/omnibasepoc/$service_name/repository"
    mkdir -p "$service_path/src/main/resources"
    mkdir -p "$service_path/src/test/java/com/omnibasepoc/$service_name"

    # pom.xml
    cat > "$service_path/pom.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.omnibasepoc</groupId>
        <artifactId>$TEAM-parent</artifactId>
        <version>1.0.0-SNAPSHOT</version>
        <relativePath>../pom.xml</relativePath>
    </parent>

    <artifactId>$service_name</artifactId>
    <name>$SERVICE</name>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

    # Application.java
    local class_prefix=$(echo "$service_name" | sed -r 's/(^|-)([a-z])/\U\2/g')
    cat > "$service_path/src/main/java/com/omnibasepoc/$service_name/Application.java" <<EOF
package com.omnibasepoc.$service_name;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
EOF

    # Entity Model
    cat > "$service_path/src/main/java/com/omnibasepoc/$service_name/model/${class_prefix}.java" <<EOF
package com.omnibasepoc.$service_name.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "${service_name}s")
public class $class_prefix {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String name;
    private String description;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
EOF

    # Repository
    cat > "$service_path/src/main/java/com/omnibasepoc/$service_name/repository/${class_prefix}Repository.java" <<EOF
package com.omnibasepoc.$service_name.repository;

import com.omnibasepoc.$service_name.model.$class_prefix;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ${class_prefix}Repository extends JpaRepository<$class_prefix, String> {
}
EOF

    # Service Interface
    cat > "$service_path/src/main/java/com/omnibasepoc/$service_name/service/${class_prefix}Service.java" <<EOF
package com.omnibasepoc.$service_name.service;

import com.omnibasepoc.$service_name.model.$class_prefix;
import java.util.List;
import java.util.Optional;

public interface ${class_prefix}Service {
    List<$class_prefix> findAll();
    Optional<$class_prefix> findById(String id);
    $class_prefix save($class_prefix entity);
    void deleteById(String id);
}
EOF

    # Service Implementation
    cat > "$service_path/src/main/java/com/omnibasepoc/$service_name/service/${class_prefix}ServiceImpl.java" <<EOF
package com.omnibasepoc.$service_name.service;

import com.omnibasepoc.$service_name.model.$class_prefix;
import com.omnibasepoc.$service_name.repository.${class_prefix}Repository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ${class_prefix}ServiceImpl implements ${class_prefix}Service {

    private final ${class_prefix}Repository repository;

    public ${class_prefix}ServiceImpl(${class_prefix}Repository repository) {
        this.repository = repository;
    }

    @Override
    public List<$class_prefix> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<$class_prefix> findById(String id) {
        return repository.findById(id);
    }

    @Override
    public $class_prefix save($class_prefix entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(String id) {
        repository.deleteById(id);
    }
}
EOF

    # Controller
    cat > "$service_path/src/main/java/com/omnibasepoc/$service_name/controller/${class_prefix}Controller.java" <<EOF
package com.omnibasepoc.$service_name.controller;

import com.omnibasepoc.$service_name.model.$class_prefix;
import com.omnibasepoc.$service_name.service.${class_prefix}Service;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/${service_name}s")
public class ${class_prefix}Controller {

    private final ${class_prefix}Service service;

    public ${class_prefix}Controller(${class_prefix}Service service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<$class_prefix>> getAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<$class_prefix> getById(@PathVariable String id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<$class_prefix> create(@RequestBody $class_prefix entity) {
        return ResponseEntity.ok(service.save(entity));
    }

    @PutMapping("/{id}")
    public ResponseEntity<$class_prefix> update(@PathVariable String id, @RequestBody $class_prefix entity) {
        entity.setId(id);
        return ResponseEntity.ok(service.save(entity));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        service.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
EOF

    # application.yml
    cat > "$service_path/src/main/resources/application.yml" <<EOF
spring:
  application:
    name: $service_name
  datasource:
    url: jdbc:postgresql://localhost:5432/monorepo_dev
    username: devuser
    password: devpass
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true

server:
  port: 8080
EOF

    # Test
    cat > "$service_path/src/test/java/com/omnibasepoc/$service_name/ApplicationTests.java" <<EOF
package com.omnibasepoc.$service_name;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class ApplicationTests {
    @Test
    void contextLoads() {
    }
}
EOF

    # Dockerfile
    cat > "$service_path/Dockerfile" <<EOF
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

    # README
    cat > "$service_path/README.md" <<EOF
# $SERVICE

## Description
Sample $service_name service with CRUD operations.

## Build
\`\`\`bash
mvn clean package
\`\`\`

## Run
\`\`\`bash
mvn spring-boot:run
\`\`\`

## API Endpoints
- GET    /api/v1/${service_name}s - Get all
- GET    /api/v1/${service_name}s/{id} - Get by ID
- POST   /api/v1/${service_name}s - Create
- PUT    /api/v1/${service_name}s/{id} - Update
- DELETE /api/v1/${service_name}s/{id} - Delete
EOF

    print_success "Java service with sample implementation generated"
}

# Generate Node service with sample implementation
generate_node_service_sample() {
    local service_path=$1
    local service_name=$2

    print_info "Generating Node service with sample implementation..."

    # Create directory structure
    mkdir -p "$service_path/src/routes"
    mkdir -p "$service_path/src/controllers"
    mkdir -p "$service_path/src/services"
    mkdir -p "$service_path/src/models"
    mkdir -p "$service_path/src/middleware"
    mkdir -p "$service_path/src/utils"
    mkdir -p "$service_path/tests/integration"
    mkdir -p "$service_path/tests/unit"

    # package.json
    cat > "$service_path/package.json" <<'EOF'
{
  "name": "@monorepo/SERVICE_NAME",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "lint": "eslint src --ext .ts"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/cors": "^2.8.13",
    "@types/node": "^20.4.2",
    "@types/jest": "^29.5.3",
    "typescript": "^5.1.6",
    "ts-node-dev": "^2.0.0",
    "jest": "^29.6.1",
    "ts-jest": "^29.1.1",
    "eslint": "^8.45.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0"
  }
}
EOF
    sed -i '' "s/SERVICE_NAME/$service_name/g" "$service_path/package.json"

    # tsconfig.json
    cat > "$service_path/tsconfig.json" <<'EOF'
{
  "extends": "../../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "module": "commonjs",
    "target": "ES2020",
    "lib": ["ES2020"],
    "esModuleInterop": true,
    "skipLibCheck": true,
    "strict": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
EOF

    # jest.config.js
    cat > "$service_path/jest.config.js" <<'EOF'
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/tests'],
  testMatch: ['**/*.test.ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
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

    # .env
    cat > "$service_path/.env" <<'EOF'
NODE_ENV=development
PORT=3000
EOF

    # src/index.ts
    cat > "$service_path/src/index.ts" <<'EOF'
import express, { Application } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import routes from './routes';
import { errorHandler } from './middleware/error.middleware';

dotenv.config();

const app: Application = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'SERVICE_NAME' });
});

// Routes
app.use('/api/v1', routes);

// Error handling
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`SERVICE_NAME running on port ${PORT}`);
});

export default app;
EOF
    sed -i '' "s/SERVICE_NAME/$service_name/g" "$service_path/src/index.ts"

    # src/routes/index.ts
    local entity_name=$(echo "$service_name" | sed 's/-service$//' | sed 's/-$//')
    local entity_name_cap=$(echo "$entity_name" | sed 's/^./\U&/')
    cat > "$service_path/src/routes/index.ts" <<EOF
import { Router } from 'express';
import ${entity_name}Routes from './${entity_name}.routes';

const router = Router();

router.use('/${entity_name}s', ${entity_name}Routes);

export default router;
EOF

    # src/routes/{entity}.routes.ts
    cat > "$service_path/src/routes/${entity_name}.routes.ts" <<EOF
import { Router } from 'express';
import { ${entity_name_cap}Controller } from '../controllers/${entity_name}.controller';

const router = Router();
const controller = new ${entity_name_cap}Controller();

router.get('/', controller.getAll);
router.get('/:id', controller.getById);
router.post('/', controller.create);
router.put('/:id', controller.update);
router.delete('/:id', controller.delete);

export default router;
EOF

    # src/controllers/{entity}.controller.ts
    cat > "$service_path/src/controllers/${entity_name}.controller.ts" <<EOF
import { Request, Response, NextFunction } from 'express';
import { ${entity_name_cap}Service } from '../services/${entity_name}.service';

export class ${entity_name_cap}Controller {
  private service = new ${entity_name_cap}Service();

  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const items = await this.service.findAll();
      res.json(items);
    } catch (error) {
      next(error);
    }
  };

  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const item = await this.service.findById(req.params.id);
      if (!item) {
        return res.status(404).json({ error: '${entity_name_cap} not found' });
      }
      res.json(item);
    } catch (error) {
      next(error);
    }
  };

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const item = await this.service.create(req.body);
      res.status(201).json(item);
    } catch (error) {
      next(error);
    }
  };

  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const item = await this.service.update(req.params.id, req.body);
      if (!item) {
        return res.status(404).json({ error: '${entity_name_cap} not found' });
      }
      res.json(item);
    } catch (error) {
      next(error);
    }
  };

  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      await this.service.delete(req.params.id);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  };
}
EOF

    # src/services/{entity}.service.ts
    cat > "$service_path/src/services/${entity_name}.service.ts" <<EOF
import { ${entity_name_cap} } from '../models/${entity_name}.model';

export class ${entity_name_cap}Service {
  private items: ${entity_name_cap}[] = [];

  async findAll(): Promise<${entity_name_cap}[]> {
    return this.items;
  }

  async findById(id: string): Promise<${entity_name_cap} | undefined> {
    return this.items.find(item => item.id === id);
  }

  async create(data: Omit<${entity_name_cap}, 'id'>): Promise<${entity_name_cap}> {
    const item: ${entity_name_cap} = {
      id: Date.now().toString(),
      ...data,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    this.items.push(item);
    return item;
  }

  async update(id: string, data: Partial<${entity_name_cap}>): Promise<${entity_name_cap} | undefined> {
    const index = this.items.findIndex(item => item.id === id);
    if (index === -1) return undefined;

    this.items[index] = {
      ...this.items[index],
      ...data,
      updatedAt: new Date(),
    };
    return this.items[index];
  }

  async delete(id: string): Promise<void> {
    this.items = this.items.filter(item => item.id !== id);
  }
}
EOF

    # src/models/{entity}.model.ts
    cat > "$service_path/src/models/${entity_name}.model.ts" <<EOF
export interface ${entity_name_cap} {
  id: string;
  name: string;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
}
EOF

    # src/middleware/error.middleware.ts
    cat > "$service_path/src/middleware/error.middleware.ts" <<'EOF'
import { Request, Response, NextFunction } from 'express';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
  });
};
EOF

    # tests/integration/{entity}.test.ts
    cat > "$service_path/tests/integration/${entity_name}.test.ts" <<EOF
import request from 'supertest';
import app from '../../src/index';

describe('${entity_name_cap} API', () => {
  it('should get all ${entity_name}s', async () => {
    const response = await request(app).get('/api/v1/${entity_name}s');
    expect(response.status).toBe(200);
    expect(Array.isArray(response.body)).toBe(true);
  });

  it('should create a ${entity_name}', async () => {
    const data = { name: 'Test', description: 'Test description' };
    const response = await request(app)
      .post('/api/v1/${entity_name}s')
      .send(data);
    expect(response.status).toBe(201);
    expect(response.body.name).toBe(data.name);
  });
});
EOF

    # tests/unit/services/${entity_name}.service.test.ts
    mkdir -p "$service_path/tests/unit/services"
    cat > "$service_path/tests/unit/services/${entity_name}.service.test.ts" <<EOF
import { ${entity_name_cap}Service } from '../../../src/services/${entity_name}.service';

describe('${entity_name_cap}Service', () => {
  let service: ${entity_name_cap}Service;

  beforeEach(() => {
    service = new ${entity_name_cap}Service();
  });

  it('should create a ${entity_name}', async () => {
    const data = { name: 'Test', description: 'Test description' };
    const result = await service.create(data);
    expect(result.name).toBe(data.name);
    expect(result.id).toBeDefined();
  });

  it('should find all ${entity_name}s', async () => {
    const result = await service.findAll();
    expect(Array.isArray(result)).toBe(true);
  });
});
EOF

    # Dockerfile
    cat > "$service_path/Dockerfile" <<'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
EOF

    # README.md
    cat > "$service_path/README.md" <<EOF
# $SERVICE

## Description
Sample $service_name service with CRUD operations.

## Tech Stack
- Node.js 18+
- TypeScript
- Express
- Jest

## Build
\`\`\`bash
npm install
npm run build
\`\`\`

## Run
\`\`\`bash
npm run dev
\`\`\`

## Test
\`\`\`bash
npm test
\`\`\`

## API Endpoints
- GET    /api/v1/${entity_name}s - Get all
- GET    /api/v1/${entity_name}s/:id - Get by ID
- POST   /api/v1/${entity_name}s - Create
- PUT    /api/v1/${entity_name}s/:id - Update
- DELETE /api/v1/${entity_name}s/:id - Delete
EOF

    print_success "Node service with sample implementation generated"
}

# Generate React app with sample implementation
generate_react_app_sample() {
    local service_path=$1
    local service_name=$2

    print_info "Generating React app with sample implementation..."

    # Create directory structure
    mkdir -p "$service_path/src/components/common"
    mkdir -p "$service_path/src/components/layout"
    mkdir -p "$service_path/src/services"
    mkdir -p "$service_path/src/hooks"
    mkdir -p "$service_path/src/types"
    mkdir -p "$service_path/src/utils"
    mkdir -p "$service_path/public"

    # package.json
    cat > "$service_path/package.json" <<'EOF'
{
  "name": "@monorepo/SERVICE_NAME",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "lint": "eslint . --ext ts,tsx"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.14.2"
  },
  "devDependencies": {
    "@types/react": "^18.2.15",
    "@types/react-dom": "^18.2.7",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@vitejs/plugin-react": "^4.0.3",
    "eslint": "^8.45.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.3",
    "typescript": "^5.0.2",
    "vite": "^4.4.5",
    "vitest": "^0.34.0"
  }
}
EOF
    sed -i '' "s/SERVICE_NAME/$service_name/g" "$service_path/package.json"

    # tsconfig.json
    cat > "$service_path/tsconfig.json" <<'EOF'
{
  "extends": "../../../tsconfig.base.json",
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

    # tsconfig.node.json
    cat > "$service_path/tsconfig.node.json" <<'EOF'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF

    # vite.config.ts
    cat > "$service_path/vite.config.ts" <<'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000
  }
})
EOF

    # public/vite.svg
    cat > "$service_path/public/vite.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 410 404" fill="none">
  <path fill="#646cff" d="M399.641 59.5246L215.643 388.545C211.844 395.338 202.084 395.378 198.228 388.618L10.5817 59.5563C6.38087 52.1896 12.6802 43.2665 21.0281 44.7586L205.223 77.6824C206.398 77.8924 207.601 77.8904 208.776 77.6763L389.119 44.8058C397.439 43.2894 403.768 52.1434 399.641 59.5246Z"/>
  <path fill="#41b883" d="M292.965 1.5744L156.801 28.2552C154.563 28.6937 152.906 30.5903 152.771 32.8664L144.395 174.33C144.198 177.662 147.258 180.248 150.51 179.498L188.42 170.749C191.967 169.931 195.172 173.055 194.443 176.622L183.18 231.775C182.422 235.487 185.907 238.661 189.532 237.56L212.947 230.446C216.577 229.344 220.065 232.527 219.297 236.242L171.4 467.341C170.609 471.196 175.507 473.858 178.323 471.051L397.633 251.846C400.087 249.397 398.577 245.196 395.146 244.935L361.893 241.769C358.196 241.491 355.937 237.585 357.458 234.251L397.633 141.846C399.354 138.061 396.138 134.056 391.998 134.807L356.103 141.254C351.966 142.005 348.749 138.001 350.469 134.216L397.633 31.5246C399.686 27.1806 395.653 22.5246 390.965 23.5744L292.965 1.5744Z"/>
</svg>
EOF

    # index.html
    cat > "$service_path/index.html" <<EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>$service_name</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

    # src/main.tsx
    cat > "$service_path/src/main.tsx" <<'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

    # src/App.tsx
    cat > "$service_path/src/App.tsx" <<'EOF'
import { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="App">
      <h1>SERVICE_NAME</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>Edit <code>src/App.tsx</code> and save to test HMR</p>
      </div>
    </div>
  )
}

export default App
EOF
    sed -i '' "s/SERVICE_NAME/$service_name/g" "$service_path/src/App.tsx"

    # src/App.css
    cat > "$service_path/src/App.css" <<'EOF'
.App {
  max-width: 1280px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}

.card {
  padding: 2em;
}

button {
  border-radius: 8px;
  border: 1px solid transparent;
  padding: 0.6em 1.2em;
  font-size: 1em;
  font-weight: 500;
  font-family: inherit;
  background-color: #1a1a1a;
  cursor: pointer;
  transition: border-color 0.25s;
}

button:hover {
  border-color: #646cff;
}

button:focus,
button:focus-visible {
  outline: 4px auto -webkit-focus-ring-color;
}
EOF

    # src/index.css
    cat > "$service_path/src/index.css" <<'EOF'
:root {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;
  color-scheme: light dark;
  color: rgba(255, 255, 255, 0.87);
  background-color: #242424;
  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  -webkit-text-size-adjust: 100%;
}

body {
  margin: 0;
  display: flex;
  place-items: center;
  min-width: 320px;
  min-height: 100vh;
}

#root {
  max-width: 1280px;
  margin: 0 auto;
  padding: 2rem;
  text-align: center;
}
EOF

    # src/vite-env.d.ts
    cat > "$service_path/src/vite-env.d.ts" <<'EOF'
/// <reference types="vite/client" />
EOF

    # src/components/common/Button.tsx
    cat > "$service_path/src/components/common/Button.tsx" <<'EOF'
import React from 'react';

interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  type?: 'button' | 'submit' | 'reset';
  disabled?: boolean;
}

export const Button: React.FC<ButtonProps> = ({
  children,
  onClick,
  type = 'button',
  disabled = false,
}) => {
  return (
    <button type={type} onClick={onClick} disabled={disabled}>
      {children}
    </button>
  );
};
EOF

    # .gitignore
    cat > "$service_path/.gitignore" <<'EOF'
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

node_modules
dist
dist-ssr
*.local

# Editor directories and files
.vscode/*
!.vscode/extensions.json
.idea
.DS_Store
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?
EOF

    # README.md
    cat > "$service_path/README.md" <<EOF
# $SERVICE

## Description
React application built with Vite and TypeScript.

## Tech Stack
- React 18
- TypeScript
- Vite
- Vitest

## Development
\`\`\`bash
npm install
npm run dev
\`\`\`

## Build
\`\`\`bash
npm run build
\`\`\`

## Test
\`\`\`bash
npm test
\`\`\`

## Preview Production Build
\`\`\`bash
npm run preview
\`\`\`
EOF

    print_success "React app with sample implementation generated"
}

# Generate database repository (schemas/migrations)
generate_database_repo() {
    local service_path=$1
    local service_name=$2

    print_info "Generating database repository..."

    mkdir -p "$service_path/schemas"
    mkdir -p "$service_path/migrations"
    mkdir -p "$service_path/seeds"

    # README.md
    cat > "$service_path/README.md" <<EOF
# $SERVICE

## Description
Database schemas and migrations for the monorepo.

## Structure
- \`schemas/\` - SQL schema definitions
- \`migrations/\` - Database migration scripts
- \`seeds/\` - Seed data for development

## Usage
Apply migrations using your preferred tool (Flyway, Liquibase, etc.)
EOF

    # Sample schema
    cat > "$service_path/schemas/users.sql" <<'EOF'
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
EOF

    # Sample migration
    cat > "$service_path/migrations/001_initial_schema.sql" <<'EOF'
-- Initial database schema
-- Run this migration first

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table created in schemas/users.sql
EOF

    print_success "Database repository generated"
}

# Generate Terraform infrastructure
generate_terraform_repo() {
    local service_path=$1
    local service_name=$2

    print_info "Generating Terraform infrastructure..."

    mkdir -p "$service_path/modules"
    mkdir -p "$service_path/environments/dev"
    mkdir -p "$service_path/environments/prod"

    # main.tf
    cat > "$service_path/main.tf" <<'EOF'
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
EOF

    # variables.tf
    cat > "$service_path/variables.tf" <<'EOF'
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "monorepo"
}
EOF

    # outputs.tf
    cat > "$service_path/outputs.tf" <<'EOF'
output "environment" {
  description = "Environment name"
  value       = var.environment
}
EOF

    # README.md
    cat > "$service_path/README.md" <<EOF
# $SERVICE

## Description
Terraform infrastructure as code.

## Structure
- \`modules/\` - Reusable Terraform modules
- \`environments/\` - Environment-specific configurations

## Usage
\`\`\`bash
terraform init
terraform plan
terraform apply
\`\`\`
EOF

    print_success "Terraform infrastructure generated"
}

# Generate config repository
generate_config_repo() {
    local service_path=$1
    local service_name=$2

    print_info "Generating config repository..."

    mkdir -p "$service_path/configs"
    mkdir -p "$service_path/dashboards"
    mkdir -p "$service_path/alerts"

    # README.md
    cat > "$service_path/README.md" <<EOF
# $SERVICE

## Description
Configuration files for monitoring and observability.

## Structure
- \`configs/\` - Service configurations
- \`dashboards/\` - Dashboard definitions
- \`alerts/\` - Alert rules
EOF

    # Sample config
    cat > "$service_path/configs/sample.yml" <<'EOF'
# Sample configuration file
service:
  name: example-service
  port: 8080
EOF

    print_success "Config repository generated"
}

# Generate mobile app (basic structure)
generate_mobile_app() {
    local service_path=$1
    local service_name=$2
    local mobile_type=$3

    print_info "Generating mobile app structure ($mobile_type)..."

    mkdir -p "$service_path/src"
    mkdir -p "$service_path/tests"

    case "$mobile_type" in
        ios)
            # iOS app structure
            cat > "$service_path/README.md" <<EOF
# $SERVICE

## Description
iOS application (Swift/SwiftUI)

## Requirements
- Xcode 15+
- iOS 15+

## Setup
\`\`\`bash
open $service_name.xcodeproj
\`\`\`
EOF
            ;;
        android)
            # Android app structure
            cat > "$service_path/README.md" <<EOF
# $SERVICE

## Description
Android application (Kotlin)

## Requirements
- Android Studio
- Kotlin 1.9+

## Setup
Open project in Android Studio
EOF
            ;;
        shared)
            # React Native shared
            cat > "$service_path/package.json" <<EOF
{
  "name": "@monorepo/$service_name",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "start": "react-native start",
    "test": "jest"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-native": "^0.72.0"
  }
}
EOF
            cat > "$service_path/README.md" <<EOF
# $SERVICE

## Description
Shared mobile code (React Native)

## Setup
\`\`\`bash
npm install
npm start
\`\`\`
EOF
            ;;
    esac

    print_success "Mobile app structure generated"
}

# Main execution
main() {
    print_header "Generating Service: $SERVICE"
    echo "Team: $TEAM"
    echo "Type: $TYPE"
    echo "Path: $SERVICE_PATH"
    echo ""

    if [ -d "$SERVICE_PATH" ]; then
        print_warning "Service already exists at $SERVICE_PATH"
        read -p "Overwrite? [y/N]: " response
        if [ "$response" != "y" ]; then
            print_info "Skipping..."
            exit 0
        fi
        rm -rf "$SERVICE_PATH"
    fi

    mkdir -p "$SERVICE_PATH"

    case "$TYPE" in
        java-service)
            generate_java_service_sample "$SERVICE_PATH" "$SERVICE"
            print_success "Service $SERVICE generated successfully!"
            echo ""
            echo "Next steps:"
            echo "1. cd $SERVICE_PATH"
            echo "2. mvn clean package"
            echo "3. mvn spring-boot:run"
            ;;
        node-service)
            generate_node_service_sample "$SERVICE_PATH" "$SERVICE"
            print_success "Service $SERVICE generated successfully!"
            echo ""
            echo "Next steps:"
            echo "1. cd $SERVICE_PATH"
            echo "2. npm install"
            echo "3. npm run dev"
            ;;
        react-app)
            generate_react_app_sample "$SERVICE_PATH" "$SERVICE"
            print_success "Service $SERVICE generated successfully!"
            echo ""
            echo "Next steps:"
            echo "1. cd $SERVICE_PATH"
            echo "2. npm install"
            echo "3. npm run dev"
            ;;
        database)
            generate_database_repo "$SERVICE_PATH" "$SERVICE"
            print_success "Database repository $SERVICE generated successfully!"
            ;;
        terraform)
            generate_terraform_repo "$SERVICE_PATH" "$SERVICE"
            print_success "Terraform infrastructure $SERVICE generated successfully!"
            ;;
        config)
            generate_config_repo "$SERVICE_PATH" "$SERVICE"
            print_success "Config repository $SERVICE generated successfully!"
            ;;
        mobile-ios)
            generate_mobile_app "$SERVICE_PATH" "$SERVICE" "ios"
            print_success "iOS app $SERVICE generated successfully!"
            ;;
        mobile-android)
            generate_mobile_app "$SERVICE_PATH" "$SERVICE" "android"
            print_success "Android app $SERVICE generated successfully!"
            ;;
        mobile-shared)
            generate_mobile_app "$SERVICE_PATH" "$SERVICE" "shared"
            print_success "Shared mobile code $SERVICE generated successfully!"
            ;;
        *)
            print_error "Type $TYPE not yet implemented"
            print_info "Supported types: java-service, node-service, react-app, database, terraform, config, mobile-ios, mobile-android, mobile-shared"
            exit 1
            ;;
    esac
}

main "$@"
