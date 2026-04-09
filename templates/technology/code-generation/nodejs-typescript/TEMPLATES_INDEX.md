# Node.js/TypeScript Templates Index

Complete list of all available templates with descriptions and placeholders.

## Core Application Templates

### 1. **index.ts.template**
- **Purpose**: Application entry point
- **Features**: Startup logic, configuration validation, error handling
- **Placeholders**: `{{APP_NAME}}`

### 2. **app.ts.template**
- **Purpose**: Express application setup and configuration
- **Features**: Middleware registration, route setup, health checks, graceful shutdown
- **Placeholders**: `{{APP_NAME}}`, `{{ROUTE_NAME}}`, `{{MIDDLEWARE_NAME}}`

### 3. **config.ts.template**
- **Purpose**: Centralized configuration management
- **Features**: Environment variables, validation, type safety
- **Placeholders**: None

## API Layer Templates

### 4. **route.ts.template**
- **Purpose**: Express routes with CRUD endpoints
- **Features**: All HTTP methods, validation, pagination
- **Placeholders**: `{{ROUTE_NAME}}`, `{{SERVICE_NAME}}`
- **Endpoints**:
  - GET / (list with pagination)
  - GET /:id (get by ID)
  - POST / (create)
  - PUT /:id (update)
  - PATCH /:id (partial update)
  - DELETE /:id (delete)

### 5. **controller.ts.template**
- **Purpose**: Request handlers and response formatting
- **Features**: CRUD operations, bulk operations, error handling
- **Placeholders**: `{{CONTROLLER_NAME}}`, `{{SERVICE_NAME}}`, `{{MODEL_NAME}}`, `{{ROUTE_NAME}}`
- **Methods**:
  - getAll
  - getById
  - create
  - update
  - patch
  - delete
  - getAggregated
  - bulkCreate
  - bulkUpdate
  - bulkDelete
  - healthCheck

## Business Logic Templates

### 6. **service.ts.template**
- **Purpose**: Business logic and external service integration
- **Features**: Axios client, retry logic, caching, BFF patterns
- **Placeholders**: `{{SERVICE_NAME}}`, `{{MODEL_NAME}}`, `{{BACKEND_URL}}`
- **Methods**:
  - getAll (with pagination)
  - getById
  - create
  - update
  - patch
  - delete
  - aggregateData
  - Cache management

## Data Models Templates

### 7. **model.ts.template**
- **Purpose**: TypeScript interfaces and types
- **Features**: Base entities, DTOs, enums, type guards, utility types
- **Placeholders**: `{{MODEL_NAME}}`, `{{FIELDS}}`
- **Exports**:
  - Main interface
  - Create/Update/Patch DTOs
  - Query parameters
  - Response wrappers
  - Enums
  - Type guards
  - Utility types
  - Cache key builders

## Middleware Templates

### 8. **middleware.ts.template**
- **Purpose**: Express middleware collection
- **Features**: Authentication, authorization, logging, error handling
- **Placeholders**: `{{MIDDLEWARE_NAME}}`
- **Middleware**:
  - authenticate (JWT)
  - authorize (RBAC)
  - requestLogger
  - errorHandler
  - notFound
  - rateLimit
  - validateRequest
  - cors
  - timeout
  - cacheControl

## Utility Templates

### 9. **logger.ts.template**
- **Purpose**: Structured logging with Winston
- **Features**: Multiple transports, log levels, performance logging
- **Placeholders**: `{{SERVICE_NAME}}`

### 10. **cache.ts.template**
- **Purpose**: Caching abstraction (Redis + in-memory)
- **Features**: Get/set/delete, pattern invalidation, decorators
- **Placeholders**: None
- **Decorators**:
  - @Cacheable
  - @InvalidateCache

### 11. **ApiError.ts.template**
- **Purpose**: Custom error classes
- **Features**: HTTP status codes, error types, serialization
- **Placeholders**: None
- **Classes**:
  - ApiError (base)
  - ValidationError
  - DatabaseError
  - ExternalServiceError
  - AuthenticationError
  - AuthorizationError
  - RateLimitError

## Testing Templates

### 12. **service.test.ts.template**
- **Purpose**: Unit tests for service layer
- **Features**: Mocked axios, retry testing, error handling tests
- **Placeholders**: `{{TEST_NAME}}`, `{{SERVICE_NAME}}`, `{{MODEL_NAME}}`
- **Test Suites**:
  - getAll
  - getById
  - create
  - update
  - patch
  - delete
  - aggregateData
  - Retry logic
  - Error transformation

### 13. **route.test.ts.template**
- **Purpose**: Integration tests for API routes
- **Features**: Supertest, endpoint testing, validation testing
- **Placeholders**: `{{TEST_NAME}}`, `{{ROUTE_NAME}}`, `{{SERVICE_NAME}}`, `{{MODEL_NAME}}`, `{{MIDDLEWARE_NAME}}`
- **Test Suites**:
  - All HTTP methods
  - Validation
  - Error handling
  - Content-Type validation
  - Query parameters

## Configuration Templates

### 14. **package.json.template**
- **Purpose**: NPM package configuration
- **Features**: Dependencies, scripts, Jest config, lint-staged
- **Placeholders**: `{{SERVICE_NAME}}`
- **Scripts**:
  - start, dev, build
  - test, test:coverage
  - lint, format
  - docker:build, docker:run

### 15. **tsconfig.json.template**
- **Purpose**: TypeScript compiler configuration
- **Features**: Strict mode, path mappings, ES2022 target
- **Placeholders**: None

### 16. **.env.template**
- **Purpose**: Environment variables template
- **Features**: All configuration options with comments
- **Placeholders**: `{{SERVICE_NAME}}`
- **Sections**:
  - Application
  - JWT
  - CORS
  - Rate limiting
  - Logging
  - Redis
  - Cache
  - Backend services

### 17. **.eslintrc.json.template**
- **Purpose**: ESLint configuration
- **Features**: TypeScript rules, import ordering, Prettier integration
- **Placeholders**: None

### 18. **.prettierrc.json.template**
- **Purpose**: Prettier code formatting
- **Features**: Consistent code style
- **Placeholders**: None

## Docker Templates

### 19. **Dockerfile.template**
- **Purpose**: Multi-stage Docker build
- **Features**: Build stage, production stage, health checks, non-root user
- **Placeholders**: None

### 20. **.dockerignore.template**
- **Purpose**: Files to exclude from Docker builds
- **Placeholders**: None

### 21. **.gitignore.template**
- **Purpose**: Files to exclude from version control
- **Placeholders**: None

## Documentation Templates

### 22. **README.md**
- **Purpose**: Complete documentation
- **Features**: Usage guide, best practices, deployment instructions
- **Placeholders**: None (documentation file)

### 23. **USAGE_EXAMPLE.md**
- **Purpose**: Step-by-step usage guide
- **Features**: Complete example of building a User service
- **Placeholders**: None (documentation file)

## Placeholder Reference

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{SERVICE_NAME}}` | Service class name | User, Product, Order |
| `{{MODEL_NAME}}` | Model/interface name | User, Product, Order |
| `{{ROUTE_NAME}}` | Route path name (plural, lowercase) | users, products, orders |
| `{{CONTROLLER_NAME}}` | Controller class name | UserController, ProductController |
| `{{MIDDLEWARE_NAME}}` | Middleware file name | auth, validation |
| `{{APP_NAME}}` | Application name | user-service, product-api |
| `{{BACKEND_URL}}` | Environment variable for backend URL | USER_API_URL, PRODUCT_API_URL |
| `{{TEST_NAME}}` | Test suite name | UserService, ProductController |
| `{{FIELDS}}` | Model field definitions | name: string; email: string; |

## Usage Pattern

1. Choose the templates you need
2. Replace placeholders with your values
3. Organize files in proper directory structure
4. Install dependencies
5. Configure environment variables
6. Run tests
7. Start development

## Quick Start Commands

```bash
# Create project structure
mkdir -p src/{config,controllers,errors,middleware,models,routes,services,utils,__tests__}

# Install dependencies
npm install

# Copy and configure environment
cp .env.template .env

# Run in development
npm run dev

# Run tests
npm test

# Build for production
npm run build
npm start

# Docker build
docker build -t service-name .
docker run -p 3000:3000 service-name
```

## Template Categories

### Essential (Minimum Viable Service)
- index.ts.template
- app.ts.template
- config.ts.template
- route.ts.template
- service.ts.template
- model.ts.template
- middleware.ts.template
- logger.ts.template
- ApiError.ts.template
- package.json.template
- tsconfig.json.template
- .env.template

### Recommended (Production Ready)
Add all Essential templates plus:
- controller.ts.template
- cache.ts.template
- service.test.ts.template
- route.test.ts.template
- Dockerfile.template
- .eslintrc.json.template
- .prettierrc.json.template

### Complete (Enterprise Grade)
All templates including:
- Documentation templates
- Docker templates
- Git configuration
- CI/CD ready

## Template Compatibility

All templates are designed to work together seamlessly:
- Consistent naming conventions
- Type-safe interfaces
- Shared utilities
- Unified error handling
- Integrated logging
- Compatible testing patterns

## Version Information

- Node.js: >= 18.0.0
- TypeScript: ^5.4.5
- Express: ^4.19.2
- Jest: ^29.7.0

## Support

For issues or questions:
1. Check README.md for general usage
2. Review USAGE_EXAMPLE.md for practical examples
3. Refer to individual template comments for details
