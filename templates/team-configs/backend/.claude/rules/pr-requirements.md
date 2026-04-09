# Backend Team Pull Request Requirements

## Overview

All pull requests must meet these requirements before merging to `main` or `develop` branches.

## Code Quality Requirements

### Test Coverage

**Minimum Coverage: 70%**

- Overall line coverage must be ≥70%
- Branch coverage should be ≥65%
- New code must have ≥80% coverage
- Critical paths (payment, auth) require ≥90% coverage

Coverage is automatically checked by CI/CD pipeline and will fail PRs below threshold.

### Test Types Required

#### 1. Unit Tests (Required)

All new or modified methods must have unit tests:

```java
@Test
@DisplayName("Should calculate order total with tax correctly")
void shouldCalculateOrderTotalWithTax() {
    // Given
    Order order = createOrderWithItems(100.00);
    
    // When
    BigDecimal total = orderService.calculateTotal(order);
    
    // Then
    assertThat(total).isEqualByComparingTo("108.00"); // 8% tax
}
```

**Requirements:**
- Test success and failure paths
- Test edge cases and boundary conditions
- Use descriptive test names
- Follow Arrange-Act-Assert pattern
- Mock external dependencies

#### 2. Integration Tests (Required)

Test interactions between components:

```java
@SpringBootTest
@AutoConfigureMockMvc
class OrderControllerIntegrationTest {
    
    @Test
    void shouldCreateOrderAndUpdateInventory() {
        // Integration test spanning multiple services
    }
}
```

**Requirements:**
- Test critical business workflows
- Test database interactions
- Test API endpoints end-to-end
- Use testcontainers for external dependencies

#### 3. Performance Tests (Conditional)

Required for:
- High-traffic endpoints (>1000 req/min expected)
- Background jobs processing large datasets
- Database-intensive operations

**Performance Criteria:**
- P95 response time <500ms for API endpoints
- P99 response time <1000ms
- Throughput ≥100 req/sec for critical endpoints
- No memory leaks over 10-minute test

**Label PR with `performance` to trigger automated performance testing.**

## API Changes Requirements

### OpenAPI/Swagger Documentation

**All API changes must include updated OpenAPI documentation.**

#### For New Endpoints

```java
@Operation(
    summary = "Create new user profile",
    description = "Creates a new user profile with the provided information",
    tags = {"user"}
)
@ApiResponses(value = {
    @ApiResponse(responseCode = "201", description = "Profile created successfully",
        content = @Content(schema = @Schema(implementation = UserProfile.class))),
    @ApiResponse(responseCode = "400", description = "Invalid input"),
    @ApiResponse(responseCode = "409", description = "Profile already exists")
})
@PostMapping("/api/v1/users/profile")
public ResponseEntity<UserProfile> createProfile(@Valid @RequestBody CreateProfileRequest request) {
    // Implementation
}
```

#### Documentation Requirements

- [ ] Endpoint summary and description
- [ ] Request/response schemas
- [ ] All response codes documented
- [ ] Authentication requirements specified
- [ ] Rate limiting information (if applicable)
- [ ] Example requests/responses
- [ ] Deprecation notices (if applicable)

#### API Versioning

- New endpoints: Use current API version (`/api/v1/...`)
- Breaking changes: Increment version (`/api/v2/...`)
- Deprecation: Mark old version and set sunset date
- Maintain backward compatibility for 2 major versions

### API Review Checklist

- [ ] RESTful design principles followed
- [ ] Consistent naming conventions
- [ ] Proper HTTP methods used
- [ ] Appropriate status codes returned
- [ ] Input validation implemented
- [ ] Error responses standardized
- [ ] Pagination for list endpoints
- [ ] Filtering and sorting options considered
- [ ] HATEOAS links included (if applicable)

## Security Requirements

### Security Checklist

- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (use parameterized queries)
- [ ] XSS prevention (encode outputs)
- [ ] Authentication required for protected endpoints
- [ ] Authorization checks implemented
- [ ] Sensitive data encrypted (passwords, tokens, PII)
- [ ] No secrets in code or configuration
- [ ] HTTPS enforced for production
- [ ] CORS properly configured
- [ ] Rate limiting for public endpoints

### Security Scanning

All PRs automatically run:

- **OWASP Dependency Check**: Scans for vulnerable dependencies
- **Snyk Security**: Checks for known vulnerabilities
- **Trivy**: Scans Docker images for CVEs

**High/Critical vulnerabilities must be resolved before merge.**

### Sensitive Code Review

PRs affecting these areas require security team review:

- Authentication/authorization logic
- Cryptographic operations
- Payment processing
- PII handling
- Database migration scripts
- External API integrations

## Code Style Requirements

### Static Analysis

Must pass without errors:

- **Checkstyle**: Java code style enforcement
- **SpotBugs**: Bug pattern detection
- **SonarQube**: Code quality and security issues

Configure in `pom.xml`:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-checkstyle-plugin</artifactId>
    <configuration>
        <configLocation>checkstyle.xml</configLocation>
        <failOnViolation>true</failOnViolation>
    </configuration>
</plugin>
```

### Code Review Guidelines

Reviewers should check for:

1. **Clarity**: Is the code easy to understand?
2. **Correctness**: Does it solve the problem correctly?
3. **Efficiency**: Are there performance concerns?
4. **Maintainability**: Can others easily modify this?
5. **Testing**: Are tests comprehensive and meaningful?
6. **Documentation**: Are complex parts explained?
7. **Error handling**: Are errors handled gracefully?
8. **Logging**: Is appropriate logging in place?

## PR Description Template

```markdown
## Description

Brief description of what this PR does and why.

## Type of Change

- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to break)
- [ ] Performance improvement
- [ ] Refactoring (no functional changes)
- [ ] Documentation update
- [ ] Dependency update

## Related Issues

Fixes #123
Relates to #456

## Changes Made

- Change 1
- Change 2
- Change 3

## Testing

### Unit Tests
- Describe unit test coverage

### Integration Tests
- Describe integration test scenarios

### Manual Testing
- Steps taken to manually verify changes

### Performance Testing
- Performance test results (if applicable)

## API Changes

### New Endpoints
- `POST /api/v1/resource` - Description

### Modified Endpoints
- `GET /api/v1/resource/:id` - Added new query parameter

### Deprecated Endpoints
- `DELETE /api/v1/old-resource` - Will be removed in v2.0

## Database Changes

- [ ] Migration script included
- [ ] Rollback script tested
- [ ] Impact on existing data documented
- [ ] Indexes added for performance

## Documentation

- [ ] OpenAPI/Swagger docs updated
- [ ] README updated
- [ ] CHANGELOG updated
- [ ] Team guide updated (if process changes)

## Deployment Notes

- Configuration changes required: [list them]
- Environment variables needed: [list them]
- Feature flags used: [list them]
- Rollback plan: [describe it]

## Screenshots/Recordings

[If applicable, add screenshots or recordings]

## Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review of code completed
- [ ] Code commented in complex areas
- [ ] Documentation updated
- [ ] Tests added/updated and passing
- [ ] Coverage threshold met (≥70%)
- [ ] No security vulnerabilities introduced
- [ ] Breaking changes documented
- [ ] Tested locally
- [ ] Ready for review

## Breaking Changes

[If this is a breaking change, describe the impact and migration path]

## Additional Notes

[Any other context, concerns, or notes for reviewers]
```

## Review Process

### Reviewer Responsibilities

1. **Timely reviews**: Respond within 24 business hours
2. **Constructive feedback**: Be specific and helpful
3. **Ask questions**: Seek clarification when needed
4. **Test locally**: For complex changes, pull and test
5. **Approve when ready**: Don't block unnecessarily

### Review Types

#### Standard Review (1 approver)
- Bug fixes
- Minor features
- Refactoring
- Documentation
- Test updates

#### Enhanced Review (2 approvers)
- Breaking changes
- API contract changes
- Database migrations
- Security-sensitive code
- Performance-critical code

### Approval Criteria

PRs can be merged when:

- [ ] All required approvals received
- [ ] All CI/CD checks passing
- [ ] Code coverage threshold met
- [ ] No unresolved conversations
- [ ] Security scans passing
- [ ] Branch up to date with base

## High-Traffic Endpoint Guidelines

For endpoints expected to handle >1000 req/min:

### Performance Requirements

- [ ] Response time P95 <500ms
- [ ] Response time P99 <1000ms
- [ ] Load tested at 2x expected traffic
- [ ] Database queries optimized (use EXPLAIN)
- [ ] Appropriate caching strategy
- [ ] Connection pooling configured
- [ ] Circuit breakers implemented
- [ ] Bulkhead pattern for isolation

### Testing Requirements

```java
@Test
@Tag("performance")
void shouldHandleHighLoadWithinThresholds() {
    // JMeter or Gatling test
    LoadTestResult result = loadTestRunner.run(
        endpoint = "/api/v1/orders",
        duration = Duration.ofMinutes(10),
        rps = 2000
    );
    
    assertThat(result.getP95ResponseTime())
        .isLessThan(Duration.ofMillis(500));
    assertThat(result.getErrorRate())
        .isLessThan(0.01); // <1% errors
}
```

### Monitoring Requirements

- [ ] Metrics exposed (Prometheus/Micrometer)
- [ ] Alerting configured
- [ ] Logging appropriate (not excessive)
- [ ] Distributed tracing added
- [ ] SLO/SLA defined

## Database Changes

### Migration Requirements

- [ ] Flyway/Liquibase script included
- [ ] Idempotent (can run multiple times safely)
- [ ] Tested on production-like dataset
- [ ] Rollback script provided
- [ ] Performance impact assessed
- [ ] Downtime requirements documented

### Schema Change Checklist

- [ ] Backward compatible (if possible)
- [ ] Indexes added for foreign keys
- [ ] Constraints validated
- [ ] Default values provided
- [ ] NULL handling considered
- [ ] Data migration tested

## Related Documentation

- [Branch Naming Convention](./branch-naming.md)
- [Commit Message Template](./commit-template.md)
- [Team Guide](/docs/TEAM_GUIDE.md)
- [API Design Guidelines](/docs/TEAM_GUIDE.md#api-design)
- [Testing Strategy](/docs/TEAM_GUIDE.md#testing-strategy)
