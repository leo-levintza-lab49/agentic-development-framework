# Node.js/TypeScript Service Templates

Comprehensive code generation templates for Node.js/TypeScript services with Express and BFF (Backend for Frontend) patterns.

## Overview

This collection provides production-ready templates for building scalable Node.js/TypeScript services with:

- **Express.js** - Web framework
- **TypeScript** - Type safety and modern JavaScript features
- **Async/Await** - Modern asynchronous patterns
- **Error Handling** - Centralized error management
- **Validation** - Input validation with express-validator
- **Authentication** - JWT-based authentication
- **Caching** - Redis and in-memory caching
- **Logging** - Structured logging with Winston
- **Testing** - Jest for unit and integration tests
- **BFF Patterns** - Data aggregation and caching

## Templates

### 1. Route Template (`route.ts.template`)

Express router with CRUD endpoints including:
- GET all (with pagination)
- GET by ID
- POST (create)
- PUT (update)
- PATCH (partial update)
- DELETE
- Input validation with express-validator
- Async/await error handling

**Placeholders:**
- `{{ROUTE_NAME}}` - Route name (e.g., "users", "products")
- `{{SERVICE_NAME}}` - Service class name (e.g., "User", "Product")

### 2. Service Template (`service.ts.template`)

Service class with business logic including:
- Axios client with retry logic
- Request/response interceptors
- Error handling and transformation
- Caching support (Redis/in-memory)
- Data aggregation (BFF pattern)
- Pagination support

**Placeholders:**
- `{{SERVICE_NAME}}` - Service name
- `{{MODEL_NAME}}` - Model/interface name
- `{{BACKEND_URL}}` - Backend service URL environment variable

### 3. Middleware Template (`middleware.ts.template`)

Comprehensive middleware collection:
- Authentication (JWT validation)
- Authorization (role-based access control)
- Request logging
- Error handling
- Rate limiting
- CORS handling
- Request timeout
- Cache control

**Placeholders:**
- `{{MIDDLEWARE_NAME}}` - Middleware file name

### 4. Model Template (`model.ts.template`)

TypeScript interfaces and types:
- Base entity interface
- Main model interface
- DTOs (Create, Update, Patch)
- Query parameters
- Response wrappers
- Type guards
- Utility types
- Cache key builders

**Placeholders:**
- `{{MODEL_NAME}}` - Model name
- `{{FIELDS}}` - Model fields definition

### 5. Controller Template (`controller.ts.template`)

Request handlers with:
- CRUD operations
- Bulk operations (create, update, delete)
- Data aggregation endpoint
- Health check
- Request/response formatting
- Error handling

**Placeholders:**
- `{{CONTROLLER_NAME}}` - Controller class name
- `{{SERVICE_NAME}}` - Service name
- `{{MODEL_NAME}}` - Model name
- `{{ROUTE_NAME}}` - Route name

### 6. Service Test Template (`service.test.ts.template`)

Jest unit tests for service layer:
- Mock axios with axios-mock-adapter
- Test all service methods
- Test retry logic
- Test error handling
- Test cache management
- 80%+ code coverage

**Placeholders:**
- `{{TEST_NAME}}` - Test suite name
- `{{SERVICE_NAME}}` - Service name
- `{{MODEL_NAME}}` - Model name

### 7. Route Test Template (`route.test.ts.template`)

Jest integration tests for routes:
- Supertest for API testing
- Test all endpoints (GET, POST, PUT, PATCH, DELETE)
- Test validation
- Test error scenarios
- Mock service layer

**Placeholders:**
- `{{TEST_NAME}}` - Test suite name
- `{{ROUTE_NAME}}` - Route name
- `{{SERVICE_NAME}}` - Service name
- `{{MODEL_NAME}}` - Model name
- `{{MIDDLEWARE_NAME}}` - Middleware name

### 8. Package.json Template (`package.json.template`)

Complete package.json with:
- Dependencies (express, axios, joi, jest, winston, redis)
- DevDependencies (typescript, ts-node, eslint, prettier)
- Scripts (build, dev, test, lint, format)
- Jest configuration
- Lint-staged configuration

**Placeholders:**
- `{{SERVICE_NAME}}` - Service name

### 9. TypeScript Config Template (`tsconfig.json.template`)

Strict TypeScript configuration:
- ES2022 target
- Strict mode enabled
- Path mappings for clean imports
- Source maps for debugging
- Declaration files

### 10. App Template (`app.ts.template`)

Express application setup:
- Middleware registration
- Security headers (helmet)
- CORS configuration
- Compression
- Rate limiting
- Health check endpoints
- Route registration
- Error handling
- Graceful shutdown

**Placeholders:**
- `{{APP_NAME}}` - Application name
- `{{ROUTE_NAME}}` - Route name
- `{{MIDDLEWARE_NAME}}` - Middleware name

### 11. Config Template (`config.ts.template`)

Centralized configuration management:
- Environment variable loading
- Type-safe configuration
- Validation
- Default values
- Configuration summary

### 12. Logger Template (`logger.ts.template`)

Winston logger configuration:
- Structured logging
- Multiple transports (console, file)
- Log levels
- Performance logging
- HTTP request logging

### 13. Cache Template (`cache.ts.template`)

Caching abstraction layer:
- Redis implementation
- In-memory fallback
- Cache decorators
- Pattern-based invalidation
- TTL support

### 14. API Error Template (`ApiError.ts.template`)

Custom error classes:
- Base ApiError class
- Specialized error types (ValidationError, AuthenticationError, etc.)
- Static factory methods
- Error serialization

### 15. Environment Template (`.env.template`)

Environment variable template with:
- Application settings
- JWT configuration
- CORS settings
- Rate limiting
- Redis configuration
- Backend service URLs
- Logging configuration

### 16. ESLint Config (`.eslintrc.json.template`)

ESLint configuration with:
- TypeScript support
- Import ordering
- Strict rules
- Prettier integration

### 17. Prettier Config (`.prettierrc.json.template`)

Code formatting configuration

### 18. Dockerfile Template (`Dockerfile.template`)

Multi-stage Docker build:
- Build stage
- Production stage
- Security best practices
- Health checks

### 19. Docker Ignore (`.dockerignore.template`)

Files to exclude from Docker builds

### 20. Git Ignore (`.gitignore.template`)

Files to exclude from version control

## Usage

### 1. Replace Placeholders

Replace the following placeholders in the templates:

```bash
# Example for a "User" service
{{SERVICE_NAME}} → User
{{MODEL_NAME}} → User
{{ROUTE_NAME}} → users
{{CONTROLLER_NAME}} → UserController
{{MIDDLEWARE_NAME}} → auth
{{APP_NAME}} → user-service
{{BACKEND_URL}} → BACKEND_API_URL
{{TEST_NAME}} → UserService
{{FIELDS}} → name: string; email: string; role: string;
```

### 2. Project Structure

Organize files in this structure:

```
src/
├── config/
│   └── index.ts           (from config.ts.template)
├── controllers/
│   └── user.controller.ts (from controller.ts.template)
├── errors/
│   └── ApiError.ts        (from ApiError.ts.template)
├── middleware/
│   └── auth.middleware.ts (from middleware.ts.template)
├── models/
│   └── user.model.ts      (from model.ts.template)
├── routes/
│   └── user.routes.ts     (from route.ts.template)
├── services/
│   └── user.service.ts    (from service.ts.template)
├── utils/
│   ├── cache.ts           (from cache.ts.template)
│   └── logger.ts          (from logger.ts.template)
├── __tests__/
│   ├── user.service.test.ts (from service.test.ts.template)
│   └── user.route.test.ts   (from route.test.ts.template)
├── app.ts                 (from app.ts.template)
└── index.ts               (entry point)
```

### 3. Install Dependencies

```bash
npm install
```

### 4. Configure Environment

```bash
cp .env.template .env
# Edit .env with your configuration
```

### 5. Run Development Server

```bash
npm run dev
```

### 6. Run Tests

```bash
npm test
npm run test:coverage
```

### 7. Build for Production

```bash
npm run build
npm start
```

## Features

### Authentication & Authorization
- JWT token validation
- Role-based access control
- Request user context

### Caching
- Redis support
- In-memory fallback
- Automatic cache invalidation
- Decorator-based caching

### Error Handling
- Centralized error middleware
- Custom error classes
- Operational vs programming errors
- Detailed error responses (dev mode)

### Logging
- Structured JSON logging
- Request/response logging
- Performance logging
- Multiple transports

### Validation
- Input validation with express-validator
- Type-safe request/response
- Custom validation rules

### Testing
- Unit tests (Jest)
- Integration tests (Supertest)
- Mocked dependencies
- 80%+ coverage threshold

### BFF Patterns
- Data aggregation from multiple services
- Response transformation
- Caching strategies
- Parallel requests

### Security
- Helmet for security headers
- CORS configuration
- Rate limiting
- Request timeout
- Input sanitization

## Best Practices

1. **Async/Await** - Use async/await instead of callbacks
2. **Error Handling** - Always use try-catch with async functions
3. **Validation** - Validate all inputs at route level
4. **Logging** - Log all important operations and errors
5. **Testing** - Write tests for all business logic
6. **Types** - Use TypeScript strict mode
7. **Security** - Follow security best practices
8. **Performance** - Use caching for expensive operations
9. **Documentation** - Document all public APIs
10. **Code Quality** - Use ESLint and Prettier

## Environment Variables

See `.env.template` for all available environment variables and their descriptions.

## Testing Strategy

- **Unit Tests**: Test individual functions and methods
- **Integration Tests**: Test API endpoints end-to-end
- **Mock External Dependencies**: Use mocks for databases and external services
- **Coverage**: Maintain 80%+ code coverage

## Deployment

### Docker

```bash
docker build -t service-name .
docker run -p 3000:3000 service-name
```

### Kubernetes

Use the provided Dockerfile with your Kubernetes manifests.

### Cloud Platforms

Compatible with AWS ECS, Google Cloud Run, Azure Container Instances, etc.

## Troubleshooting

### Common Issues

1. **Port already in use**: Change PORT in .env
2. **Redis connection failed**: Check REDIS_HOST and REDIS_PORT
3. **JWT errors**: Ensure JWT_SECRET is set
4. **TypeScript errors**: Run `npm run type-check`

## License

MIT

## Contributing

Contributions welcome! Please follow the coding standards and include tests.
