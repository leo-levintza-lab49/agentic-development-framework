# Backend-for-Frontend (BFF) Team Guide

## Team Mission

The BFF team owns the Backend-for-Frontend layer, providing optimized, client-specific APIs that sit between frontend applications and backend services. Our goal is to deliver fast, reliable, and maintainable API experiences tailored to web, mobile, and GraphQL clients.

## Architecture Overview

### BFF Pattern

The BFF pattern separates the concerns of frontend and backend, allowing each to evolve independently while providing optimized interfaces for different client types.

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Web App   │  │ Mobile App  │  │ GraphQL CLI │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │
       └────────────────┼────────────────┘
                        │
              ┌─────────▼─────────┐
              │   BFF Layer       │
              │ (Node.js/Express) │
              └─────────┬─────────┘
                        │
       ┌────────────────┼────────────────┐
       │                │                │
┌──────▼──────┐  ┌──────▼──────┐  ┌─────▼──────┐
│ User Service│  │Payment Svc  │  │Product Svc │
└─────────────┘  └─────────────┘  └────────────┘
```

### Core Responsibilities

1. **API Composition**: Aggregate data from multiple backend services
2. **Data Transformation**: Convert backend formats to client-optimized structures
3. **Client Optimization**: Reduce chattiness, minimize payload sizes
4. **Error Translation**: Transform backend errors to client-friendly messages
5. **Caching**: Implement response caching to reduce backend load
6. **Authentication**: Handle client authentication and token management
7. **Rate Limiting**: Protect backend services from abuse

## Technology Stack

### Core Technologies
- **Runtime**: Node.js 20.x LTS
- **Language**: TypeScript 5.x (strict mode)
- **Framework**: Express.js 4.x
- **GraphQL**: Apollo Server 4.x
- **Validation**: Zod for runtime type validation
- **Testing**: Jest + Supertest
- **API Documentation**: OpenAPI 3.1 / Swagger

### Infrastructure
- **Caching**: Redis 7.x
- **Service Communication**: REST + gRPC
- **Observability**: OpenTelemetry + Prometheus
- **Logging**: Winston + structured JSON logs
- **Tracing**: Jaeger

## Node.js/TypeScript Standards

### Project Structure

```
src/
├── routes/           # Route handlers (thin layer)
│   ├── web/         # Web-specific routes
│   ├── mobile/      # Mobile-specific routes
│   └── shared/      # Shared routes
├── services/        # Business logic and backend integration
│   ├── user/
│   ├── payment/
│   └── product/
├── middleware/      # Express middleware
│   ├── auth.ts
│   ├── validation.ts
│   ├── error.ts
│   └── logging.ts
├── graphql/         # GraphQL layer
│   ├── schema/
│   ├── resolvers/
│   └── dataloaders/
├── types/           # TypeScript type definitions
│   ├── client/      # Client-facing types
│   ├── backend/     # Backend service types
│   └── internal/    # Internal types
├── utils/           # Utility functions
├── config/          # Configuration
└── app.ts           # Express app setup
```

### TypeScript Configuration

Use strict TypeScript settings:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "target": "ES2022",
    "module": "commonjs",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "outDir": "./dist"
  }
}
```

### Code Style Guidelines

#### 1. Use Explicit Types

```typescript
// ✅ Good: Explicit types
function getUserProfile(userId: string): Promise<UserProfile> {
  return userService.getProfile(userId);
}

// ❌ Bad: Implicit types
function getUserProfile(userId) {
  return userService.getProfile(userId);
}
```

#### 2. Avoid `any`, Use `unknown`

```typescript
// ✅ Good: Use unknown for uncertain types
function handleResponse(response: unknown): Result {
  if (isValidResponse(response)) {
    return parseResponse(response);
  }
  throw new Error('Invalid response');
}

// ❌ Bad: Using any
function handleResponse(response: any): Result {
  return parseResponse(response);
}
```

#### 3. Use Type Guards

```typescript
// ✅ Good: Type guard for runtime validation
function isUserProfile(data: unknown): data is UserProfile {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'email' in data
  );
}

const result = await backend.getUser();
if (isUserProfile(result)) {
  console.log(result.email); // TypeScript knows the type
}
```

#### 4. Prefer Interfaces for Objects, Types for Unions

```typescript
// ✅ Good: Interface for object shapes
interface UserProfile {
  id: string;
  email: string;
  name: string;
}

// ✅ Good: Type for unions and complex types
type PaymentStatus = 'pending' | 'completed' | 'failed';
type Result<T> = { success: true; data: T } | { success: false; error: Error };
```

#### 5. Use Async/Await Over Promises

```typescript
// ✅ Good: Async/await for readability
async function getOrderDetails(orderId: string): Promise<OrderDetails> {
  const order = await orderService.getOrder(orderId);
  const user = await userService.getUser(order.userId);
  const payment = await paymentService.getPayment(order.paymentId);
  
  return {
    order,
    user,
    payment,
  };
}

// ❌ Bad: Promise chains
function getOrderDetails(orderId: string): Promise<OrderDetails> {
  return orderService.getOrder(orderId)
    .then(order => userService.getUser(order.userId)
      .then(user => paymentService.getPayment(order.paymentId)
        .then(payment => ({ order, user, payment }))
      )
    );
}
```

## BFF Pattern Guidelines

### 1. Keep Routes Thin

Route handlers should only handle HTTP concerns:

```typescript
// ✅ Good: Thin route handler
router.get('/users/:id', async (req, res, next) => {
  try {
    const userId = req.params.id;
    const profile = await userService.getUserProfile(userId);
    res.json(profile);
  } catch (error) {
    next(error);
  }
});

// ❌ Bad: Business logic in routes
router.get('/users/:id', async (req, res, next) => {
  try {
    const userId = req.params.id;
    const user = await backend.get(`/users/${userId}`);
    const orders = await backend.get(`/orders?userId=${userId}`);
    const formatted = {
      ...user,
      orderCount: orders.length,
      lastOrder: orders[0]?.date,
    };
    res.json(formatted);
  } catch (error) {
    next(error);
  }
});
```

### 2. Service Layer for Business Logic

Move composition and transformation to services:

```typescript
// services/user/userService.ts
export class UserService {
  async getUserProfile(userId: string): Promise<UserProfile> {
    // Fetch from multiple backends
    const [user, orders, preferences] = await Promise.all([
      this.backendClient.getUser(userId),
      this.orderService.getUserOrders(userId),
      this.preferenceService.getPreferences(userId),
    ]);

    // Transform to client format
    return this.transformToUserProfile(user, orders, preferences);
  }

  private transformToUserProfile(
    user: BackendUser,
    orders: Order[],
    preferences: Preferences
  ): UserProfile {
    return {
      id: user.id,
      email: user.email,
      fullName: `${user.firstName} ${user.lastName}`,
      orderCount: orders.length,
      lastOrderDate: orders[0]?.createdAt,
      preferences: {
        notifications: preferences.notificationsEnabled,
        theme: preferences.theme,
      },
    };
  }
}
```

### 3. Client-Specific Optimization

Create optimized endpoints for different clients:

```typescript
// routes/web/products.ts
router.get('/products', async (req, res) => {
  // Web clients get full details
  const products = await productService.getProductsForWeb({
    includeReviews: true,
    includeRelated: true,
    imageSize: 'large',
  });
  res.json(products);
});

// routes/mobile/products.ts
router.get('/products', async (req, res) => {
  // Mobile clients get minimal payload
  const products = await productService.getProductsForMobile({
    includeReviews: false,
    includeRelated: false,
    imageSize: 'thumbnail',
  });
  res.json(products);
});
```

### 4. Aggregate Backend Calls

Reduce client round-trips by aggregating:

```typescript
// ✅ Good: Single endpoint aggregates data
router.get('/checkout/summary', async (req, res) => {
  const { cartId } = req.query;
  
  const summary = await checkoutService.getCheckoutSummary(cartId, {
    includeCart: true,
    includeShipping: true,
    includeTax: true,
    includePaymentMethods: true,
  });
  
  res.json(summary);
});

// ❌ Bad: Client makes multiple requests
// GET /cart/:id
// GET /shipping/estimate
// GET /tax/calculate
// GET /payment/methods
```

### 5. Backend Error Translation

Transform backend errors to client-friendly format:

```typescript
export class ErrorHandler {
  handle(error: unknown, clientType: 'web' | 'mobile'): ClientError {
    if (error instanceof BackendError) {
      // Translate backend error codes
      switch (error.code) {
        case 'USER_NOT_FOUND':
          return new NotFoundError('User not found');
        case 'INSUFFICIENT_BALANCE':
          return new BadRequestError('Insufficient balance for this transaction');
        case 'SERVICE_UNAVAILABLE':
          return new ServiceUnavailableError('Service temporarily unavailable');
        default:
          return new InternalError('An unexpected error occurred');
      }
    }

    // Never expose internal errors to clients
    logger.error('Unexpected error', { error });
    return new InternalError('An unexpected error occurred');
  }
}
```

## Error Handling Strategy

### Error Classification

1. **Client Errors (4xx)**: Client can fix
   - 400 Bad Request: Invalid input
   - 401 Unauthorized: Not authenticated
   - 403 Forbidden: Not authorized
   - 404 Not Found: Resource doesn't exist
   - 422 Unprocessable Entity: Valid format, invalid semantics

2. **Server Errors (5xx)**: Server-side issue
   - 500 Internal Server Error: Unexpected error
   - 502 Bad Gateway: Backend service error
   - 503 Service Unavailable: Temporary unavailability
   - 504 Gateway Timeout: Backend timeout

### Error Response Format

Standard error response structure:

```typescript
interface ErrorResponse {
  error: {
    code: string;          // Machine-readable error code
    message: string;       // Human-readable message
    details?: unknown;     // Additional context (dev mode only)
    requestId: string;     // For debugging
    timestamp: string;     // ISO 8601 timestamp
  };
}

// Example
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": {
      "field": "email",
      "value": "not-an-email"
    },
    "requestId": "req_abc123",
    "timestamp": "2026-04-09T10:30:00Z"
  }
}
```

### Error Middleware

```typescript
// middleware/error.ts
export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  const requestId = req.id || generateId();
  
  // Log error with context
  logger.error('Request error', {
    requestId,
    error: err,
    path: req.path,
    method: req.method,
    userId: req.user?.id,
  });

  // Transform error to client response
  const clientError = errorTranslator.translate(err);
  
  res.status(clientError.statusCode).json({
    error: {
      code: clientError.code,
      message: clientError.message,
      details: config.isDevelopment ? clientError.details : undefined,
      requestId,
      timestamp: new Date().toISOString(),
    },
  });
}
```

### Retry and Circuit Breaking

```typescript
// services/backend-client.ts
export class BackendClient {
  private circuitBreaker: CircuitBreaker;
  
  async request<T>(options: RequestOptions): Promise<T> {
    return this.circuitBreaker.execute(async () => {
      try {
        return await this.httpClient.request<T>(options);
      } catch (error) {
        if (this.isRetryable(error)) {
          return this.retryWithBackoff(options);
        }
        throw error;
      }
    });
  }

  private isRetryable(error: unknown): boolean {
    if (error instanceof HttpError) {
      // Retry on 5xx errors and network issues
      return error.status >= 500 || error.code === 'NETWORK_ERROR';
    }
    return false;
  }

  private async retryWithBackoff<T>(
    options: RequestOptions,
    attempt: number = 1
  ): Promise<T> {
    const maxAttempts = 3;
    const backoffMs = Math.pow(2, attempt) * 100; // Exponential backoff

    if (attempt >= maxAttempts) {
      throw new MaxRetriesError(`Failed after ${maxAttempts} attempts`);
    }

    await sleep(backoffMs);
    
    try {
      return await this.httpClient.request<T>(options);
    } catch (error) {
      if (this.isRetryable(error)) {
        return this.retryWithBackoff(options, attempt + 1);
      }
      throw error;
    }
  }
}
```

## Performance Best Practices

### 1. Use DataLoaders for GraphQL

Prevent N+1 queries:

```typescript
// graphql/dataloaders/userLoader.ts
export function createUserLoader(userService: UserService) {
  return new DataLoader<string, User>(async (userIds) => {
    const users = await userService.getUsersByIds(userIds);
    return userIds.map(id => users.find(u => u.id === id) || null);
  });
}

// graphql/resolvers/order.ts
const orderResolvers = {
  Order: {
    user: (order, _args, { loaders }) => {
      return loaders.userLoader.load(order.userId);
    },
  },
};
```

### 2. Implement Response Caching

```typescript
// middleware/cache.ts
export function cacheMiddleware(duration: number) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const cacheKey = `cache:${req.path}:${JSON.stringify(req.query)}`;
    
    const cached = await redis.get(cacheKey);
    if (cached) {
      return res.json(JSON.parse(cached));
    }

    const originalJson = res.json.bind(res);
    res.json = (data) => {
      redis.setex(cacheKey, duration, JSON.stringify(data));
      return originalJson(data);
    };

    next();
  };
}

// Usage
router.get('/products', cacheMiddleware(300), async (req, res) => {
  const products = await productService.getProducts();
  res.json(products);
});
```

### 3. Use Compression

```typescript
import compression from 'compression';

app.use(compression({
  threshold: 1024, // Only compress responses > 1KB
  level: 6,        // Compression level (1-9)
}));
```

### 4. Optimize Payload Size

```typescript
// Only send fields client needs
function toClientUser(user: BackendUser, fields?: string[]): ClientUser {
  const base = {
    id: user.id,
    email: user.email,
    name: user.name,
  };

  if (!fields) return base;

  const result: Partial<ClientUser> = { ...base };
  
  if (fields.includes('profile')) {
    result.profile = user.profile;
  }
  if (fields.includes('preferences')) {
    result.preferences = user.preferences;
  }

  return result as ClientUser;
}
```

## Testing Standards

### Test Structure

```typescript
// services/__tests__/userService.test.ts
describe('UserService', () => {
  let userService: UserService;
  let mockBackend: jest.Mocked<BackendClient>;

  beforeEach(() => {
    mockBackend = createMockBackendClient();
    userService = new UserService(mockBackend);
  });

  describe('getUserProfile', () => {
    it('should fetch and transform user profile', async () => {
      mockBackend.getUser.mockResolvedValue(mockBackendUser);
      
      const result = await userService.getUserProfile('user123');
      
      expect(result).toEqual({
        id: 'user123',
        email: 'test@example.com',
        fullName: 'John Doe',
      });
    });

    it('should handle user not found', async () => {
      mockBackend.getUser.mockRejectedValue(new NotFoundError());
      
      await expect(userService.getUserProfile('invalid'))
        .rejects.toThrow('User not found');
    });
  });
});
```

## Deployment and Operations

### Health Checks

```typescript
router.get('/health', async (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    dependencies: {
      redis: await checkRedis(),
      userService: await checkBackendService('user'),
      paymentService: await checkBackendService('payment'),
    },
  };

  const allHealthy = Object.values(health.dependencies).every(d => d.status === 'up');
  
  res.status(allHealthy ? 200 : 503).json(health);
});
```

### Monitoring

- **Metrics**: Request rate, response time, error rate
- **Tracing**: Distributed tracing with OpenTelemetry
- **Logging**: Structured JSON logs with correlation IDs
- **Alerts**: SLA violations, error spikes, dependency failures

## Resources

- **Internal Docs**: https://docs.company.com/bff
- **API Docs**: https://api-docs.company.com
- **Runbook**: https://runbook.company.com/bff
- **Slack**: #team-bff
- **On-call**: PagerDuty rotation

## Getting Help

- **Architecture questions**: @architecture-team
- **Backend integration**: @backend-team
- **Frontend coordination**: @frontend-team
- **GraphQL help**: @graphql-guild
- **Security concerns**: @security-team
