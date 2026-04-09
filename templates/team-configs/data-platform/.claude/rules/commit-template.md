# Commit Message Template

## Overview
Standardized commit messages help track changes, generate changelogs, and understand the evolution of database schemas and migrations.

## Format
```
<type>(migration-id): <description>

[optional body]

[optional footer]
```

## Commit Types

### schema
Schema definition changes (DDL operations)
```
schema(m_20260408_001): add users table with email index
schema(m_20260408_002): add created_at column to orders
```

### migration
Data migration or transformation logic
```
migration(m_20260408_003): backfill user preferences from legacy system
migration(m_20260408_004): deduplicate customer records
```

### hotfix
Urgent production fixes
```
hotfix(m_20260408_005): fix null pointer in user query
hotfix(m_20260408_006): correct revenue calculation in reports
```

### rollback
Reverting previous migrations
```
rollback(m_20260408_003): revert user preferences backfill
```

### docs
Documentation updates only
```
docs: update migration runbook for v2.3.0
docs: add troubleshooting guide for schema validation
```

### test
Test additions or modifications
```
test(m_20260408_001): add integration tests for user table migration
test: improve coverage for rollback scenarios
```

## Migration ID Format
- Pattern: `m_YYYYMMDD_NNN`
- `YYYYMMDD`: Date of migration creation
- `NNN`: Sequential number (001, 002, etc.)

### Examples
```
m_20260408_001  → First migration on April 8, 2026
m_20260408_002  → Second migration on April 8, 2026
m_20260409_001  → First migration on April 9, 2026
```

## Description Guidelines
- Use imperative mood ("add" not "added" or "adds")
- Start with lowercase
- No period at the end
- Maximum 72 characters
- Be specific about what changed

### Good Examples
```
schema(m_20260408_001): add users table with email and profile fields
migration(m_20260408_002): backfill email verification status for existing users
hotfix(m_20260408_003): fix deadlock in concurrent order processing
```

### Bad Examples
```
schema(m_20260408_001): Added stuff  (vague, wrong tense)
migration: backfill data  (missing migration ID)
schema(m_20260408_001): This commit adds a new users table with email, profile, preferences, and metadata fields and also includes several indexes  (too long)
```

## Optional Body
Use the body to provide context and details:
```
schema(m_20260408_001): add users table with authentication fields

This migration creates the core users table with support for:
- Email-based authentication
- OAuth provider integration
- Profile metadata storage
- Soft delete functionality

Migration ID: m_20260408_001
Estimated runtime: ~30 seconds on production
Rollback available: yes
```

## Breaking Change Footer
Mark breaking changes with a `BREAKING CHANGE:` footer:
```
schema(m_20260408_010): rename customer_id to user_id in orders table

This migration renames the customer_id column to user_id for consistency
across all tables. All dependent queries and services must be updated.

BREAKING CHANGE: customer_id column renamed to user_id
Affects: orders, order_items, invoices tables
Requires: application deployment v2.5.0+
```

### Breaking Change Examples
- Renaming columns or tables
- Changing data types
- Dropping columns or tables
- Modifying constraints that affect application logic
- Changing foreign key relationships

## Footer Format
Additional metadata can be included:
```
schema(m_20260408_001): add users table with authentication fields

Migration-ID: m_20260408_001
Runtime: ~30s
Rollback: yes
Reviewed-by: @senior-data-engineer
Tested-on: staging, 2026-04-07
Refs: #234, #235
Fixes: #456
```

## Examples by Scenario

### New Table Creation
```
schema(m_20260408_001): add products table with inventory tracking

Creates products table with:
- SKU, name, description fields
- Inventory quantity and location
- Price history tracking
- Soft delete support

Migration-ID: m_20260408_001
Runtime: ~15s
Rollback: yes
```

### Column Addition
```
schema(m_20260408_002): add email_verified_at to users table

Adds nullable timestamp column to track email verification.
Existing records will have NULL values (unverified).

Migration-ID: m_20260408_002
Runtime: ~2s
Rollback: yes
```

### Data Backfill
```
migration(m_20260408_003): backfill email verification status

Analyzes login history to determine verification status for
existing users without email_verified_at timestamp.

Migration-ID: m_20260408_003
Runtime: ~5 minutes (estimated)
Rollback: partial (sets all to NULL)
Data-Impact: 50,000 user records
```

### Breaking Schema Change
```
schema(m_20260408_010): change user_id from integer to uuid

Updates user_id column from integer to UUID across all tables.
This is a multi-phase migration requiring application updates.

BREAKING CHANGE: user_id type changed from integer to UUID
Migration-ID: m_20260408_010
Runtime: ~20 minutes (estimated)
Rollback: yes (with data loss for new records)
Requires: application v3.0.0+
Coordinated-Deploy: yes
```

### Hotfix
```
hotfix(m_20260408_005): add missing index on orders.created_at

Query performance degraded due to missing index on orders table.
This hotfix adds the index to resolve production slowness.

Migration-ID: m_20260408_005
Runtime: ~3 minutes (concurrent index creation)
Rollback: yes
Impact: reduces query time from 15s to 50ms
Incident: INC-2026-0408-001
```

## Validation
Commit messages are validated by:
- Pre-commit Git hooks
- GitHub Actions workflow
- PR title checks

Invalid commit messages will be rejected automatically.

## Related Documentation
- [Branch Naming Convention](./branch-naming.md)
- [PR Requirements](./pr-requirements.md)
- [Team Guide](/docs/TEAM_GUIDE.md)
