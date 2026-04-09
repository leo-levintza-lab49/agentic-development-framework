# React/TypeScript Code Generation Templates

Comprehensive templates for generating React/TypeScript applications with modern patterns and best practices.

## Available Templates

### 1. Functional Component (`component.tsx.template`)
Basic React functional component with TypeScript, hooks, and accessibility features.

**Placeholders:**
- `{{COMPONENT_NAME}}` - Name of the component
- `{{PROPS}}` - Component props definition

**Features:**
- TypeScript props interface
- useState and useEffect hooks
- ARIA attributes for accessibility
- Event handlers pattern

**Usage:**
```bash
# Replace placeholders
sed 's/{{COMPONENT_NAME}}/Button/g; s/{{PROPS}}/onClick?: () => void;/g' component.tsx.template > Button.tsx
```

---

### 2. Form Component (`form-component.tsx.template`)
Form component with validation using React Hook Form and Zod.

**Placeholders:**
- `{{FORM_NAME}}` - Name of the form
- `{{FIELDS}}` - Form field definitions in Zod schema

**Features:**
- React Hook Form integration
- Zod schema validation
- Error handling and display
- Submit handler with loading states
- Accessibility (ARIA labels, error announcements)

**Usage:**
```bash
sed 's/{{FORM_NAME}}/LoginForm/g' form-component.tsx.template > LoginForm.tsx
```

---

### 3. Custom Hook (`use-hook.ts.template`)
Custom React hook with React Query for data fetching.

**Placeholders:**
- `{{HOOK_NAME}}` - Name of the hook (e.g., useUserData)
- `{{API_ENDPOINT}}` - API endpoint URL

**Features:**
- React Query integration (useQuery and useMutation)
- Loading and error states
- Automatic cache invalidation
- TypeScript generics for type safety

**Usage:**
```bash
sed 's/{{HOOK_NAME}}/useUserData/g; s|{{API_ENDPOINT}}|/api/users|g' use-hook.ts.template > useUserData.ts
```

---

### 4. API Service (`api-service.ts.template`)
Axios-based API service with interceptors and error handling.

**Placeholders:**
- `{{SERVICE_NAME}}` - Name of the service (e.g., User, Product)
- `{{BASE_URL}}` - Base API URL

**Features:**
- Axios instance configuration
- Request/response interceptors
- Authentication token management
- Comprehensive error handling
- All HTTP methods (GET, POST, PUT, PATCH, DELETE)

**Usage:**
```bash
sed 's/{{SERVICE_NAME}}/User/g; s|{{BASE_URL}}|https://api.example.com|g' api-service.ts.template > UserService.ts
```

---

### 5. Component Test (`component.test.tsx.template`)
Comprehensive test suite using React Testing Library.

**Placeholders:**
- `{{COMPONENT_NAME}}` - Name of the component to test

**Features:**
- React Testing Library setup
- User interaction tests
- Accessibility tests with jest-axe
- State management tests
- Error handling tests
- Edge case coverage

**Usage:**
```bash
sed 's/{{COMPONENT_NAME}}/Button/g' component.test.tsx.template > Button.test.tsx
```

---

### 6. Page Component (`page.tsx.template`)
Page-level component with routing, SEO, and data fetching.

**Placeholders:**
- `{{PAGE_NAME}}` - Name of the page

**Features:**
- React Router integration
- React Helmet for SEO meta tags
- Loading, error, and empty states
- Breadcrumb navigation
- Responsive layout structure

**Usage:**
```bash
sed 's/{{PAGE_NAME}}/Dashboard/g' page.tsx.template > Dashboard.tsx
```

---

### 7. Context Provider (`context.tsx.template`)
React Context with reducer pattern for state management.

**Placeholders:**
- `{{CONTEXT_NAME}}` - Name of the context (e.g., Auth, Theme)

**Features:**
- useReducer for state management
- Custom hooks for context access
- Memoized values and actions
- TypeScript strict typing
- Error boundary for context usage outside provider

**Usage:**
```bash
sed 's/{{CONTEXT_NAME}}/Auth/g' context.tsx.template > AuthContext.tsx
```

---

### 8. Styled Components (`component.styles.ts.template`)
CSS-in-JS styling with styled-components or Emotion.

**Placeholders:**
- `{{COMPONENT_NAME}}` - Name of the component

**Features:**
- Theme integration
- Responsive design patterns
- Variant and size props
- Accessibility focus states
- Animation utilities
- TypeScript theme interface

**Usage:**
```bash
sed 's/{{COMPONENT_NAME}}/Button/g' component.styles.ts.template > Button.styles.ts
```

---

### 9. Type Definitions (`types.ts.template`)
Comprehensive TypeScript type definitions and utilities.

**Placeholders:**
- `{{TYPE_NAME}}` - Name of the main type/entity

**Features:**
- Base interfaces and types
- API response types
- Pagination and filtering types
- Utility types (Optional, DeepPartial, etc.)
- Type guards and assertions
- Constants and validation schemas

**Usage:**
```bash
sed 's/{{TYPE_NAME}}/User/g' types.ts.template > user.types.ts
```

---

### 10. Vite Config (`vite.config.ts.template`)
Production-ready Vite configuration for React/TypeScript.

**Features:**
- React plugin with Fast Refresh
- Path aliases for clean imports
- Code splitting and chunking
- Development server with proxy
- Build optimization
- Environment variable handling
- Test configuration (Vitest)

**Usage:**
```bash
cp vite.config.ts.template vite.config.ts
```

---

## Dependencies

Install required dependencies for these templates:

```bash
# Core dependencies
npm install react react-dom react-router-dom

# TypeScript
npm install -D typescript @types/react @types/react-dom

# Form handling
npm install react-hook-form @hookform/resolvers zod

# Data fetching
npm install @tanstack/react-query axios

# Styling (choose one)
npm install styled-components
# or
npm install @emotion/react @emotion/styled

# SEO
npm install react-helmet-async

# Testing
npm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom jest-axe vitest jsdom

# Build tool
npm install -D vite @vitejs/plugin-react
```

## Best Practices

### TypeScript
- Use strict mode
- Define explicit return types
- Use proper generics
- Avoid `any` type

### React
- Functional components only
- Custom hooks for reusable logic
- Proper dependency arrays in useEffect
- Memoization when needed (useMemo, useCallback)

### Accessibility
- Semantic HTML elements
- ARIA attributes where needed
- Keyboard navigation support
- Focus management
- Screen reader support

### Testing
- Test user interactions, not implementation
- Use accessible queries (getByRole, getByLabelText)
- Test accessibility with jest-axe
- Cover edge cases and error states

### Performance
- Code splitting with React.lazy
- Optimize bundle size
- Avoid unnecessary re-renders
- Use proper caching strategies

## Project Structure

Recommended folder structure for React/TypeScript projects:

```
src/
├── components/          # Reusable components
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.styles.ts
│   │   └── Button.test.tsx
│   └── ...
├── pages/              # Page components
│   ├── Dashboard/
│   └── ...
├── hooks/              # Custom hooks
│   ├── useUserData.ts
│   └── ...
├── contexts/           # React contexts
│   ├── AuthContext.tsx
│   └── ...
├── services/           # API services
│   ├── UserService.ts
│   └── ...
├── types/              # Type definitions
│   ├── user.types.ts
│   └── ...
├── utils/              # Utility functions
├── styles/             # Global styles
├── assets/             # Static assets
└── constants/          # Constants
```

## Automation Scripts

Create a script to generate components from templates:

```bash
#!/bin/bash
# generate-component.sh

COMPONENT_NAME=$1
TEMPLATE_DIR="./templates/code-generation/react-typescript"
OUTPUT_DIR="./src/components/$COMPONENT_NAME"

mkdir -p "$OUTPUT_DIR"

# Generate component
sed "s/{{COMPONENT_NAME}}/$COMPONENT_NAME/g; s/{{PROPS}}//g" \
  "$TEMPLATE_DIR/component.tsx.template" > "$OUTPUT_DIR/$COMPONENT_NAME.tsx"

# Generate styles
sed "s/{{COMPONENT_NAME}}/$COMPONENT_NAME/g" \
  "$TEMPLATE_DIR/component.styles.ts.template" > "$OUTPUT_DIR/$COMPONENT_NAME.styles.ts"

# Generate test
sed "s/{{COMPONENT_NAME}}/$COMPONENT_NAME/g" \
  "$TEMPLATE_DIR/component.test.tsx.template" > "$OUTPUT_DIR/$COMPONENT_NAME.test.tsx"

echo "Component $COMPONENT_NAME generated successfully!"
```

Usage:
```bash
chmod +x generate-component.sh
./generate-component.sh Button
```

## Contributing

When adding new templates:
1. Follow existing naming conventions
2. Include comprehensive documentation
3. Add TypeScript types
4. Include accessibility features
5. Add tests
6. Update this README

## License

MIT
