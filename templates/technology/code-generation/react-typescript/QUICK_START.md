# Quick Start Guide

Get up and running with React/TypeScript templates in 5 minutes.

## Prerequisites

- Node.js 18+ and npm 9+
- Git (optional)

## Option 1: New Project from Scratch

### Step 1: Create Vite Project

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app
```

### Step 2: Copy Templates

```bash
# Copy template directory to your project
cp -r /path/to/templates/code-generation/react-typescript ./templates
```

### Step 3: Install Dependencies

```bash
# Core dependencies
npm install react-router-dom @tanstack/react-query axios \
  react-hook-form @hookform/resolvers zod \
  styled-components react-helmet-async

# Type definitions
npm install -D @types/styled-components

# Dev dependencies
npm install -D @testing-library/react @testing-library/user-event \
  @testing-library/jest-dom jest-axe vitest jsdom @vitest/ui
```

### Step 4: Setup Configuration

```bash
cd templates
cp vite.config.ts.template ../vite.config.ts
cp tsconfig.json.template ../tsconfig.json
cp eslintrc.json.template ../.eslintrc.json
cp .prettierrc.json.template ../.prettierrc.json
cd ..
```

### Step 5: Generate Your First Component

```bash
cd templates
chmod +x generate-*.sh
./generate-component.sh Button ../src/components --with-styles --with-test
```

### Step 6: Run Development Server

```bash
npm run dev
```

Visit `http://localhost:3000` in your browser.

---

## Option 2: Add to Existing Project

### Step 1: Copy Templates

```bash
mkdir -p templates
cp -r /path/to/templates/code-generation/react-typescript ./templates/
```

### Step 2: Make Scripts Executable

```bash
chmod +x templates/*.sh
```

### Step 3: Generate Code

```bash
cd templates

# Generate a component
./generate-component.sh MyComponent ../src/components --with-styles --with-test

# Generate a page
./generate-page.sh Dashboard ../src/pages

# Generate a custom hook
./generate-hook.sh useData /api/data ../src/hooks

# Generate a context
./generate-context.sh Auth ../src/contexts

# Generate an API service
./generate-service.sh Api https://api.example.com ../src/services
```

---

## Common Commands

### Generate Components

```bash
# Basic component
./generate-component.sh Button

# Component with styles
./generate-component.sh Button --with-styles

# Component with tests
./generate-component.sh Button --with-test

# Component with everything
./generate-component.sh Button --with-styles --with-test

# Custom output directory
./generate-component.sh Button ./src/components/ui --with-styles --with-test
```

### Generate Pages

```bash
# Basic page
./generate-page.sh Dashboard

# Custom output directory
./generate-page.sh Dashboard ./src/pages
```

### Generate Hooks

```bash
# Hook with API endpoint
./generate-hook.sh useUsers /api/users

# Custom output directory
./generate-hook.sh useUsers /api/users ./src/hooks
```

### Generate Contexts

```bash
# Basic context
./generate-context.sh Auth

# Custom output directory
./generate-context.sh Auth ./src/contexts
```

### Generate Services

```bash
# API service
./generate-service.sh User https://api.example.com/v1

# Custom output directory
./generate-service.sh User https://api.example.com/v1 ./src/services
```

---

## Project Structure Setup

Create recommended folder structure:

```bash
mkdir -p src/{components/{common,features},pages,hooks,contexts,services,types,utils,styles,assets,constants}
```

---

## Example: Building a User Feature

Complete workflow for creating a user management feature:

```bash
# 1. Create directories
mkdir -p src/{types,services,hooks,components/users,pages}

# 2. Generate types
cd templates
sed 's/{{TYPE_NAME}}/User/g' types.ts.template > ../src/types/user.types.ts

# 3. Generate API service
./generate-service.sh User https://api.example.com/v1 ../src/services

# 4. Generate custom hooks
./generate-hook.sh useUsers /api/users ../src/hooks
./generate-hook.sh useUser /api/users ../src/hooks

# 5. Generate components
./generate-component.sh UserList ../src/components/users --with-styles --with-test
./generate-component.sh UserDetail ../src/components/users --with-styles --with-test

# 6. Generate pages
./generate-page.sh Users ../src/pages
./generate-page.sh UserProfile ../src/pages
```

Now customize the generated files:

1. Edit `src/types/user.types.ts` - Add User interface
2. Edit `src/services/UserService.ts` - Add user-specific methods
3. Edit `src/hooks/useUsers.ts` - Implement data fetching
4. Edit `src/components/users/UserList/UserList.tsx` - Build list UI
5. Edit `src/pages/Users/Users.tsx` - Compose page

---

## Testing Your Setup

### Run Tests

```bash
npm test
```

### Run Linter

```bash
npm run lint
```

### Type Check

```bash
npm run type-check
```

### Build for Production

```bash
npm run build
npm run preview
```

---

## Common Issues

### Issue: "Template not found"

**Solution**: Ensure you're in the templates directory or use absolute paths.

```bash
cd templates
./generate-component.sh MyComponent
```

### Issue: "Permission denied"

**Solution**: Make scripts executable.

```bash
chmod +x templates/*.sh
```

### Issue: Import errors after generation

**Solution**: Update path aliases in `vite.config.ts`:

```typescript
resolve: {
  alias: {
    '@': path.resolve(__dirname, './src'),
    '@components': path.resolve(__dirname, './src/components'),
    // ... add more aliases
  },
}
```

### Issue: Type errors in generated code

**Solution**: Update TypeScript configuration and install missing types:

```bash
npm install -D @types/react @types/react-dom @types/styled-components
```

---

## Next Steps

1. **Read Full Documentation**: Check README.md for detailed information
2. **Review Examples**: See EXAMPLES.md for real-world usage
3. **Customize Templates**: Modify templates to match your needs
4. **Setup CI/CD**: Add GitHub Actions or similar
5. **Add Testing**: Write comprehensive tests for your components

---

## Resources

- [README.md](./README.md) - Complete documentation
- [EXAMPLES.md](./EXAMPLES.md) - Real-world examples
- [SUMMARY.md](./SUMMARY.md) - Template overview

---

## Help

Need help? Check these resources:

1. **Templates**
   - Component issues → See component.tsx.template
   - Testing issues → See component.test.tsx.template
   - Styling issues → See component.styles.ts.template

2. **Scripts**
   - Check script output for helpful messages
   - Scripts include next steps after generation

3. **Documentation**
   - README.md for detailed usage
   - EXAMPLES.md for practical examples

---

**Happy Coding!** 🚀
