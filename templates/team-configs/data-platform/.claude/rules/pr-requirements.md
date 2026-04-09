# Pull Request Requirements

## Overview
All pull requests for the data-platform team must meet specific requirements before merging to ensure data integrity, system reliability, and maintainability.

## Required Elements

### 1. Test Coverage (80% Minimum)
All migrations must achieve at least 80% test coverage.

#### What to Test
- Migration execution (up)
- Rollback execution (down)
- Data integrity constraints
- Edge cases and error handling
- Performance with representative data volumes

#### Example Test Structure
```python
def test_migration_m_20260408_001_up():
    """Test user table creation migration."""
    # Execute migration
    alembic.upgrade("m_20260408_001")
    
    # Verify table exists
    assert table_exists("users")
    
    # Verify columns
    assert column_exists("users", "id")
    assert column_exists("users", "email")
    
    # Verify constraints
    assert has_primary_key("users", "id")
    assert has_unique_constraint("users", "email")

def test_migration_m_20260408_001_down():
    """Test user table creation rollback."""
    # Execute migration
    alembic.upgrade("m_20260408_001")
    
    # Rollback
    alembic.downgrade("-1")
    
    # Verify table removed
    assert not table_exists("users")
```

### 2. Schema Validation
All schema changes must pass automated validation.

#### Required Validations
- SQL syntax checking
- Breaking change detection
- Foreign key constraint verification
- Index naming conventions
- Column naming standards

#### Validation Tools
- SQLFluff for linting
- Migra for schema diff
- Custom validation scripts

### 3. Rollback Script
Every migration must include a tested rollback path.

#### Rollback Requirements
- Must restore previous schema state
- Must handle data cleanup (if applicable)
- Must be idempotent
- Must document any data loss scenarios

#### Example Rollback Documentation
```python
def downgrade():
    """
    Rollback user preferences table creation.
    
    Data Impact: ALL data in user_preferences table will be lost
    Rollback Time: ~10 seconds
    Dependencies: None
    Safe: Only safe if no production data exists in this table
    """
    op.drop_table('user_preferences')
```

### 4. Documentation of Data Impact

#### Impact Assessment Template
```markdown
## Data Impact Analysis

### Tables Affected
- `users`: Add email_verified_at column
- `auth_logs`: No changes

### Expected Data Changes
- Existing users: email_verified_at = NULL
- New users: email_verified_at set on first verification

### Data Volume
- Affected rows: ~50,000 user records
- Expected growth: +1 column per row

### Performance Impact
- Migration runtime: ~2 seconds
- Table lock duration: ~100ms
- Downtime required: No

### Rollback Data Loss
- Reverting drops email_verified_at column
- All verification timestamps will be lost
- Mitigation: Backup recommended before migration
```

### 5. Breaking Change Declaration
Explicitly declare any breaking changes.

#### Breaking Change Checklist
- [ ] Column renamed or dropped
- [ ] Table renamed or dropped
- [ ] Data type changed
- [ ] Constraint added that may fail for existing data
- [ ] Foreign key relationship modified
- [ ] Index or unique constraint added

#### Breaking Change Documentation
```markdown
## BREAKING CHANGES

### Column Rename: customer_id → user_id
- **Affected Tables**: orders, order_items, invoices
- **Application Impact**: All queries using customer_id must be updated
- **Required App Version**: v2.5.0 or higher
- **Deployment Strategy**: Blue-green deployment recommended
- **Rollback Risk**: Medium (requires coordinated rollback)

### Migration Steps
1. Deploy application v2.5.0 (supports both column names)
2. Run migration m_20260408_010
3. Verify no errors in application logs
4. Deploy application v2.6.0 (removes old column name support)
```

## PR Description Template

```markdown
## Migration Summary
Brief description of what this migration does.

## Migration Details
- **Migration ID**: m_20260408_001
- **Type**: schema | migration | hotfix
- **Breaking Change**: Yes | No

## Changes
- Added `users` table with email, profile fields
- Created indexes on email and created_at columns
- Added foreign key to auth_providers table

## Data Impact
- **Tables Modified**: users (new), auth_providers (FK added)
- **Affected Rows**: 0 (new table)
- **Estimated Runtime**: ~15 seconds
- **Downtime Required**: No

## Testing
- [x] Unit tests passing (85% coverage)
- [x] Integration tests passing
- [x] Tested on staging environment
- [x] Rollback tested successfully
- [x] Performance validated with sample data (100K records)

## Rollback Plan
```sql
-- Rollback removes users table entirely
DROP TABLE IF EXISTS users CASCADE;
```
- **Data Loss**: All user records (acceptable for new table)
- **Rollback Time**: ~5 seconds

## Schema Validation
- [x] SQLFluff linting passed
- [x] Schema diff generated and reviewed
- [x] No breaking changes to existing tables
- [x] Foreign key constraints validated

## Deployment Notes
- Deploy during maintenance window: No
- Requires application deployment: No
- Coordination required with other teams: No

## Related Issues
Closes #123
Refs #456

## Checklist
- [x] Migration ID follows naming convention
- [x] Commit message follows template
- [x] Tests achieve 80%+ coverage
- [x] Rollback script included and tested
- [x] Data impact documented
- [x] Breaking changes declared (if any)
- [x] Schema validation passed
- [x] Reviewed by data team lead
- [x] Reviewed by backend team member
```

## Review Process

### Required Reviewers
1. **Data Platform Team Member** (mandatory)
2. **Backend Team Member** (mandatory)
3. **Data Engineering Lead** (for breaking changes)
4. **Senior Data Engineer** (for production pipeline changes)

### Review Criteria
- [ ] Migration ID follows convention
- [ ] Tests are comprehensive and passing
- [ ] Rollback script is present and tested
- [ ] Data impact is clearly documented
- [ ] Breaking changes are properly flagged
- [ ] Schema changes follow naming conventions
- [ ] Performance impact is acceptable
- [ ] Security considerations are addressed

## Automated Checks
The following checks must pass before merge:

### CI/CD Pipeline
1. SQL Linting (SQLFluff)
2. Migration Validation
3. Schema Diff Generation
4. Test Coverage (80% minimum)
5. Rollback Testing
6. Security Scanning
7. Data Quality Checks

### GitHub Actions
- All workflow jobs must pass
- No unresolved review comments
- Branch must be up to date with base branch

## Special Cases

### Hotfix PRs
- Can bypass normal review timeline for critical production issues
- Must still include all required elements
- Post-merge review required within 24 hours
- Incident ticket reference required

### Large Migrations
For migrations affecting >1 million rows or requiring >5 minutes:
- [ ] Performance testing on production-scale data
- [ ] Maintenance window scheduled
- [ ] Stakeholder communication completed
- [ ] Monitoring alerts configured
- [ ] Gradual rollout plan (if applicable)

### Data Backfills
- [ ] Backfill strategy documented (batch size, rate limiting)
- [ ] Progress monitoring approach defined
- [ ] Partial rollback strategy available
- [ ] Data validation queries prepared

## Post-Merge Requirements

### Immediate Actions
1. Monitor application logs for errors
2. Check database performance metrics
3. Verify data integrity with validation queries
4. Update deployment runbook

### Within 24 Hours
1. Update team knowledge base
2. Close related issues
3. Post completion summary in team chat
4. Schedule post-mortem (if hotfix)

## Enforcement
- PRs not meeting requirements will be blocked by automation
- Manual override requires approval from data engineering lead
- Repeated violations may result in loss of merge privileges

## Related Documentation
- [Branch Naming Convention](./branch-naming.md)
- [Commit Template](./commit-template.md)
- [Team Guide](/docs/TEAM_GUIDE.md)
