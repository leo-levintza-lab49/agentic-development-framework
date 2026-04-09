# Database Templates Quick Reference

## Template Files

| Template | Purpose | Key Variables |
|----------|---------|---------------|
| `create-table.sql.template` | Create new table with audit columns | `TABLE_NAME`, `COLUMNS`, `DESCRIPTION` |
| `changeset.xml.template` | Liquibase changeset with rollback | `CHANGESET_ID`, `AUTHOR`, `TABLE_NAME`, `COLUMNS` |
| `migration-up.sql.template` | Forward migration script | `MIGRATION_ID`, `DESCRIPTION`, `MIGRATION_CHANGES` |
| `migration-down.sql.template` | Rollback migration script | `MIGRATION_ID`, `ROLLBACK_CHANGES` |
| `seed-data.sql.template` | Insert test/dev data | `TABLE_NAME`, `DATA_ROWS`, `ENVIRONMENT` |
| `create-index.sql.template` | Create performance indexes | `INDEX_NAME`, `TABLE_NAME`, `COLUMNS`, `INDEX_TYPE` |
| `add-foreign-key.sql.template` | Add foreign key constraints | `FK_NAME`, `TABLE_NAME`, `COLUMN_NAME`, `REF_TABLE` |
| `validate-schema.sql.template` | Comprehensive schema validation | `TABLE_NAME`, `SCHEMA_NAME` |
| `db.changelog-master.xml.template` | Liquibase master changelog | `PROJECT_NAME`, `DATABASE_NAME` |
| `database.yml.template` | Multi-environment DB config | `DB_NAME`, `DB_HOST`, `DB_PORT`, `DB_USER` |

## Common Tasks

### Create a New Table
1. Use `create-table.sql.template`
2. Replace `{{TABLE_NAME}}` with your table name (snake_case, plural)
3. Add custom columns in `{{COLUMNS}}` section
4. Run the SQL or wrap in Liquibase changeset

### Add a Foreign Key
1. Use `add-foreign-key.sql.template`
2. Replace variables: `FK_NAME`, `TABLE_NAME`, `COLUMN_NAME`, `REF_TABLE`, `REF_COLUMN`
3. Choose appropriate ON DELETE rule (CASCADE, RESTRICT, SET NULL)
4. Run pre-validation queries first to find orphaned records

### Create an Index
1. Use `create-index.sql.template`
2. Replace `INDEX_NAME` (format: `idx_{table}_{columns}`)
3. Choose index type: B-tree (default), GIN, GiST, BRIN, Hash
4. Use CONCURRENTLY for production deployments

### Run a Migration
1. Create forward migration with `migration-up.sql.template`
2. Create rollback with `migration-down.sql.template`
3. Test in dev environment
4. Validate with `validate-schema.sql.template`
5. Deploy to staging then production

### Seed Test Data
1. Use `seed-data.sql.template`
2. Add environment check (prevents production seeding)
3. Use ON CONFLICT DO NOTHING for idempotency
4. Reset sequences after explicit ID inserts

### Validate Schema
1. Use `validate-schema.sql.template`
2. Replace `TABLE_NAME` and `SCHEMA_NAME`
3. Run entire script to generate comprehensive report
4. Review findings for issues (missing indexes, orphaned data, etc.)

## Variable Substitution

All templates use `{{VARIABLE_NAME}}` format for placeholders.

### Find and Replace
```bash
# Single file
sed -e 's/{{TABLE_NAME}}/users/g' \
    -e 's/{{DESCRIPTION}}/User accounts table/g' \
    create-table.sql.template > create-users-table.sql

# Multiple variables
cat create-table.sql.template | \
  sed 's/{{TABLE_NAME}}/products/g' | \
  sed 's/{{COLUMNS}}/name VARCHAR(255) NOT NULL,\n    sku VARCHAR(50) UNIQUE NOT NULL,\n    price DECIMAL(10,2) NOT NULL/g' | \
  sed 's/{{DESCRIPTION}}/Product catalog/g' > create-products-table.sql
```

### Using a Script
```bash
#!/bin/bash
TABLE_NAME="orders"
COLUMNS="user_id BIGINT NOT NULL,\n    order_number VARCHAR(50) UNIQUE NOT NULL,\n    total_amount DECIMAL(10,2) NOT NULL,\n    status VARCHAR(20) DEFAULT 'pending'"
DESCRIPTION="Customer orders"

sed -e "s/{{TABLE_NAME}}/$TABLE_NAME/g" \
    -e "s/{{COLUMNS}}/$COLUMNS/g" \
    -e "s/{{DESCRIPTION}}/$DESCRIPTION/g" \
    create-table.sql.template > "create-${TABLE_NAME}-table.sql"
```

## Naming Conventions

### Tables
- **Format**: `snake_case`, plural
- **Examples**: `users`, `order_items`, `product_categories`

### Columns
- **Format**: `snake_case`
- **Examples**: `user_id`, `created_at`, `email_address`

### Indexes
- **Format**: `idx_{table}_{columns}[_{suffix}]`
- **Examples**: 
  - `idx_users_email`
  - `idx_orders_user_id_created_at`
  - `idx_products_status_active` (partial index)

### Foreign Keys
- **Format**: `fk_{table}_{column}`
- **Examples**: `fk_orders_user_id`, `fk_order_items_product_id`

### Constraints
- **Format**: `{type}_{table}_{column}[_{suffix}]`
- **Types**: `pk` (primary key), `fk` (foreign key), `unq` (unique), `chk` (check)
- **Examples**:
  - `pk_users`
  - `fk_orders_user_id`
  - `unq_users_email`
  - `chk_users_age_positive`

## Standard Audit Columns

Always include in tables:
```sql
id BIGSERIAL PRIMARY KEY,
created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
deleted_at TIMESTAMP WITH TIME ZONE,  -- soft delete
created_by VARCHAR(255),
updated_by VARCHAR(255)
```

## Index Strategy Checklist

**Always Index:**
- ✅ Foreign key columns
- ✅ Columns in WHERE clauses
- ✅ Columns in JOIN conditions
- ✅ Columns in ORDER BY clauses

**Consider Indexing:**
- 🟡 Columns in GROUP BY
- 🟡 High cardinality columns
- 🟡 Frequently searched columns

**Don't Index:**
- ❌ Low cardinality columns (< 10 distinct values)
- ❌ Frequently updated columns (high write overhead)
- ❌ Small tables (< 1000 rows)

## Foreign Key ON DELETE Rules

| Rule | Behavior | Use Case |
|------|----------|----------|
| `CASCADE` | Automatically delete child records | Orders when user deleted |
| `RESTRICT` | Prevent delete if children exist (immediate) | Prevent accidental data loss |
| `NO ACTION` | Prevent delete if children exist (deferred) | Similar to RESTRICT |
| `SET NULL` | Nullify foreign key on parent delete | Keep audit records when user deleted |
| `SET DEFAULT` | Set to default value on parent delete | Assign to default category |

## Index Types

| Type | Use Case | Example |
|------|----------|---------|
| **B-tree** (default) | General purpose, equality & range queries | `CREATE INDEX idx_users_email ON users(email)` |
| **GIN** | Full-text search, arrays, JSONB | `CREATE INDEX idx_docs_content ON docs USING GIN(content)` |
| **GiST** | Geometric data, full-text search | `CREATE INDEX idx_locations ON places USING GIST(location)` |
| **BRIN** | Very large tables with natural ordering | `CREATE INDEX idx_logs_timestamp ON logs USING BRIN(timestamp)` |
| **Hash** | Simple equality comparisons only | `CREATE INDEX idx_status ON orders USING HASH(status)` |

## Liquibase Commands

```bash
# Run all pending changesets
liquibase update

# Rollback last N changesets
liquibase rollback-count N

# Rollback to specific tag
liquibase rollback <tag>

# Generate rollback SQL (preview)
liquibase rollback-sql

# Mark all pending changesets as run (without executing)
liquibase changelog-sync

# Validate checksums
liquibase validate

# Generate documentation
liquibase db-doc ./docs

# Check status
liquibase status

# Tag current state
liquibase tag v1.0.0
```

## PostgreSQL Data Types Reference

| Type | Description | Example |
|------|-------------|---------|
| `BIGSERIAL` | Auto-incrementing 8-byte integer | Primary keys |
| `VARCHAR(n)` | Variable-length string with limit | `email VARCHAR(255)` |
| `TEXT` | Variable-length string, unlimited | Long descriptions |
| `INTEGER` | 4-byte integer | Counters, quantities |
| `BIGINT` | 8-byte integer | Foreign keys, large numbers |
| `DECIMAL(p,s)` | Exact numeric with precision | `price DECIMAL(10,2)` |
| `BOOLEAN` | True/false | `is_active BOOLEAN` |
| `TIMESTAMP WITH TIME ZONE` | Date and time with timezone | Audit columns |
| `DATE` | Date only | `birth_date DATE` |
| `TIME` | Time only | `opening_time TIME` |
| `JSONB` | Binary JSON with indexing | `metadata JSONB` |
| `UUID` | Universally unique identifier | `external_id UUID` |
| `ARRAY` | Array of any type | `tags TEXT[]` |

## Performance Tips

### Index Creation
```sql
-- Use CONCURRENTLY for production (no table locking)
CREATE INDEX CONCURRENTLY idx_name ON table(column);

-- Partial index for common queries
CREATE INDEX idx_active_users ON users(email) WHERE deleted_at IS NULL;

-- Covering index (avoid table lookups)
CREATE INDEX idx_users_lookup ON users(email) INCLUDE (full_name, status);
```

### Query Optimization
```sql
-- Always use EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Update statistics after bulk operations
ANALYZE table_name;

-- Check index usage
SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;
```

### Soft Delete Pattern
```sql
-- Index supports soft delete queries
CREATE INDEX idx_table_deleted_at ON table(deleted_at) WHERE deleted_at IS NULL;

-- Always filter by deleted_at
SELECT * FROM table WHERE deleted_at IS NULL;

-- Soft delete instead of hard delete
UPDATE table SET deleted_at = NOW() WHERE id = 123;
```

## Common Queries

### Find Table Size
```sql
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Find Unused Indexes
```sql
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
    AND indexname NOT LIKE '%_pkey'
ORDER BY pg_relation_size(indexname::regclass) DESC;
```

### Find Missing Foreign Key Indexes
```sql
SELECT
    tc.table_name,
    kcu.column_name,
    'Missing index on ' || kcu.column_name AS recommendation
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND NOT EXISTS (
        SELECT 1
        FROM pg_indexes
        WHERE tablename = tc.table_name
            AND indexdef LIKE '%' || kcu.column_name || '%'
    );
```

### Find Duplicate Indexes
```sql
SELECT
    pg_size_pretty(SUM(pg_relation_size(idx))::BIGINT) AS total_size,
    string_agg(indexrelname, ', ') AS duplicate_indexes
FROM pg_index idx
JOIN pg_class cls ON cls.oid = idx.indexrelid
WHERE indrelid = 'public.table_name'::regclass
GROUP BY indkey
HAVING COUNT(*) > 1;
```

## Troubleshooting

### Migration Fails
1. Check logs: `tail -f /var/log/postgresql/postgresql.log`
2. Verify data integrity: Run validation queries
3. Test rollback in dev first
4. Check for lock conflicts: `SELECT * FROM pg_locks WHERE NOT granted`

### Slow Queries
1. Run `EXPLAIN ANALYZE`
2. Check for missing indexes
3. Update table statistics: `ANALYZE table_name`
4. Consider partitioning for very large tables

### Foreign Key Constraint Violation
1. Find orphaned records using `add-foreign-key.sql.template` validation queries
2. Clean up orphaned data
3. Re-run constraint addition

### Index Not Being Used
1. Check query plan with `EXPLAIN`
2. Update statistics: `ANALYZE table_name`
3. Consider lowering `random_page_cost` for SSDs
4. Ensure query matches index structure (especially for composite indexes)

## Environment-Specific Considerations

### Development
- Enable query logging
- Use smaller connection pools
- Include seed data
- Enable detailed error messages

### Staging
- Mirror production configuration
- Use production-like data volumes
- Test migrations thoroughly
- Enable monitoring

### Production
- Use SSL/TLS connections
- Large connection pools
- Read replicas for scaling
- Automated backups
- Monitoring and alerting
- Use `CONCURRENTLY` for index creation
- Schedule migrations during low-traffic windows

## File Organization

Recommended project structure:
```
db/
├── changelog/
│   ├── db.changelog-master.xml
│   ├── v1.0/
│   │   ├── 001-create-users.xml
│   │   ├── 002-create-orders.xml
│   │   └── ...
│   ├── v1.1/
│   │   └── ...
│   └── seed/
│       ├── 01-reference-data.xml
│       └── 02-test-data.xml
├── migrations/
│   ├── 20240409_001_add_user_profile.up.sql
│   ├── 20240409_001_add_user_profile.down.sql
│   └── ...
├── schema/
│   ├── create-users-table.sql
│   ├── create-orders-table.sql
│   └── ...
├── indexes/
│   ├── idx-users-email.sql
│   └── ...
├── foreign-keys/
│   ├── fk-orders-user-id.sql
│   └── ...
└── validation/
    ├── validate-users.sql
    └── ...
```

## Support

For detailed documentation, see `README.md` in this directory.

For PostgreSQL documentation: https://www.postgresql.org/docs/
For Liquibase documentation: https://docs.liquibase.com/
