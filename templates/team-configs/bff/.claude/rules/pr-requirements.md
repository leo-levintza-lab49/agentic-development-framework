# BFF Team Pull Request Requirements

## Overview

All pull requests must meet these requirements before merging. Automated checks enforce most requirements, but reviewers verify quality and completeness.

## Code Quality Requirements

### 1. Test Coverage: 75% Minimum

All PRs must maintain or improve test coverage:
- **Overall coverage**: 75% minimum
- **New code**: 85% minimum coverage
- **Critical paths**: 100% coverage required
  - Authentication and authorization
  - Payment processing
  - Order management
  - Data validation

#### Coverage Requirements by Type

**Unit Tests**
- All business logic functions
- Utility functions and helpers
- Data transformation logic
- Validation rules

**Integration Tests**
- API endpoint flows
- Backend service interactions
- Database operations
- Cache behavior
- Error handling scenarios

**Contract Tests**
- API response schemas
- GraphQL types and resolvers
- Client request/response formats
- Backend service contracts

### 2. Integration Tests with Backend Services

Required for changes affecting backend communication:
- Mock backend responses for development
- Verify request/response formats
- Test error handling and timeouts
- Validate retry logic
- Check circuit breaker behavior

#### Example Checklist
```
- [ ] Tests for successful backend responses
- [ ] Tests for backend error responses (4xx, 5xx)
- [ ] Tests for backend timeout scenarios
- [ ] Tests for network failures
- [ ] Tests for malformed backend responses
- [ ] Verified retry and backoff logic
```

### 3. API Contract Tests

Required for all client-facing changes:
- Use Pact or similar contract testing
- Define consumer expectations
- Validate provider compliance
- Version contract tests with API changes

#### Required Scenarios
- Request validation (required fields, types, formats)
- Response structure validation
- Error response formats
- Authentication and authorization flows
- Pagination and filtering

### 4. Response Time Requirements

Performance tests must validate SLAs:

**Target Response Times (95th percentile)**
- Simple GET requests: < 100ms
- Complex queries: < 300ms
- GraphQL queries: < 400ms
- POST/PUT operations: < 500ms
- Payment operations: < 1000ms

**Load Testing Requirements**
For significant changes, include:
- Baseline performance metrics
- Load test results (100 concurrent users minimum)
- Memory usage analysis
- CPU utilization metrics

## Code Review Standards

### Required Reviewers
- **1 reviewer**: Standard changes
- **2 reviewers**: Client-breaking changes
- **Security team**: Auth, payments, PII handling
- **Frontend team**: Route or schema changes

### Review Checklist

#### Architecture and Design
- [ ] Follows BFF pattern guidelines
- [ ] Appropriate separation of concerns
- [ ] No business logic in routes (belongs in services)
- [ ] Proper error handling strategy
- [ ] Considers scalability implications

#### Code Quality
- [ ] TypeScript types are precise and accurate
- [ ] No `any` types (use `unknown` if necessary)
- [ ] Functions are focused and single-purpose
- [ ] Code is self-documenting with clear names
- [ ] Comments explain "why" not "what"

#### Security
- [ ] Input validation on all endpoints
- [ ] Authentication checked where required
- [ ] Authorization enforced properly
- [ ] No sensitive data in logs
- [ ] Rate limiting considered for public endpoints

#### Error Handling
- [ ] All errors properly caught and handled
- [ ] Appropriate error messages for clients
- [ ] No internal details leaked in error responses
- [ ] Backend errors transformed appropriately
- [ ] Error logging includes context

#### Performance
- [ ] No N+1 queries (use DataLoader)
- [ ] Appropriate caching strategy
- [ ] Database queries optimized
- [ ] Large payloads paginated
- [ ] Response compression enabled

## PR Description Template

Use this template for all PRs:

```markdown
## Description
Brief overview of changes and why they're needed.

## Type of Change
- [ ] Feature (new functionality)
- [ ] Fix (bug fix)
- [ ] Refactor (code improvement, no behavior change)
- [ ] Performance (optimization)
- [ ] Breaking change (requires client updates)

## Platform Impact
- [ ] Web
- [ ] Mobile
- [ ] GraphQL
- [ ] Shared/All platforms

## Changes Made
- Bullet point list of specific changes
- Focus on what and why, not how

## Testing
### Test Coverage
- Overall: X%
- New code: Y%
- Critical paths: 100%

### Tests Added
- [ ] Unit tests
- [ ] Integration tests
- [ ] Contract tests
- [ ] Performance tests

### Manual Testing
Steps to manually verify changes:
1. Step one
2. Step two
3. Expected result

## Performance Impact
- Response time: Xms (baseline: Yms)
- Load test: Z concurrent users
- Memory usage: +/-X MB

## Breaking Changes
If applicable, describe:
- What's breaking
- Why the change is necessary
- Migration path for clients
- Timeline for deprecation

## Backend Dependencies
If applicable:
- Required backend service versions
- New API endpoints used
- Changed contracts

## Rollback Plan
How to safely rollback if issues arise:
1. Step one
2. Step two

## Screenshots/Videos
For UI-facing changes, include evidence.

## Documentation
- [ ] API documentation updated
- [ ] TypeScript types updated
- [ ] README updated if needed
- [ ] Deployment guide updated if needed

## Checklist
- [ ] Code follows team style guidelines
- [ ] Tests pass locally and in CI
- [ ] Coverage meets minimum requirements
- [ ] No console.log or debug code
- [ ] Secrets not committed
- [ ] PR title follows commit convention
- [ ] Branch name follows convention
```

## Automated Checks

All PRs must pass:

### CI Pipeline
- ✅ ESLint (no errors, warnings reviewed)
- ✅ Prettier formatting
- ✅ TypeScript type checking (strict mode)
- ✅ Unit tests (all passing)
- ✅ Integration tests (all passing)
- ✅ Contract tests (all passing)
- ✅ Coverage threshold (75% minimum)
- ✅ Performance tests (within SLAs)
- ✅ Security scan (no high/critical vulnerabilities)
- ✅ Dependency check (no known vulnerabilities)

### Git Checks
- ✅ Branch name follows convention
- ✅ Commit messages follow template
- ✅ No merge commits (rebase only)
- ✅ CODEOWNERS approval obtained

## Breaking Changes Process

For client-breaking changes:

### 1. Announcement Phase (T-2 weeks)
- Create breaking change announcement
- Notify frontend team and stakeholders
- Document migration path
- Update API changelog

### 2. Deprecation Phase (T-1 week)
- Mark old endpoint/field as deprecated
- Add deprecation warnings in responses
- Ensure both old and new versions work

### 3. Migration Phase (Release)
- Deploy new version
- Monitor client migrations
- Support clients during transition

### 4. Cleanup Phase (T+2 weeks)
- Remove deprecated code
- Update documentation
- Announce completion

## GraphQL Schema Changes

Special requirements for schema modifications:

### Additive Changes (Safe)
- Adding new fields: No approval needed beyond standard review
- Adding new types: Include in PR description
- Adding new queries/mutations: Requires integration tests

### Breaking Changes (Requires Approval)
- Removing fields: Requires frontend team approval + deprecation period
- Changing field types: Requires frontend team approval
- Renaming fields: Requires frontend team approval + migration plan
- Changing nullability: Requires careful review and client testing

### Schema Review Checklist
- [ ] Schema changes documented in PR description
- [ ] Breaking changes announced in advance
- [ ] Deprecation warnings added where applicable
- [ ] Frontend team notified and approved
- [ ] Contract tests updated
- [ ] TypeScript types regenerated
- [ ] Schema documentation updated

## Response Time Validation

Performance tests automatically validate:

### Measurement Criteria
- Tests run against production-like environment
- Minimum 100 concurrent users
- 5-minute duration test
- 95th percentile (p95) measured
- 99th percentile (p99) recorded for reference

### Failure Thresholds
- p95 > 2x target: ❌ Must fix before merge
- p95 > 1.5x target: ⚠️ Requires justification
- p95 > 1.2x target: 💡 Consider optimization

### Performance Regression
If PR increases response times:
- Explain why in PR description
- Provide justification (e.g., feature complexity)
- Propose optimization plan if applicable
- Get explicit approval from tech lead

## Merge Requirements Summary

Before merging, ensure:
- ✅ All CI checks passing
- ✅ 75%+ test coverage maintained
- ✅ Integration tests with backend services
- ✅ API contract tests passing
- ✅ Response times within SLA
- ✅ Required reviewers approved
- ✅ No unresolved review comments
- ✅ PR description complete
- ✅ Documentation updated
- ✅ Breaking changes properly handled

## Post-Merge

After merging:
1. Monitor error rates and performance metrics
2. Verify deployment to staging/production
3. Update related documentation
4. Notify affected teams if needed
5. Close related issues
6. Delete feature branch

## Questions?

Contact:
- BFF team lead: @bff-lead
- Architecture questions: @architecture-team
- Security concerns: @security-team
- Performance issues: @platform-team
