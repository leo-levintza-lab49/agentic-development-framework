# BFF Team Commit Message Template

## Standard Format

```
<type>(platform): <description>

[optional body]

[optional footer]
```

## Commit Types

### `feat` - New Feature
Adding new functionality
```
feat(web): add user search endpoint with fuzzy matching
feat(mobile): implement push notification preferences
feat(graphql): add subscription for real-time order updates
```

### `fix` - Bug Fix
Fixing existing functionality
```
fix(web): prevent race condition in checkout flow
fix(mobile): correct token refresh timing issue
fix(graphql): resolve N+1 query in user resolver
```

### `refactor` - Code Refactoring
Restructuring without changing behavior
```
refactor(shared): extract auth middleware to separate module
refactor(graphql): simplify resolver error handling
refactor(web): consolidate validation logic
```

### `perf` - Performance Improvement
Optimizing code performance
```
perf(web): add Redis caching for product catalog
perf(graphql): implement DataLoader for batch queries
perf(mobile): reduce payload size for list endpoints
```

### `test` - Testing
Adding or updating tests
```
test(web): add integration tests for payment flow
test(graphql): increase resolver test coverage to 85%
test(shared): add contract tests with backend services
```

### `docs` - Documentation
Documentation changes
```
docs(api): update authentication flow diagrams
docs(graphql): add schema documentation
docs(deployment): update deployment runbook
```

### `chore` - Maintenance
Build, dependencies, configuration
```
chore(deps): upgrade express to 4.19.0
chore(config): update TypeScript strict mode settings
chore(ci): optimize Docker build caching
```

### `security` - Security
Security-related changes
```
security(auth): implement rate limiting on login endpoint
security(validation): add input sanitization middleware
security(deps): patch vulnerable axios version
```

## Platform Scope

Always specify the platform affected:
- `(web)` - Web client routes/endpoints
- `(mobile)` - Mobile client routes/endpoints
- `(graphql)` - GraphQL layer
- `(shared)` - Cross-platform code
- `(api)` - General API changes
- `(config)` - Configuration
- `(ci)` - CI/CD pipeline

## Description Guidelines

The description should:
- Use imperative mood ("add" not "added" or "adds")
- Start with lowercase
- No period at the end
- Be concise (50 characters max)
- Clearly state what changed

### Good Examples
```
feat(web): add pagination to product search endpoint
fix(mobile): prevent duplicate order submissions
refactor(graphql): extract common resolver utilities
```

### Bad Examples
```
feat(web): Added new feature for products.  (wrong tense, period)
fix: fixed a bug (missing platform, too vague)
Update stuff (missing type, not imperative, too vague)
```

## Optional Body

Use the body to explain:
- **Why** the change was made
- **What** problem it solves
- **How** it addresses the issue
- Any important implementation details

Wrap lines at 72 characters.

### Example with Body
```
fix(web): prevent race condition in checkout flow

When multiple checkout requests arrived simultaneously, the inventory
check could pass for both, leading to overselling. Added Redis-based
distributed locking to ensure only one checkout processes at a time
per user session.

- Implemented RedLock algorithm for distributed locks
- Added 5-second timeout for lock acquisition
- Added metrics for lock contention monitoring
```

## Optional Footer

Use footer for:

### Breaking Changes
```
BREAKING CHANGE: authentication now requires API version header

All API requests must include 'X-API-Version: 2.0' header.
Clients using v1 endpoints will receive 410 Gone responses.

Migration guide: docs/migration/v1-to-v2.md
```

### Issue References
```
Closes #234
Fixes #567, #890
Related to #123
```

### Backend Service Dependencies
```
Depends-on: user-service@v2.3.0
Requires: payment-service commit abc123
```

### Reviewers for Sensitive Changes
```
Needs-review-by: @security-team
CC: @backend-team
```

## Client-Breaking Change Flags

When making changes that affect client applications, use these flags:

### `[BREAKING]` - Client Breaking Change
Requires client updates
```
feat(web)!: [BREAKING] change user response format to nested structure

BREAKING CHANGE: User API response structure has changed
- Old: { id, name, email, city, country }
- New: { id, name, email, address: { city, country } }

Affects: All web clients using /api/users endpoints
Migration: Update TypeScript interfaces and response handlers
Timeline: Deploy to production 2026-04-15
```

### `[DEPRECATION]` - Deprecating Endpoint
Announcing future removal
```
feat(mobile): [DEPRECATION] add v2 authentication endpoint

The v1 /auth/login endpoint is now deprecated in favor of /v2/auth/login.
v1 will be removed on 2026-07-01.

New endpoint includes refresh token rotation and improved security.
```

### `[SCHEMA]` - GraphQL Schema Change
Schema modifications
```
feat(graphql): [SCHEMA] add orderStatus field to Order type

Added orderStatus: OrderStatus! field for real-time order tracking.
Clients should update their fragments to include this field.
```

## Backend Service Dependencies

Flag changes requiring backend service updates:

```
feat(web): add advanced product filtering

Depends-on: product-service@v3.5.0
Requires: New filter API endpoint /api/v1/products/filter

This feature requires product-service v3.5.0 or later which introduces
the advanced filtering API. Deploy product-service update first.

Deployment order:
1. Deploy product-service v3.5.0
2. Deploy BFF with this commit
3. Update web client

Rollback plan: docs/rollback/advanced-filtering.md
```

## Examples

### Feature with Breaking Change
```
feat(web)!: [BREAKING] migrate to versioned API responses

BREAKING CHANGE: All responses now include apiVersion field

All API responses now include { apiVersion: "2.0", data: {...} } wrapper.
This ensures clients can handle multiple API versions gracefully.

- Updated all route handlers
- Added response wrapper middleware
- Updated TypeScript response types

Closes #456
Depends-on: client-sdk@v2.0.0
```

### Bug Fix with Context
```
fix(mobile): prevent duplicate order submissions

Users could submit orders multiple times by rapidly tapping the
checkout button. Implemented idempotency keys and client-side debouncing.

- Added idempotency middleware using request IDs
- Store processed requests in Redis for 5 minutes
- Return cached response for duplicate requests

Fixes #789
```

### Refactoring with Justification
```
refactor(graphql): extract data loader utilities

Resolvers were duplicating DataLoader setup code. Extracted to shared
utility module for consistency and maintainability.

- Created dataLoaderFactory helper
- Standardized cache key generation
- Added TypeScript generics for type safety

No functional changes.
```

### Performance Optimization
```
perf(web): implement response caching for product catalog

Product catalog API was slow under load. Added Redis caching with
smart invalidation.

- Cache duration: 5 minutes
- Invalidate on product updates via event bus
- Added cache hit/miss metrics
- Reduced p95 response time from 450ms to 45ms

Closes #345
```

## Validation

Commit messages are validated by:
- Git pre-commit hooks (commitlint)
- CI pipeline checks
- Automated PR title synchronization

Invalid commits will be rejected.

## Tools

### Commitizen
Use interactive commit message builder:
```bash
npm run commit
```

### Conventional Commits
We follow the Conventional Commits specification:
https://www.conventionalcommits.org/
