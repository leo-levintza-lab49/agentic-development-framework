# Backend Team Commit Message Template

## Format

```
<type>(service): <subject>

<body>

<footer>
```

## Components

### Type (required)

The nature of the change:

- **feat**: New feature or functionality
- **fix**: Bug fix
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding or updating tests
- **docs**: Documentation changes
- **style**: Code style changes (formatting, semicolons, etc.)
- **chore**: Build process, dependencies, or tooling changes
- **revert**: Reverting a previous commit

### Service (required)

The microservice affected (same as branch naming):
- `user`, `auth`, `order`, `payment`, `notification`, `inventory`, `catalog`, `shipping`, `reporting`, `admin`

### Subject (required)

- 50 characters or less
- Imperative mood ("add", not "added" or "adds")
- No period at the end
- Capitalize first letter

### Body (optional but recommended)

- Wrap at 72 characters
- Explain WHAT and WHY, not HOW
- Separate from subject with blank line
- Use bullet points for multiple items

### Footer (optional)

- Reference issues: `Fixes #123`, `Closes #456`, `Relates to #789`
- Breaking changes: `BREAKING CHANGE: description`
- Co-authors: `Co-authored-by: Name <email>`

## Examples

### Simple Feature

```
feat(user): add profile picture upload endpoint

Implements new REST endpoint for uploading user profile pictures.
Supports JPEG, PNG, and WebP formats up to 5MB.

Fixes #234
```

### Bug Fix

```
fix(payment): handle timeout during transaction processing

- Add retry logic with exponential backoff
- Implement circuit breaker pattern for payment gateway
- Log all retry attempts for debugging

Previously, timeouts would cause transactions to fail without retry,
leading to poor user experience and lost revenue.

Fixes #456
Relates to #445
```

### Performance Improvement

```
perf(order): optimize bulk order query with database indexes

Add composite indexes on (user_id, created_at) and (status, updated_at)
to improve query performance for order history and status filtering.

Reduces average query time from 2.3s to 180ms for users with 1000+ orders.

Performance testing shows:
- 92% reduction in query time
- 75% reduction in database CPU usage
- Handles 3x concurrent requests without degradation

Closes #567
```

### Breaking Change

```
feat(auth): migrate to JWT from session-based auth

BREAKING CHANGE: Authentication mechanism has changed from server-side
sessions to JWT tokens. Clients must update to include Authorization
header with Bearer token instead of relying on cookies.

Migration guide:
1. Update client to request JWT from /api/v2/auth/login
2. Store token securely (httpOnly cookie or secure storage)
3. Include "Authorization: Bearer <token>" in all API requests
4. Handle 401 responses and refresh token flow

Old session endpoints (/api/v1/auth/*) will be deprecated on 2026-06-01
and removed on 2026-09-01.

Fixes #789
```

### Refactoring

```
refactor(order): extract pricing calculation into service

- Move pricing logic from OrderController to PricingService
- Add unit tests for pricing calculations
- Improve testability and separation of concerns

No functional changes. All existing tests pass.
```

### Multi-Service Change

```
feat(order): integrate with payment service for async processing

- Add message queue integration between order and payment services
- Implement event-driven order status updates
- Add retry and dead-letter queue handling

This change affects both order and payment services but is primarily
an order service enhancement. Payment service changes are minimal
(new webhook endpoint).

Fixes #891
Related to polybase-poc/payment-service#45
```

### Revert

```
revert: feat(notification): add SMS notification support

This reverts commit abc123def456.

SMS provider integration is causing production issues with international
numbers. Reverting to investigate and reimplement with proper validation.

Fixes #923
```

## Breaking Change Guidelines

Use `BREAKING CHANGE:` in the footer when:

1. API contract changes (endpoints, request/response format)
2. Database schema changes requiring migration
3. Configuration changes requiring deployment updates
4. Behavior changes that could affect clients
5. Dependency updates with incompatible changes

Always include:
- What changed
- Why it changed
- Migration steps
- Timeline for deprecation (if applicable)

## Issue References

### Linking Issues

- `Fixes #123` - Closes the issue when merged
- `Closes #123` - Same as Fixes
- `Resolves #123` - Same as Fixes
- `Relates to #123` - Links but doesn't close
- `Refs #123` - Short for references

### Cross-Repository References

For referencing issues in other repositories:

```
Fixes polybase-poc/payment-service#45
Relates to polybase-poc/user-service#67
```

## Tips for Good Commit Messages

1. **Write for humans**: Your team will read this in 6 months
2. **Explain context**: Why was this change needed?
3. **Reference issues**: Link to discussions and requirements
4. **Be specific**: "fix validation" → "fix email validation regex for international domains"
5. **One logical change per commit**: Makes reverting easier
6. **Test before committing**: Ensure all tests pass

## Commit Message Checklist

Before committing, verify:

- [ ] Type and service are correct
- [ ] Subject is imperative mood and under 50 chars
- [ ] Body explains WHY (if non-trivial change)
- [ ] Issue references are included
- [ ] Breaking changes are clearly marked
- [ ] All tests pass
- [ ] Code follows style guidelines

## Git Hook Validation

Commit messages are validated by git hooks:

- Subject line length (≤50 chars)
- Type and service format
- Breaking change detection
- Issue reference format

Invalid commits will be rejected with specific error messages.

## Related Documentation

- [Branch Naming Convention](./branch-naming.md)
- [PR Requirements](./pr-requirements.md)
- [Team Guide](/docs/TEAM_GUIDE.md)
