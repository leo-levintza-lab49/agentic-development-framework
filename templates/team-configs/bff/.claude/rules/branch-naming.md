# BFF Team Branch Naming Conventions

## Standard Pattern

All branches must follow this format:

```
<type>/<platform>/<description>
```

### Examples
- `feature/web/search-endpoint`
- `fix/mobile/auth-token-refresh`
- `refactor/graphql/user-resolver`
- `feature/web/checkout-flow`
- `fix/mobile/navigation-crash`

## Branch Types

### `feature/`
New functionality or enhancements
- Adding new API endpoints
- Implementing new GraphQL resolvers
- Adding new middleware or services
- Integrating with new backend services

### `fix/`
Bug fixes and corrections
- Fixing broken endpoints
- Correcting data transformation logic
- Resolving performance issues
- Fixing error handling

### `refactor/`
Code improvements without changing functionality
- Restructuring middleware
- Optimizing resolver logic
- Improving type definitions
- Cleaning up service layers

### `perf/`
Performance optimizations
- Query optimization
- Caching improvements
- Response time reduction
- Memory usage optimization

### `security/`
Security-related changes
- Authentication improvements
- Authorization fixes
- Input validation enhancements
- Security vulnerability patches

## Platform Identifiers

### `web/`
Changes specific to web client routes and endpoints
- REST API endpoints for web
- Web-specific data transformations
- Web client optimizations

### `mobile/`
Changes specific to mobile client routes and endpoints
- Mobile-optimized endpoints
- Mobile-specific response formats
- App-specific features

### `graphql/`
GraphQL-related changes
- Schema modifications
- Resolver implementations
- Query/mutation optimizations
- Subscription handlers

### `shared/`
Changes affecting multiple platforms
- Shared middleware
- Common utilities
- Cross-platform features
- Shared type definitions

## Description Guidelines

Keep descriptions:
- **Short**: 3-5 words maximum
- **Lowercase**: Use kebab-case
- **Descriptive**: Clear about what changes
- **Specific**: Avoid generic terms like "update" or "changes"

### Good Examples
- `user-profile-endpoint`
- `payment-processing-flow`
- `auth-token-validation`
- `product-search-optimization`

### Bad Examples
- `updates` (too vague)
- `fix-stuff` (not specific)
- `NEW_FEATURE` (wrong case)
- `implement-the-new-user-registration-flow-with-email-verification` (too long)

## Special Cases

### Hotfixes
For urgent production fixes:
```
hotfix/platform/critical-issue
```
Example: `hotfix/web/payment-timeout`

### Dependency Updates
For updating packages:
```
deps/platform/package-name
```
Example: `deps/shared/express-upgrade`

### Documentation
For documentation-only changes:
```
docs/area/topic
```
Example: `docs/api/authentication-guide`

## Branch Lifecycle

1. **Create**: Always branch from `develop` (or `main` for hotfixes)
2. **Work**: Keep branches focused on single features/fixes
3. **Update**: Regularly rebase with `develop` to avoid conflicts
4. **Review**: Create PR when ready (see pr-requirements.md)
5. **Merge**: Squash merge to `develop`, fast-forward to `main`
6. **Delete**: Remove branch after merge

## Validation

Branch names are automatically validated by:
- Pre-push Git hooks
- GitHub Actions CI pipeline
- PR title validation

Invalid branch names will cause the pipeline to fail.

## Protected Branches

These branches have special rules and restrictions:
- `main`: Production code, requires 2 approvals
- `develop`: Integration branch, requires 1 approval
- `staging`: Pre-production testing

Never commit directly to protected branches.
