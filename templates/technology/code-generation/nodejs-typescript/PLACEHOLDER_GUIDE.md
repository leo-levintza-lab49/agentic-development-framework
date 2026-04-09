# Placeholder Replacement Guide

Quick reference for replacing placeholders in templates.

## Placeholder Patterns

### Naming Conventions

| Entity Type | Example | Placeholders |
|-------------|---------|--------------|
| User Management | User, users | SERVICE_NAME=User, ROUTE_NAME=users |
| Product Catalog | Product, products | SERVICE_NAME=Product, ROUTE_NAME=products |
| Order Processing | Order, orders | SERVICE_NAME=Order, ROUTE_NAME=orders |
| Payment System | Payment, payments | SERVICE_NAME=Payment, ROUTE_NAME=payments |

## Complete Placeholder Sets

### Example 1: User Service

```bash
SERVICE_NAME="User"
MODEL_NAME="User"
ROUTE_NAME="users"
CONTROLLER_NAME="UserController"
MIDDLEWARE_NAME="auth"
APP_NAME="user-service"
BACKEND_URL="USER_API_URL"
TEST_NAME="UserService"
FIELDS="name: string;\n  email: string;\n  role: UserRole;\n  isActive: boolean;"
```

### Example 2: Product Service

```bash
SERVICE_NAME="Product"
MODEL_NAME="Product"
ROUTE_NAME="products"
CONTROLLER_NAME="ProductController"
MIDDLEWARE_NAME="validation"
APP_NAME="product-service"
BACKEND_URL="PRODUCT_API_URL"
TEST_NAME="ProductService"
FIELDS="name: string;\n  description: string;\n  price: number;\n  sku: string;\n  inStock: boolean;"
```

### Example 3: Order Service

```bash
SERVICE_NAME="Order"
MODEL_NAME="Order"
ROUTE_NAME="orders"
CONTROLLER_NAME="OrderController"
MIDDLEWARE_NAME="auth"
APP_NAME="order-service"
BACKEND_URL="ORDER_API_URL"
TEST_NAME="OrderService"
FIELDS="userId: string;\n  items: OrderItem[];\n  totalAmount: number;\n  status: OrderStatus;\n  shippingAddress: Address;"
```

## Automated Replacement Scripts

### Bash Script

```bash
#!/bin/bash
# replace-placeholders.sh

# Configuration
SERVICE_NAME="User"
MODEL_NAME="User"
ROUTE_NAME="users"
CONTROLLER_NAME="UserController"
MIDDLEWARE_NAME="auth"
APP_NAME="user-service"
BACKEND_URL="USER_API_URL"
TEST_NAME="UserService"
FIELDS="name: string; email: string; role: UserRole;"

# Directory containing templates
TEMPLATE_DIR="templates/code-generation/nodejs-typescript"
OUTPUT_DIR="src"

# Create output directories
mkdir -p "$OUTPUT_DIR"/{config,controllers,errors,middleware,models,routes,services,utils,__tests__}

# Function to replace placeholders
replace_placeholders() {
  local input_file="$1"
  local output_file="$2"
  
  sed -e "s/{{SERVICE_NAME}}/$SERVICE_NAME/g" \
      -e "s/{{MODEL_NAME}}/$MODEL_NAME/g" \
      -e "s/{{ROUTE_NAME}}/$ROUTE_NAME/g" \
      -e "s/{{CONTROLLER_NAME}}/$CONTROLLER_NAME/g" \
      -e "s/{{MIDDLEWARE_NAME}}/$MIDDLEWARE_NAME/g" \
      -e "s/{{APP_NAME}}/$APP_NAME/g" \
      -e "s/{{BACKEND_URL}}/$BACKEND_URL/g" \
      -e "s/{{TEST_NAME}}/$TEST_NAME/g" \
      -e "s/{{FIELDS}}/$FIELDS/g" \
      "$input_file" > "$output_file"
}

# Process templates
replace_placeholders "$TEMPLATE_DIR/route.ts.template" "$OUTPUT_DIR/routes/${ROUTE_NAME}.routes.ts"
replace_placeholders "$TEMPLATE_DIR/service.ts.template" "$OUTPUT_DIR/services/${ROUTE_NAME}.service.ts"
replace_placeholders "$TEMPLATE_DIR/model.ts.template" "$OUTPUT_DIR/models/${ROUTE_NAME}.model.ts"
replace_placeholders "$TEMPLATE_DIR/controller.ts.template" "$OUTPUT_DIR/controllers/${ROUTE_NAME}.controller.ts"
replace_placeholders "$TEMPLATE_DIR/middleware.ts.template" "$OUTPUT_DIR/middleware/${MIDDLEWARE_NAME}.middleware.ts"
replace_placeholders "$TEMPLATE_DIR/service.test.ts.template" "$OUTPUT_DIR/__tests__/${ROUTE_NAME}.service.test.ts"
replace_placeholders "$TEMPLATE_DIR/route.test.ts.template" "$OUTPUT_DIR/__tests__/${ROUTE_NAME}.route.test.ts"

# Copy utility files (no placeholders)
cp "$TEMPLATE_DIR/ApiError.ts.template" "$OUTPUT_DIR/errors/ApiError.ts"
cp "$TEMPLATE_DIR/logger.ts.template" "$OUTPUT_DIR/utils/logger.ts"
cp "$TEMPLATE_DIR/cache.ts.template" "$OUTPUT_DIR/utils/cache.ts"
cp "$TEMPLATE_DIR/config.ts.template" "$OUTPUT_DIR/config/index.ts"

# Copy app and index
replace_placeholders "$TEMPLATE_DIR/app.ts.template" "$OUTPUT_DIR/app.ts"
replace_placeholders "$TEMPLATE_DIR/index.ts.template" "$OUTPUT_DIR/index.ts"

# Copy configuration files
replace_placeholders "$TEMPLATE_DIR/package.json.template" "package.json"
cp "$TEMPLATE_DIR/tsconfig.json.template" "tsconfig.json"
replace_placeholders "$TEMPLATE_DIR/.env.template" ".env"
cp "$TEMPLATE_DIR/.eslintrc.json.template" ".eslintrc.json"
cp "$TEMPLATE_DIR/.prettierrc.json.template" ".prettierrc.json"
cp "$TEMPLATE_DIR/.gitignore.template" ".gitignore"
cp "$TEMPLATE_DIR/.dockerignore.template" ".dockerignore"
cp "$TEMPLATE_DIR/Dockerfile.template" "Dockerfile"

echo "Templates processed successfully!"
```

### Node.js Script

```javascript
// replace-placeholders.js
const fs = require('fs');
const path = require('path');

// Configuration
const config = {
  SERVICE_NAME: 'User',
  MODEL_NAME: 'User',
  ROUTE_NAME: 'users',
  CONTROLLER_NAME: 'UserController',
  MIDDLEWARE_NAME: 'auth',
  APP_NAME: 'user-service',
  BACKEND_URL: 'USER_API_URL',
  TEST_NAME: 'UserService',
  FIELDS: 'name: string;\n  email: string;\n  role: UserRole;'
};

const TEMPLATE_DIR = 'templates/code-generation/nodejs-typescript';
const OUTPUT_DIR = 'src';

// Create directories
const dirs = [
  `${OUTPUT_DIR}/config`,
  `${OUTPUT_DIR}/controllers`,
  `${OUTPUT_DIR}/errors`,
  `${OUTPUT_DIR}/middleware`,
  `${OUTPUT_DIR}/models`,
  `${OUTPUT_DIR}/routes`,
  `${OUTPUT_DIR}/services`,
  `${OUTPUT_DIR}/utils`,
  `${OUTPUT_DIR}/__tests__`
];

dirs.forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Replace placeholders in content
function replacePlaceholders(content) {
  let result = content;
  Object.keys(config).forEach(key => {
    const placeholder = `{{${key}}}`;
    result = result.split(placeholder).join(config[key]);
  });
  return result;
}

// Process template file
function processTemplate(inputFile, outputFile) {
  const content = fs.readFileSync(inputFile, 'utf8');
  const processed = replacePlaceholders(content);
  fs.writeFileSync(outputFile, processed);
  console.log(`Created: ${outputFile}`);
}

// Template mappings
const templates = [
  { input: 'route.ts.template', output: `routes/${config.ROUTE_NAME}.routes.ts` },
  { input: 'service.ts.template', output: `services/${config.ROUTE_NAME}.service.ts` },
  { input: 'model.ts.template', output: `models/${config.ROUTE_NAME}.model.ts` },
  { input: 'controller.ts.template', output: `controllers/${config.ROUTE_NAME}.controller.ts` },
  { input: 'middleware.ts.template', output: `middleware/${config.MIDDLEWARE_NAME}.middleware.ts` },
  { input: 'service.test.ts.template', output: `__tests__/${config.ROUTE_NAME}.service.test.ts` },
  { input: 'route.test.ts.template', output: `__tests__/${config.ROUTE_NAME}.route.test.ts` },
  { input: 'ApiError.ts.template', output: 'errors/ApiError.ts' },
  { input: 'logger.ts.template', output: 'utils/logger.ts' },
  { input: 'cache.ts.template', output: 'utils/cache.ts' },
  { input: 'config.ts.template', output: 'config/index.ts' },
  { input: 'app.ts.template', output: 'app.ts' },
  { input: 'index.ts.template', output: 'index.ts' }
];

// Process templates
templates.forEach(({ input, output }) => {
  const inputPath = path.join(TEMPLATE_DIR, input);
  const outputPath = path.join(OUTPUT_DIR, output);
  processTemplate(inputPath, outputPath);
});

// Process root configuration files
const rootFiles = [
  { input: 'package.json.template', output: 'package.json' },
  { input: 'tsconfig.json.template', output: 'tsconfig.json' },
  { input: '.env.template', output: '.env' },
  { input: '.eslintrc.json.template', output: '.eslintrc.json' },
  { input: '.prettierrc.json.template', output: '.prettierrc.json' },
  { input: '.gitignore.template', output: '.gitignore' },
  { input: '.dockerignore.template', output: '.dockerignore' },
  { input: 'Dockerfile.template', output: 'Dockerfile' }
];

rootFiles.forEach(({ input, output }) => {
  const inputPath = path.join(TEMPLATE_DIR, input);
  processTemplate(inputPath, output);
});

console.log('\nTemplates processed successfully!');
console.log(`\nNext steps:`);
console.log(`1. npm install`);
console.log(`2. Update .env with your configuration`);
console.log(`3. npm run dev`);
```

### Python Script

```python
#!/usr/bin/env python3
# replace_placeholders.py

import os
import re
from pathlib import Path

# Configuration
config = {
    'SERVICE_NAME': 'User',
    'MODEL_NAME': 'User',
    'ROUTE_NAME': 'users',
    'CONTROLLER_NAME': 'UserController',
    'MIDDLEWARE_NAME': 'auth',
    'APP_NAME': 'user-service',
    'BACKEND_URL': 'USER_API_URL',
    'TEST_NAME': 'UserService',
    'FIELDS': 'name: string;\n  email: string;\n  role: UserRole;'
}

TEMPLATE_DIR = 'templates/code-generation/nodejs-typescript'
OUTPUT_DIR = 'src'

def replace_placeholders(content):
    """Replace all placeholders in content"""
    for key, value in config.items():
        placeholder = f'{{{{{key}}}}}'
        content = content.replace(placeholder, value)
    return content

def process_template(input_file, output_file):
    """Process a template file"""
    with open(input_file, 'r') as f:
        content = f.read()
    
    processed = replace_placeholders(content)
    
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    with open(output_file, 'w') as f:
        f.write(processed)
    
    print(f'Created: {output_file}')

def main():
    # Create directories
    dirs = [
        f'{OUTPUT_DIR}/config',
        f'{OUTPUT_DIR}/controllers',
        f'{OUTPUT_DIR}/errors',
        f'{OUTPUT_DIR}/middleware',
        f'{OUTPUT_DIR}/models',
        f'{OUTPUT_DIR}/routes',
        f'{OUTPUT_DIR}/services',
        f'{OUTPUT_DIR}/utils',
        f'{OUTPUT_DIR}/__tests__'
    ]
    
    for dir_path in dirs:
        os.makedirs(dir_path, exist_ok=True)
    
    # Template mappings
    templates = [
        ('route.ts.template', f'routes/{config["ROUTE_NAME"]}.routes.ts'),
        ('service.ts.template', f'services/{config["ROUTE_NAME"]}.service.ts'),
        ('model.ts.template', f'models/{config["ROUTE_NAME"]}.model.ts'),
        ('controller.ts.template', f'controllers/{config["ROUTE_NAME"]}.controller.ts'),
        ('middleware.ts.template', f'middleware/{config["MIDDLEWARE_NAME"]}.middleware.ts'),
        ('service.test.ts.template', f'__tests__/{config["ROUTE_NAME"]}.service.test.ts'),
        ('route.test.ts.template', f'__tests__/{config["ROUTE_NAME"]}.route.test.ts'),
        ('ApiError.ts.template', 'errors/ApiError.ts'),
        ('logger.ts.template', 'utils/logger.ts'),
        ('cache.ts.template', 'utils/cache.ts'),
        ('config.ts.template', 'config/index.ts'),
        ('app.ts.template', 'app.ts'),
        ('index.ts.template', 'index.ts')
    ]
    
    # Process templates
    for input_file, output_file in templates:
        input_path = os.path.join(TEMPLATE_DIR, input_file)
        output_path = os.path.join(OUTPUT_DIR, output_file)
        process_template(input_path, output_path)
    
    # Root files
    root_files = [
        ('package.json.template', 'package.json'),
        ('tsconfig.json.template', 'tsconfig.json'),
        ('.env.template', '.env'),
        ('.eslintrc.json.template', '.eslintrc.json'),
        ('.prettierrc.json.template', '.prettierrc.json'),
        ('.gitignore.template', '.gitignore'),
        ('.dockerignore.template', '.dockerignore'),
        ('Dockerfile.template', 'Dockerfile')
    ]
    
    for input_file, output_file in root_files:
        input_path = os.path.join(TEMPLATE_DIR, input_file)
        process_template(input_path, output_file)
    
    print('\nTemplates processed successfully!')
    print('\nNext steps:')
    print('1. npm install')
    print('2. Update .env with your configuration')
    print('3. npm run dev')

if __name__ == '__main__':
    main()
```

## Manual Replacement Steps

1. **Identify your entity** (e.g., User, Product, Order)
2. **Determine all placeholder values** using the patterns above
3. **Use find-and-replace** in your IDE:
   - Find: `{{SERVICE_NAME}}`
   - Replace: Your service name
   - Apply to all files
4. **Repeat for each placeholder**
5. **Verify replacements** are correct
6. **Test the generated code**

## Common Pitfalls

1. **Case sensitivity**: Ensure proper casing (User vs user vs users)
2. **Plural forms**: ROUTE_NAME should be plural, lowercase
3. **Consistency**: Use the same values across all templates
4. **Field syntax**: Ensure FIELDS uses proper TypeScript syntax
5. **Environment variables**: BACKEND_URL should be SCREAMING_SNAKE_CASE

## Validation Checklist

After replacement, verify:
- [ ] All placeholders replaced (search for `{{` in files)
- [ ] Import statements are correct
- [ ] File names match conventions
- [ ] TypeScript compiles without errors
- [ ] Tests run successfully
- [ ] Environment variables are set
