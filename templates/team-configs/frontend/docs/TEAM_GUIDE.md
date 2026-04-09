# Frontend Team Guide

## Welcome to the Frontend Team

This guide covers our coding standards, best practices, and workflows for building high-quality React applications at Polybase.

## Table of Contents

- [Tech Stack](#tech-stack)
- [Development Setup](#development-setup)
- [React Coding Standards](#react-coding-standards)
- [Component Design Patterns](#component-design-patterns)
- [State Management](#state-management)
- [Accessibility Guidelines](#accessibility-guidelines)
- [Testing Strategy](#testing-strategy)
- [Performance Best Practices](#performance-best-practices)
- [Design System](#design-system)
- [Code Review Guidelines](#code-review-guidelines)

## Tech Stack

### Core Technologies

- **React 18**: UI framework with concurrent features
- **TypeScript 5**: Type-safe JavaScript
- **Vite**: Fast build tool and dev server
- **React Router 6**: Client-side routing
- **Zustand**: Lightweight state management
- **React Query**: Server state and data fetching
- **Tailwind CSS**: Utility-first CSS framework

### Testing

- **Vitest**: Fast unit test runner
- **React Testing Library**: Component testing
- **Playwright**: E2E and visual regression testing
- **axe-core**: Accessibility testing

### Code Quality

- **ESLint**: JavaScript/TypeScript linting
- **Prettier**: Code formatting
- **Husky**: Git hooks
- **Commitlint**: Commit message validation

## Development Setup

### Prerequisites

- Node.js 20.x or later
- npm 10.x or later
- Git

### Getting Started

```bash
# Clone repository
git clone <repository-url>
cd frontend

# Install dependencies
npm install

# Start dev server
npm run dev

# Run tests
npm test

# Run linting
npm run lint

# Build for production
npm run build
```

### Environment Variables

Copy `.env.example` to `.env.local` and configure:

```env
VITE_API_BASE_URL=http://localhost:3000/api
VITE_APP_ENV=development
```

## React Coding Standards

### Component Structure

Use functional components with hooks:

```typescript
// Good: Functional component with TypeScript
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  onClick?: () => void;
  children: React.ReactNode;
  disabled?: boolean;
}

export function Button({ 
  variant = 'primary', 
  size = 'md',
  onClick,
  children,
  disabled = false
}: ButtonProps) {
  return (
    <button
      className={cn(buttonStyles.base, buttonStyles[variant], buttonStyles[size])}
      onClick={onClick}
      disabled={disabled}
      type="button"
    >
      {children}
    </button>
  );
}
```

### File Organization

```
src/
├── components/          # Shared components
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx
│   │   └── index.ts
├── features/            # Feature-specific code
│   ├── dashboard/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── utils/
│   │   └── DashboardPage.tsx
├── hooks/               # Shared custom hooks
├── utils/               # Utility functions
├── services/            # API services
├── types/               # TypeScript types
├── assets/              # Images, fonts, etc.
└── styles/              # Global styles
```

### Naming Conventions

- **Components**: PascalCase (`UserProfile.tsx`)
- **Hooks**: camelCase with 'use' prefix (`useAuth.ts`)
- **Utilities**: camelCase (`formatDate.ts`)
- **Constants**: UPPER_SNAKE_CASE (`API_BASE_URL`)
- **Types/Interfaces**: PascalCase (`UserProfile`)

### Import Order

```typescript
// 1. React and external libraries
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

// 2. Internal imports (absolute paths)
import { Button } from '@/components/Button';
import { useAuth } from '@/hooks/useAuth';
import { formatDate } from '@/utils/date';

// 3. Types
import type { User } from '@/types/user';

// 4. Styles and assets
import styles from './Dashboard.module.css';
import logo from '@/assets/logo.svg';
```

## Component Design Patterns

### Container/Presentation Pattern

Separate logic from presentation:

```typescript
// UserProfileContainer.tsx (logic)
export function UserProfileContainer() {
  const { user, isLoading } = useUser();
  const { updateProfile } = useUpdateProfile();

  if (isLoading) return <Skeleton />;
  if (!user) return <ErrorState />;

  return <UserProfile user={user} onUpdate={updateProfile} />;
}

// UserProfile.tsx (presentation)
interface UserProfileProps {
  user: User;
  onUpdate: (data: Partial<User>) => void;
}

export function UserProfile({ user, onUpdate }: UserProfileProps) {
  return (
    <div className="profile">
      <h1>{user.name}</h1>
      {/* UI only, no business logic */}
    </div>
  );
}
```

### Compound Components

For complex UI with shared state:

```typescript
interface TabsContextValue {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const TabsContext = createContext<TabsContextValue | null>(null);

export function Tabs({ children, defaultTab }: TabsProps) {
  const [activeTab, setActiveTab] = useState(defaultTab);
  
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

Tabs.List = function TabsList({ children }: { children: React.ReactNode }) {
  return <div className="tabs-list">{children}</div>;
};

Tabs.Tab = function Tab({ id, children }: TabProps) {
  const { activeTab, setActiveTab } = useContext(TabsContext)!;
  return (
    <button 
      onClick={() => setActiveTab(id)}
      aria-selected={activeTab === id}
    >
      {children}
    </button>
  );
};

Tabs.Panel = function TabPanel({ id, children }: TabPanelProps) {
  const { activeTab } = useContext(TabsContext)!;
  if (activeTab !== id) return null;
  return <div role="tabpanel">{children}</div>;
};

// Usage
<Tabs defaultTab="profile">
  <Tabs.List>
    <Tabs.Tab id="profile">Profile</Tabs.Tab>
    <Tabs.Tab id="settings">Settings</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel id="profile"><ProfileContent /></Tabs.Panel>
  <Tabs.Panel id="settings"><SettingsContent /></Tabs.Panel>
</Tabs>
```

### Custom Hooks

Extract reusable logic:

```typescript
// useForm.ts
export function useForm<T extends Record<string, any>>(
  initialValues: T,
  validate?: (values: T) => Record<string, string>
) {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [touched, setTouched] = useState<Record<string, boolean>>({});

  const handleChange = (name: keyof T, value: any) => {
    setValues(prev => ({ ...prev, [name]: value }));
    if (touched[name as string] && validate) {
      const newErrors = validate({ ...values, [name]: value });
      setErrors(newErrors);
    }
  };

  const handleBlur = (name: keyof T) => {
    setTouched(prev => ({ ...prev, [name]: true }));
    if (validate) {
      const newErrors = validate(values);
      setErrors(newErrors);
    }
  };

  const handleSubmit = (onSubmit: (values: T) => void) => {
    return (e: React.FormEvent) => {
      e.preventDefault();
      if (validate) {
        const newErrors = validate(values);
        setErrors(newErrors);
        if (Object.keys(newErrors).length === 0) {
          onSubmit(values);
        }
      } else {
        onSubmit(values);
      }
    };
  };

  return { values, errors, touched, handleChange, handleBlur, handleSubmit };
}
```

## State Management

### Local State

Use `useState` for component-specific state:

```typescript
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

### Global State (Zustand)

For application-wide state:

```typescript
// stores/authStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  login: (user: User) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      login: (user) => set({ user, isAuthenticated: true }),
      logout: () => set({ user: null, isAuthenticated: false }),
    }),
    { name: 'auth-storage' }
  )
);

// Usage
function Header() {
  const { user, logout } = useAuthStore();
  return <button onClick={logout}>Logout {user?.name}</button>;
}
```

### Server State (React Query)

For data fetching and caching:

```typescript
// hooks/useUsers.ts
export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const response = await fetch('/api/users');
      return response.json();
    },
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

export function useUpdateUser() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (user: User) => {
      const response = await fetch(`/api/users/${user.id}`, {
        method: 'PUT',
        body: JSON.stringify(user),
      });
      return response.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}
```

## Accessibility Guidelines

### Semantic HTML

Use appropriate HTML elements:

```typescript
// Good
<button onClick={handleClick}>Click me</button>
<nav><a href="/home">Home</a></nav>

// Bad
<div onClick={handleClick}>Click me</div>
<div><span onClick={goHome}>Home</span></div>
```

### ARIA Labels

Provide context for assistive technologies:

```typescript
<button 
  aria-label="Close dialog"
  onClick={onClose}
>
  <XIcon aria-hidden="true" />
</button>

<input
  type="text"
  id="email"
  aria-describedby="email-error"
  aria-invalid={!!errors.email}
/>
{errors.email && (
  <span id="email-error" role="alert">
    {errors.email}
  </span>
)}
```

### Keyboard Navigation

Ensure all interactive elements are keyboard accessible:

```typescript
function Modal({ isOpen, onClose, children }: ModalProps) {
  const modalRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen) {
      // Trap focus within modal
      const focusableElements = modalRef.current?.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      const firstElement = focusableElements?.[0] as HTMLElement;
      firstElement?.focus();
    }
  }, [isOpen]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      onClose();
    }
  };

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      onKeyDown={handleKeyDown}
    >
      {children}
    </div>
  );
}
```

### Focus Management

Handle focus appropriately:

```typescript
function ConfirmDialog({ onConfirm, onCancel }: ConfirmDialogProps) {
  const cancelButtonRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    // Focus cancel button when dialog opens (safer default)
    cancelButtonRef.current?.focus();
  }, []);

  return (
    <div role="dialog">
      <h2 id="dialog-title">Confirm Action</h2>
      <p>Are you sure you want to proceed?</p>
      <button onClick={onConfirm}>Confirm</button>
      <button ref={cancelButtonRef} onClick={onCancel}>Cancel</button>
    </div>
  );
}
```

## Testing Strategy

### Unit Tests

Test individual components and functions:

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  it('renders with children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    await userEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

### Integration Tests

Test component interactions:

```typescript
describe('LoginForm', () => {
  it('submits form with valid data', async () => {
    const mockLogin = vi.fn();
    render(<LoginForm onLogin={mockLogin} />);

    await userEvent.type(
      screen.getByLabelText(/email/i), 
      'user@example.com'
    );
    await userEvent.type(
      screen.getByLabelText(/password/i), 
      'password123'
    );
    await userEvent.click(
      screen.getByRole('button', { name: /sign in/i })
    );

    expect(mockLogin).toHaveBeenCalledWith({
      email: 'user@example.com',
      password: 'password123'
    });
  });

  it('shows validation errors for invalid input', async () => {
    render(<LoginForm />);

    await userEvent.click(
      screen.getByRole('button', { name: /sign in/i })
    );

    expect(await screen.findByText(/email is required/i)).toBeInTheDocument();
  });
});
```

### Accessibility Tests

```typescript
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

describe('UserProfile accessibility', () => {
  it('has no accessibility violations', async () => {
    const { container } = render(<UserProfile user={mockUser} />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});
```

## Performance Best Practices

### Code Splitting

Lazy load routes and heavy components:

```typescript
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./features/dashboard/DashboardPage'));
const Analytics = lazy(() => import('./features/analytics/AnalyticsPage'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/analytics" element={<Analytics />} />
      </Routes>
    </Suspense>
  );
}
```

### Memoization

Optimize expensive computations and prevent unnecessary re-renders:

```typescript
// useMemo for expensive calculations
const sortedUsers = useMemo(() => {
  return users.sort((a, b) => a.name.localeCompare(b.name));
}, [users]);

// useCallback for function references
const handleUserClick = useCallback((userId: string) => {
  navigate(`/users/${userId}`);
}, [navigate]);

// React.memo for component memoization
export const UserCard = memo(function UserCard({ user }: UserCardProps) {
  return <div>{user.name}</div>;
});
```

### Image Optimization

```typescript
<img
  src="/images/hero.jpg"
  srcSet="/images/hero-400w.jpg 400w, /images/hero-800w.jpg 800w"
  sizes="(max-width: 600px) 400px, 800px"
  alt="Hero image"
  loading="lazy"
/>
```

## Design System

### Using Design Tokens

```typescript
import { colors, spacing, typography } from '@/design-system/tokens';

const buttonStyles = {
  base: `
    ${typography.button}
    ${spacing.padding.md}
    rounded-md
    transition-colors
  `,
  primary: `bg-${colors.primary.base} hover:bg-${colors.primary.hover}`,
  secondary: `bg-${colors.secondary.base} hover:bg-${colors.secondary.hover}`,
};
```

### Component Library

Import from the shared component library:

```typescript
import { Button, Card, Input, Modal } from '@/components';

function MyFeature() {
  return (
    <Card>
      <Input label="Email" type="email" />
      <Button variant="primary">Submit</Button>
    </Card>
  );
}
```

## Code Review Guidelines

### As a Reviewer

- Be constructive and kind
- Explain the "why" behind suggestions
- Approve PRs that improve the codebase, even if not perfect
- Focus on high-impact issues
- Praise good work

### As an Author

- Keep PRs small and focused
- Provide context in the description
- Respond to feedback promptly
- Don't take feedback personally
- Ask questions when unclear

## Resources

- [React Documentation](https://react.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [React Testing Library](https://testing-library.com/react)
- [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Internal Design System](https://design-system.polybase.io)

## Getting Help

- Slack: `#frontend-team`
- Tech Lead: [Name]
- Design Team: `#design-system`
- General Questions: `#engineering`

---

**Last Updated**: 2026-04-09
**Maintained By**: Frontend Team
