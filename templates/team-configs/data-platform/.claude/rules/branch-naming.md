# Branch Naming Convention

## Overview
The data-platform team follows a structured branch naming convention to maintain clarity and enable automated workflows.

## Format
```
<type>/<version>/<description>
```

## Branch Types

### schema
Used for schema changes, new tables, column modifications, or index additions.
```
schema/v2.3.0/add-user-table
schema/v3.0.0/rename-customer-id-column
schema/v2.4.1/add-email-index
```

### migration
Used for data migrations, backfills, or data transformations.
```
migration/v1.5.0/backfill-user-preferences
migration/v2.0.0/migrate-legacy-orders
migration/v1.6.2/update-product-categories
```

### hotfix
Used for urgent production fixes that require immediate deployment.
```
hotfix/v2.3.1/fix-null-pointer-user-query
hotfix/v1.8.3/correct-revenue-calculation
```

## Version Format
Follow semantic versioning: `vX.Y.Z`

- **X (Major)**: Breaking changes, major schema refactoring, or backwards-incompatible migrations
- **Y (Minor)**: New features, additive schema changes, non-breaking migrations
- **Z (Patch)**: Bug fixes, hotfixes, minor corrections

### Examples
- `v1.0.0` → `v2.0.0`: Renamed primary key columns (breaking)
- `v2.1.0` → `v2.2.0`: Added new optional columns (non-breaking)
- `v2.2.0` → `v2.2.1`: Fixed migration script bug (patch)

## Description Guidelines
- Use lowercase with hyphens
- Be concise but descriptive
- Include the main entity or table name when relevant
- Maximum 50 characters

### Good Examples
```
schema/v2.3.0/add-user-preferences-table
migration/v1.5.0/backfill-customer-emails
hotfix/v2.1.1/fix-duplicate-order-ids
```

### Bad Examples
```
schema/v2.3.0/New_Schema_Changes  (use lowercase with hyphens)
migration/v1.5.0/fix                (too vague)
hotfix/v2.1.1/this-is-a-very-long-description-that-goes-on-forever  (too long)
schema/add-user-table               (missing version)
```

## Protected Branches
The following branches have special protections:
- `main`: Production-ready code
- `develop`: Integration branch for staging
- `hotfix/*`: Must merge to both main and develop

## Automation
Branch names are used to:
- Trigger specific CI/CD workflows
- Generate release notes
- Determine deployment targets
- Enforce review requirements

## Enforcement
Branch names are validated automatically by:
- Pre-push Git hooks
- GitHub Actions workflow checks
- PR title validation

## Related Documentation
- [Commit Template](./commit-template.md)
- [PR Requirements](./pr-requirements.md)
- [Team Guide](/docs/TEAM_GUIDE.md)
