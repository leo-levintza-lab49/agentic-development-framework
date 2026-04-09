# React/TypeScript Code Generation Templates - Index

## Quick Navigation

- [QUICK_START.md](./QUICK_START.md) - Get started in 5 minutes
- [README.md](./README.md) - Complete documentation
- [EXAMPLES.md](./EXAMPLES.md) - Real-world usage examples
- [SUMMARY.md](./SUMMARY.md) - Project overview and features

## Templates

### Component Templates
- [component.tsx.template](./component.tsx.template) - Functional component
- [form-component.tsx.template](./form-component.tsx.template) - Form with validation
- [page.tsx.template](./page.tsx.template) - Page component with routing
- [component.styles.ts.template](./component.styles.ts.template) - Styled components
- [component.test.tsx.template](./component.test.tsx.template) - Test suite

### Logic Templates
- [use-hook.ts.template](./use-hook.ts.template) - Custom React hook
- [api-service.ts.template](./api-service.ts.template) - API service
- [context.tsx.template](./context.tsx.template) - Context provider
- [types.ts.template](./types.ts.template) - Type definitions

### Configuration Templates
- [vite.config.ts.template](./vite.config.ts.template) - Vite configuration
- [tsconfig.json.template](./tsconfig.json.template) - TypeScript config
- [eslintrc.json.template](./eslintrc.json.template) - ESLint config
- [.prettierrc.json.template](./.prettierrc.json.template) - Prettier config
- [package.json.template](./package.json.template) - Dependencies

## Generation Scripts

- [generate-component.sh](./generate-component.sh) - Generate components
- [generate-page.sh](./generate-page.sh) - Generate pages
- [generate-hook.sh](./generate-hook.sh) - Generate hooks
- [generate-context.sh](./generate-context.sh) - Generate contexts
- [generate-service.sh](./generate-service.sh) - Generate API services

## Quick Commands

```bash
# Component with styles and tests
./generate-component.sh Button --with-styles --with-test

# Page component
./generate-page.sh Dashboard

# Custom hook
./generate-hook.sh useUsers /api/users

# Context provider
./generate-context.sh Auth

# API service
./generate-service.sh User https://api.example.com
```

## File Count

- **10** Core templates
- **5** Generation scripts (executable)
- **4** Configuration templates
- **4** Documentation files

Total: **23 files** with ~3,000+ lines of production-ready code

## Technology Stack

- React 18.3+
- TypeScript 5.4+
- Vite 5.2+
- React Query (TanStack Query)
- React Hook Form + Zod
- Styled Components
- React Testing Library
- Vitest

## Features

- Modern React patterns (functional components, hooks)
- TypeScript strict mode
- Accessibility (ARIA, keyboard navigation)
- Comprehensive testing setup
- Production-optimized build configuration
- Automated code generation scripts

## Start Here

1. New to templates? → [QUICK_START.md](./QUICK_START.md)
2. Need details? → [README.md](./README.md)
3. Want examples? → [EXAMPLES.md](./EXAMPLES.md)
4. Want overview? → [SUMMARY.md](./SUMMARY.md)
