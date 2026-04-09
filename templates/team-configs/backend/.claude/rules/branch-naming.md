# Backend Team Branch Naming Convention

## Pattern

All branches must follow this pattern:

```
<type>/<service>/<description>
```

### Components

1. **Type** (required): The nature of the work
2. **Service** (required): The microservice being modified
3. **Description** (required): Brief description using kebab-case

## Branch Types

### feature
New functionality or feature additions.

**Examples:**
- `feature/user/add-profile-api`
- `feature/auth/implement-oauth2-provider`
- `feature/order/add-bulk-processing`

### fix
Bug fixes and issue resolutions.

**Examples:**
- `fix/payment/handle-timeout-retry`
- `fix/notification/email-template-encoding`
- `fix/user/null-pointer-in-validation`

### refactor
Code improvements without changing functionality.

**Examples:**
- `refactor/order/extract-pricing-service`
- `refactor/auth/simplify-token-validation`
- `refactor/notification/consolidate-senders`

### perf
Performance improvements and optimizations.

**Examples:**
- `perf/user/optimize-search-query`
- `perf/order/add-database-indexes`
- `perf/payment/reduce-api-calls`

## Service Names

Use the canonical service name for the microservice you're modifying:

- **user** - User profile and account management
- **auth** - Authentication and authorization
- **order** - Order management and processing
- **payment** - Payment processing and transactions
- **notification** - Email, SMS, and push notifications
- **inventory** - Inventory tracking and management
- **catalog** - Product catalog service
- **shipping** - Shipping and fulfillment
- **reporting** - Analytics and reporting
- **admin** - Administrative functions

For work spanning multiple services, use the primary service affected.

## Description Guidelines

- Use kebab-case (lowercase with hyphens)
- Keep it concise but descriptive (3-6 words)
- Focus on WHAT, not HOW
- Avoid issue numbers (those go in commits)

### Good Examples

```
feature/user/add-profile-api
fix/payment/handle-timeout-retry
refactor/order/extract-pricing-service
perf/notification/batch-email-sending
```

### Bad Examples

```
feature/user/issue-123              ❌ Don't include issue numbers
fix/payment/fix_bug                 ❌ Not descriptive enough
feature/user/AddNewProfileAPI       ❌ Use kebab-case, not PascalCase
refactor/OrderServiceRefactoring    ❌ Missing service name format
perf/improve-performance            ❌ Missing service name
```

## Special Cases

### Hotfix Branches

For production hotfixes, use:

```
hotfix/<service>/<description>
```

Example: `hotfix/payment/critical-transaction-bug`

### Release Branches

For release preparation:

```
release/<version>
```

Example: `release/v2.3.0`

### Cross-Service Changes

If your work affects multiple services significantly, use the most impacted service and mention others in the PR description.

Example: `feature/order/add-payment-webhook` (even though it touches payment service)

## Validation

Branch names are validated automatically:
- By Git hooks (pre-push)
- By CI/CD pipeline
- By PR automation

Invalid branch names will be rejected with guidance on the correct format.

## Tips

1. Create your branch early to establish the name
2. If unsure about the service name, check the repository structure
3. Keep descriptions focused on the business value or technical goal
4. When in doubt, ask in the team channel before pushing

## Related Documentation

- [Commit Message Template](./commit-template.md)
- [PR Requirements](./pr-requirements.md)
- [Team Guide](/docs/TEAM_GUIDE.md)
