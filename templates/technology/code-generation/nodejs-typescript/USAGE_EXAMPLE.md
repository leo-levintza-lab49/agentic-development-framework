# Usage Example: Creating a User Service

This guide demonstrates how to use these templates to create a complete User management service.

## Step 1: Replace Placeholders

Create a script or manually replace placeholders:

```bash
# Placeholders for User service
SERVICE_NAME=User
MODEL_NAME=User
ROUTE_NAME=users
CONTROLLER_NAME=UserController
MIDDLEWARE_NAME=auth
APP_NAME=user-service
BACKEND_URL=USER_API_URL
TEST_NAME=UserService
FIELDS="name: string;\n  email: string;\n  role: UserRole;\n  isActive: boolean;"
```

## Step 2: Define the Model

Create `src/models/user.model.ts`:

```typescript
// Replace {{MODEL_NAME}} with User and {{FIELDS}} with actual fields
export interface User extends BaseEntity {
  name: string;
  email: string;
  role: UserRole;
  isActive: boolean;
}

export enum UserRole {
  ADMIN = 'admin',
  USER = 'user',
  GUEST = 'guest'
}

export interface CreateUserDto {
  name: string;
  email: string;
  role?: UserRole;
}

export interface UpdateUserDto {
  name?: string;
  email?: string;
  role?: UserRole;
  isActive?: boolean;
}
```

## Step 3: Create the Service

Create `src/services/user.service.ts` from `service.ts.template`:

```typescript
export class UserService {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.USER_API_URL || 'http://localhost:3000',
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json'
      }
    });
    // ... rest of template
  }

  async getAll(options: PaginationOptions): Promise<PaginatedResult<User>> {
    // Implementation from template
  }

  async getById(id: string): Promise<User | null> {
    // Implementation from template
  }

  // ... other methods
}
```

## Step 4: Create the Controller

Create `src/controllers/user.controller.ts` from `controller.ts.template`:

```typescript
export class UserController {
  private userService: UserService;

  constructor() {
    this.userService = new UserService();
  }

  getAll = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    // Implementation from template
  };

  // ... other methods
}
```

## Step 5: Create the Routes

Create `src/routes/user.routes.ts` from `route.ts.template`:

```typescript
const router = Router();
const userController = new UserController();

router.get('/', 
  [
    query('page').optional().isInt({ min: 1 }).toInt(),
    query('limit').optional().isInt({ min: 1, max: 100 }).toInt(),
    validate
  ],
  userController.getAll
);

router.get('/:id', 
  [param('id').isUUID(), validate],
  userController.getById
);

router.post('/',
  [
    body('name').notEmpty().isString(),
    body('email').isEmail(),
    body('role').optional().isIn(['admin', 'user', 'guest']),
    validate
  ],
  userController.create
);

// ... other routes

export default router;
```

## Step 6: Register Routes in App

Update `src/app.ts`:

```typescript
import userRoutes from './routes/user.routes';

// In createApp function:
app.use('/api/v1/users', authenticate, userRoutes);
```

## Step 7: Write Tests

Create `src/__tests__/user.service.test.ts`:

```typescript
describe('UserService', () => {
  let service: UserService;

  beforeEach(() => {
    service = new UserService();
    service.disableCache();
  });

  describe('getAll', () => {
    it('should fetch all users', async () => {
      const mockResponse = {
        items: [mockUser],
        page: 1,
        limit: 10,
        total: 1,
        totalPages: 1
      };

      mockAxios.onGet('/users').reply(200, mockResponse);

      const result = await service.getAll({ page: 1, limit: 10 });
      expect(result.items).toHaveLength(1);
    });
  });

  // ... other tests
});
```

## Step 8: Configure Environment

Create `.env`:

```bash
NODE_ENV=development
PORT=3000
JWT_SECRET=your-secret-key
USER_API_URL=http://localhost:8000/api
REDIS_HOST=localhost
REDIS_PORT=6379
```

## Step 9: Run the Service

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Run tests
npm test

# Build for production
npm run build
npm start
```

## Step 10: Test the API

```bash
# Health check
curl http://localhost:3000/health

# Get all users (requires auth token)
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/v1/users

# Get user by ID
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/v1/users/123e4567-e89b-12d3-a456-426614174000

# Create user
curl -X POST \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com","role":"user"}' \
  http://localhost:3000/api/v1/users

# Update user
curl -X PUT \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","email":"jane@example.com"}' \
  http://localhost:3000/api/v1/users/123e4567-e89b-12d3-a456-426614174000

# Delete user
curl -X DELETE \
  -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/v1/users/123e4567-e89b-12d3-a456-426614174000
```

## Complete Project Structure

```
user-service/
├── src/
│   ├── config/
│   │   └── index.ts
│   ├── controllers/
│   │   └── user.controller.ts
│   ├── errors/
│   │   └── ApiError.ts
│   ├── middleware/
│   │   └── auth.middleware.ts
│   ├── models/
│   │   └── user.model.ts
│   ├── routes/
│   │   └── user.routes.ts
│   ├── services/
│   │   └── user.service.ts
│   ├── utils/
│   │   ├── cache.ts
│   │   └── logger.ts
│   ├── __tests__/
│   │   ├── user.service.test.ts
│   │   └── user.route.test.ts
│   ├── app.ts
│   └── index.ts
├── logs/
├── dist/
├── .env
├── .env.template
├── .eslintrc.json
├── .prettierrc.json
├── .gitignore
├── .dockerignore
├── Dockerfile
├── package.json
├── tsconfig.json
└── README.md
```

## Advanced Patterns

### BFF Pattern: Aggregating User Data

```typescript
async getUserProfile(userId: string): Promise<UserProfile> {
  const [user, orders, preferences] = await Promise.allSettled([
    this.getById(userId),
    this.fetchUserOrders(userId),
    this.fetchUserPreferences(userId)
  ]);

  return {
    user: user.status === 'fulfilled' ? user.value : null,
    orders: orders.status === 'fulfilled' ? orders.value : [],
    preferences: preferences.status === 'fulfilled' ? preferences.value : {}
  };
}
```

### Caching Strategy

```typescript
@Cacheable(300) // Cache for 5 minutes
async getById(id: string): Promise<User | null> {
  // Method implementation
}

@InvalidateCache('users:*')
async update(id: string, data: UpdateUserDto): Promise<User | null> {
  // Method implementation
}
```

### Custom Validation

```typescript
router.post('/',
  [
    body('email')
      .isEmail()
      .normalizeEmail()
      .custom(async (email) => {
        const exists = await userService.existsByEmail(email);
        if (exists) {
          throw new Error('Email already in use');
        }
      }),
    body('password')
      .isLength({ min: 8 })
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
      .withMessage('Password must contain uppercase, lowercase, and number'),
    validate
  ],
  userController.create
);
```

## Monitoring

Add application monitoring:

```typescript
// In app.ts
import * as Sentry from '@sentry/node';

if (config.env === 'production') {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: config.env
  });
  
  app.use(Sentry.Handlers.requestHandler());
  app.use(Sentry.Handlers.errorHandler());
}
```

## Conclusion

You now have a complete, production-ready User service with:
- Type safety
- Input validation
- Authentication/authorization
- Caching
- Error handling
- Logging
- Testing
- Docker support

Repeat this process for other entities (Products, Orders, etc.) by replacing the placeholders accordingly.
