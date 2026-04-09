# React/TypeScript Templates - Usage Examples

Practical examples of using the code generation templates to build a complete React application.

## Example 1: User Management Feature

Build a complete user management feature with list, detail, and form components.

### Step 1: Generate Types

```bash
./generate-types.sh User ./src/types
```

Edit `src/types/user.types.ts`:

```typescript
export interface User extends BaseEntity {
  email: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  avatar?: string;
  status: UserStatus;
}

export enum UserRole {
  Admin = 'admin',
  User = 'user',
  Guest = 'guest',
}

export enum UserStatus {
  Active = 'active',
  Inactive = 'inactive',
  Suspended = 'suspended',
}
```

### Step 2: Generate API Service

```bash
./generate-service.sh User https://api.example.com/v1 ./src/services
```

Add user-specific methods to `src/services/UserService.ts`:

```typescript
// Add to UserService class
async getUsers(params?: QueryParams): Promise<PaginatedResponse<User>> {
  return this.get<PaginatedResponse<User>>('/users', { params });
}

async getUserById(id: string): Promise<User> {
  return this.get<User>(`/users/${id}`);
}

async createUser(data: CreateUserPayload): Promise<User> {
  return this.post<User>('/users', data);
}

async updateUser(id: string, data: UpdateUserPayload): Promise<User> {
  return this.put<User>(`/users/${id}`, data);
}

async deleteUser(id: string): Promise<void> {
  return this.delete<void>(`/users/${id}`);
}
```

### Step 3: Generate Custom Hooks

```bash
./generate-hook.sh useUsers /api/users ./src/hooks
./generate-hook.sh useUser /api/users ./src/hooks
```

Customize `src/hooks/useUsers.ts`:

```typescript
export const useUsers = (params?: QueryParams) => {
  return useQuery<PaginatedResponse<User>, AxiosError<ApiError>>({
    queryKey: ['users', params],
    queryFn: async () => {
      const response = await UserApi.getUsers(params);
      return response.data;
    },
  });
};

export const useCreateUser = () => {
  const queryClient = useQueryClient();
  
  return useMutation<User, AxiosError<ApiError>, CreateUserPayload>({
    mutationFn: async (data) => {
      const response = await UserApi.createUser(data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
};
```

### Step 4: Generate Components

```bash
# User List Component
./generate-component.sh UserList ./src/components --with-styles --with-test

# User Detail Component
./generate-component.sh UserDetail ./src/components --with-styles --with-test

# User Form Component (use form template directly)
```

Implement `src/components/UserList/UserList.tsx`:

```typescript
import React, { useState } from 'react';
import { useUsers } from '@/hooks/useUsers';
import { QueryParams } from '@/types/user.types';

export const UserList: React.FC = () => {
  const [params, setParams] = useState<QueryParams>({ page: 1, pageSize: 10 });
  const { data, isLoading, error } = useUsers(params);

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      <h2>Users</h2>
      <ul>
        {data?.data.map(user => (
          <li key={user.id}>
            {user.firstName} {user.lastName} - {user.email}
          </li>
        ))}
      </ul>
      {/* Pagination controls */}
    </div>
  );
};
```

### Step 5: Generate User Form

Copy form template and customize:

```typescript
// src/components/UserForm/UserForm.tsx
const UserFormSchema = z.object({
  email: z.string().email('Invalid email address'),
  firstName: z.string().min(2, 'First name must be at least 2 characters'),
  lastName: z.string().min(2, 'Last name must be at least 2 characters'),
  role: z.enum(['admin', 'user', 'guest']),
});

type UserFormData = z.infer<typeof UserFormSchema>;

export const UserForm: React.FC<UserFormProps> = ({ onSubmit, defaultValues }) => {
  const { register, handleSubmit, formState: { errors } } = useForm<UserFormData>({
    resolver: zodResolver(UserFormSchema),
    defaultValues,
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="email">Email</label>
        <input id="email" type="email" {...register('email')} />
        {errors.email && <span>{errors.email.message}</span>}
      </div>
      
      <div>
        <label htmlFor="firstName">First Name</label>
        <input id="firstName" {...register('firstName')} />
        {errors.firstName && <span>{errors.firstName.message}</span>}
      </div>
      
      <div>
        <label htmlFor="lastName">Last Name</label>
        <input id="lastName" {...register('lastName')} />
        {errors.lastName && <span>{errors.lastName.message}</span>}
      </div>
      
      <div>
        <label htmlFor="role">Role</label>
        <select id="role" {...register('role')}>
          <option value="user">User</option>
          <option value="admin">Admin</option>
          <option value="guest">Guest</option>
        </select>
      </div>
      
      <button type="submit">Submit</button>
    </form>
  );
};
```

### Step 6: Generate Pages

```bash
./generate-page.sh Users ./src/pages
./generate-page.sh UserDetail ./src/pages
```

Implement `src/pages/Users/Users.tsx`:

```typescript
export const Users: React.FC = () => {
  const navigate = useNavigate();
  const [showForm, setShowForm] = useState(false);
  const createUser = useCreateUser();

  const handleCreateUser = async (data: UserFormData) => {
    await createUser.mutateAsync(data);
    setShowForm(false);
  };

  return (
    <>
      <Helmet>
        <title>Users | My App</title>
      </Helmet>
      
      <div>
        <h1>Users</h1>
        
        <button onClick={() => setShowForm(true)}>
          Add User
        </button>
        
        {showForm && (
          <UserForm onSubmit={handleCreateUser} />
        )}
        
        <UserList />
      </div>
    </>
  );
};
```

---

## Example 2: Shopping Cart with Context

### Step 1: Generate Context

```bash
./generate-context.sh Cart ./src/contexts
```

### Step 2: Customize Cart Context

Edit `src/contexts/CartContext.tsx`:

```typescript
interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  total: number;
  isLoading: boolean;
  error: Error | null;
}

type CartAction =
  | { type: 'ADD_ITEM'; payload: CartItem }
  | { type: 'REMOVE_ITEM'; payload: string }
  | { type: 'UPDATE_QUANTITY'; payload: { id: string; quantity: number } }
  | { type: 'CLEAR_CART' };

const CartReducer = (state: CartState, action: CartAction): CartState => {
  switch (action.type) {
    case 'ADD_ITEM': {
      const existingItem = state.items.find(item => item.id === action.payload.id);
      
      if (existingItem) {
        return {
          ...state,
          items: state.items.map(item =>
            item.id === action.payload.id
              ? { ...item, quantity: item.quantity + action.payload.quantity }
              : item
          ),
        };
      }
      
      return {
        ...state,
        items: [...state.items, action.payload],
      };
    }
    
    case 'REMOVE_ITEM':
      return {
        ...state,
        items: state.items.filter(item => item.id !== action.payload),
      };
    
    case 'UPDATE_QUANTITY':
      return {
        ...state,
        items: state.items.map(item =>
          item.id === action.payload.id
            ? { ...item, quantity: action.payload.quantity }
            : item
        ),
      };
    
    case 'CLEAR_CART':
      return {
        ...state,
        items: [],
        total: 0,
      };
    
    default:
      return state;
  }
};
```

### Step 3: Use Cart Context

```typescript
// App.tsx
import { CartProvider } from '@/contexts/CartContext';

function App() {
  return (
    <CartProvider>
      <Router>
        <Routes>
          {/* Your routes */}
        </Routes>
      </Router>
    </CartProvider>
  );
}

// CartComponent.tsx
import { useCart } from '@/contexts/CartContext';

export const CartComponent: React.FC = () => {
  const { state, actions } = useCart();
  
  return (
    <div>
      <h2>Shopping Cart ({state.items.length} items)</h2>
      {state.items.map(item => (
        <div key={item.id}>
          <span>{item.name}</span>
          <span>${item.price}</span>
          <input
            type="number"
            value={item.quantity}
            onChange={(e) => actions.updateQuantity(item.id, parseInt(e.target.value))}
          />
          <button onClick={() => actions.removeItem(item.id)}>Remove</button>
        </div>
      ))}
      <button onClick={actions.clearCart}>Clear Cart</button>
    </div>
  );
};
```

---

## Example 3: Dashboard with Multiple Data Sources

### Step 1: Generate Multiple Hooks

```bash
./generate-hook.sh useAnalytics /api/analytics ./src/hooks
./generate-hook.sh useRecentOrders /api/orders/recent ./src/hooks
./generate-hook.sh useUserStats /api/users/stats ./src/hooks
```

### Step 2: Generate Dashboard Components

```bash
./generate-component.sh AnalyticsCard ./src/components/dashboard --with-styles
./generate-component.sh RecentOrdersList ./src/components/dashboard --with-styles
./generate-component.sh UserStatsWidget ./src/components/dashboard --with-styles
```

### Step 3: Generate Dashboard Page

```bash
./generate-page.sh Dashboard ./src/pages
```

### Step 4: Implement Dashboard

```typescript
// src/pages/Dashboard/Dashboard.tsx
export const Dashboard: React.FC = () => {
  const { data: analytics, isLoading: analyticsLoading } = useAnalytics();
  const { data: orders, isLoading: ordersLoading } = useRecentOrders();
  const { data: stats, isLoading: statsLoading } = useUserStats();

  const isLoading = analyticsLoading || ordersLoading || statsLoading;

  if (isLoading) return <LoadingSpinner />;

  return (
    <>
      <Helmet>
        <title>Dashboard | My App</title>
      </Helmet>
      
      <div className="dashboard">
        <h1>Dashboard</h1>
        
        <div className="dashboard-grid">
          <AnalyticsCard data={analytics} />
          <UserStatsWidget data={stats} />
          <RecentOrdersList orders={orders} />
        </div>
      </div>
    </>
  );
};
```

---

## Example 4: Authentication Flow

### Step 1: Generate Auth Context

```bash
./generate-context.sh Auth ./src/contexts
```

### Step 2: Generate Auth Service

```bash
./generate-service.sh Auth https://api.example.com/v1/auth ./src/services
```

### Step 3: Implement Auth Logic

```typescript
// src/contexts/AuthContext.tsx
interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

type AuthAction =
  | { type: 'LOGIN_SUCCESS'; payload: { user: User; token: string } }
  | { type: 'LOGOUT' }
  | { type: 'SET_LOADING'; payload: boolean };

// Add custom methods
export const useAuthActions = () => {
  const { actions } = useAuth();
  
  const login = async (email: string, password: string) => {
    actions.setLoading(true);
    try {
      const response = await AuthApi.post('/login', { email, password });
      AuthApi.setAuthToken(response.data.token);
      actions.loginSuccess(response.data);
    } catch (error) {
      throw error;
    } finally {
      actions.setLoading(false);
    }
  };
  
  const logout = () => {
    AuthApi.clearAuthToken();
    actions.logout();
  };
  
  return { login, logout };
};
```

### Step 4: Protected Route Component

```bash
./generate-component.sh ProtectedRoute ./src/components/auth
```

```typescript
// src/components/auth/ProtectedRoute.tsx
import { Navigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const { state } = useAuth();
  
  if (!state.isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  return <>{children}</>;
};
```

---

## Complete Project Setup

### 1. Initialize Project

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app
```

### 2. Install Dependencies

```bash
# Core
npm install react-router-dom @tanstack/react-query axios

# Forms
npm install react-hook-form @hookform/resolvers zod

# Styling
npm install styled-components
npm install -D @types/styled-components

# SEO
npm install react-helmet-async

# Testing
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom jest-axe vitest jsdom
```

### 3. Setup Vite Config

```bash
cp templates/code-generation/react-typescript/vite.config.ts.template vite.config.ts
```

### 4. Generate Core Structure

```bash
# Context providers
./generate-context.sh Auth ./src/contexts
./generate-context.sh Theme ./src/contexts

# API services
./generate-service.sh Api https://api.example.com/v1 ./src/services

# Common components
./generate-component.sh Button ./src/components/common --with-styles --with-test
./generate-component.sh Input ./src/components/common --with-styles --with-test
./generate-component.sh Modal ./src/components/common --with-styles --with-test

# Pages
./generate-page.sh Home ./src/pages
./generate-page.sh Login ./src/pages
./generate-page.sh Dashboard ./src/pages
```

### 5. Setup App Structure

```typescript
// src/App.tsx
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { HelmetProvider } from 'react-helmet-async';
import { ThemeProvider } from 'styled-components';
import { AuthProvider } from '@/contexts/AuthContext';
import { AppRoutes } from '@/routes';
import { theme } from '@/styles/theme';

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <HelmetProvider>
        <ThemeProvider theme={theme}>
          <BrowserRouter>
            <AuthProvider>
              <AppRoutes />
            </AuthProvider>
          </BrowserRouter>
        </ThemeProvider>
      </HelmetProvider>
    </QueryClientProvider>
  );
}

export default App;
```

---

## Best Practices

1. **Type Safety**: Always define proper TypeScript types
2. **Error Handling**: Implement comprehensive error boundaries
3. **Loading States**: Show loading indicators for async operations
4. **Accessibility**: Use semantic HTML and ARIA attributes
5. **Testing**: Write tests for critical user flows
6. **Code Splitting**: Use React.lazy for large components
7. **Caching**: Configure React Query caching strategies
8. **Security**: Never expose sensitive data in client-side code

---

## Troubleshooting

### Common Issues

**Issue**: Template placeholders not replaced
```bash
# Solution: Check sed command syntax
sed 's/{{PLACEHOLDER}}/value/g' template.txt
```

**Issue**: Import errors after generation
```bash
# Solution: Update path aliases in vite.config.ts
```

**Issue**: Type errors in generated code
```bash
# Solution: Run TypeScript compiler to check
npx tsc --noEmit
```

**Issue**: Tests failing after generation
```bash
# Solution: Update test setup and mocks
```

---

For more information, see README.md
