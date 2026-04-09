# Database Schema and Migration Templates

Comprehensive PostgreSQL database templates for schema design, migrations, and data management.

## Templates Overview

### 1. create-table.sql.template
**Purpose**: Standard PostgreSQL table creation with best practices

**Features**:
- Auto-incrementing primary key (BIGSERIAL)
- Audit columns (created_at, updated_at, deleted_at)
- Automatic updated_at trigger
- Soft delete support with index
- Table and column comments

**Variables**:
- `{{TABLE_NAME}}` - Name of the table (snake_case)
- `{{COLUMNS}}` - Custom column definitions
- `{{DESCRIPTION}}` - Table description for comments

**Example Usage**:
```sql
-- Replace {{TABLE_NAME}} with: products
-- Replace {{COLUMNS}} with:
name VARCHAR(255) NOT NULL,
sku VARCHAR(50) UNIQUE NOT NULL,
price DECIMAL(10,2) NOT NULL,
stock_quantity INTEGER DEFAULT 0,
-- Replace {{DESCRIPTION}} with: Product catalog table
```

---

### 2. changeset.xml.template
**Purpose**: Liquibase changeset for version-controlled schema changes

**Features**:
- Full Liquibase 4.20 XML format
- Automatic rollback support
- Triggers and functions included
- Multiple changeset examples (add column, modify column)

**Variables**:
- `{{CHANGESET_ID}}` - Unique changeset identifier (e.g., 001-create-users)
- `{{AUTHOR}}` - Changeset author name
- `{{TABLE_NAME}}` - Table name
- `{{COLUMNS}}` - Column definitions in Liquibase XML format
- `{{DESCRIPTION}}` - Changeset description

**Example Usage**:
```xml
<!-- Replace {{CHANGESET_ID}} with: 001-create-users -->
<!-- Replace {{AUTHOR}} with: john.doe -->
<!-- Replace {{TABLE_NAME}} with: users -->
<!-- Replace {{COLUMNS}} with:
<column name="email" type="VARCHAR(255)">
    <constraints nullable="false" unique="true"/>
</column>
<column name="full_name" type="VARCHAR(255)">
    <constraints nullable="false"/>
</column>
-->
```

---

### 3. migration-up.sql.template
**Purpose**: Forward migration script for schema evolution

**Features**:
- Version tracking integration
- Schema changes section
- Data migration examples
- Post-migration validation
- Permission grants
- Transaction support

**Variables**:
- `{{MIGRATION_ID}}` - Migration version (e.g., 20240409_001)
- `{{DESCRIPTION}}` - Migration description
- `{{MIGRATION_CHANGES}}` - SQL statements for schema changes
- `{{DATE}}` - Migration date
- `{{AUTHOR}}` - Migration author

**Example Usage**:
```sql
-- Replace {{MIGRATION_ID}} with: 20240409_001
-- Replace {{DESCRIPTION}} with: Add user profile columns
-- Replace {{MIGRATION_CHANGES}} with:
ALTER TABLE users
ADD COLUMN IF NOT EXISTS phone VARCHAR(20),
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS bio TEXT;

CREATE INDEX idx_users_phone ON users(phone);
```

---

### 4. migration-down.sql.template
**Purpose**: Rollback script to revert migrations

**Features**:
- Rollback validation (ensures correct version)
- Data restoration examples
- Schema rollback
- Constraint restoration
- Migration record cleanup

**Variables**:
- `{{MIGRATION_ID}}` - Migration version to rollback
- `{{DESCRIPTION}}` - Rollback description
- `{{ROLLBACK_CHANGES}}` - SQL statements to revert changes
- `{{DATE}}` - Rollback script date
- `{{AUTHOR}}` - Script author

**Example Usage**:
```sql
-- Replace {{ROLLBACK_CHANGES}} with:
ALTER TABLE users
DROP COLUMN IF EXISTS phone,
DROP COLUMN IF EXISTS avatar_url,
DROP COLUMN IF EXISTS bio;

DROP INDEX IF EXISTS idx_users_phone;
```

---

### 5. seed-data.sql.template
**Purpose**: Insert test and development data

**Features**:
- Environment safety check (prevents production seeding)
- Multiple insertion patterns (explicit IDs, auto-generated, loops)
- ON CONFLICT handling
- Sequence reset
- Random data generation
- Verification queries

**Variables**:
- `{{TABLE_NAME}}` - Table to seed
- `{{DATA_ROWS}}` - Column names for data insertion
- `{{ENVIRONMENT}}` - Target environment (dev, test, staging)
- `{{DATE}}` - Seed date
- `{{AUTHOR}}` - Script author

**Example Usage**:
```sql
-- Replace {{TABLE_NAME}} with: users
-- Replace {{DATA_ROWS}} with: email, full_name, role
-- Replace {{ENVIRONMENT}} with: development

-- Values example:
('john@example.com', 'John Doe', 'admin'),
('jane@example.com', 'Jane Smith', 'user')
```

---

### 6. create-index.sql.template
**Purpose**: Performance optimization through indexes

**Features**:
- Pre/post index analysis
- Multiple index types (B-tree, GIN, GiST, BRIN, Hash)
- Partial indexes (filtered)
- Composite indexes
- Expression indexes
- Covering indexes (INCLUDE)
- CONCURRENTLY option for production
- Usage monitoring queries

**Variables**:
- `{{INDEX_NAME}}` - Index name (e.g., idx_users_email)
- `{{TABLE_NAME}}` - Table to index
- `{{COLUMNS}}` - Columns to index (single or multiple)
- `{{INDEX_TYPE}}` - Index type (btree, gin, gist, etc.)
- `{{DESCRIPTION}}` - Index purpose
- `{{IMPACT_DESCRIPTION}}` - Expected performance impact

**Example Usage**:
```sql
-- Replace {{INDEX_NAME}} with: idx_users_email_active
-- Replace {{TABLE_NAME}} with: users
-- Replace {{COLUMNS}} with: email
-- Add WHERE clause for partial index:
WHERE deleted_at IS NULL AND status = 'active'
```

---

### 7. add-foreign-key.sql.template
**Purpose**: Establish referential integrity between tables

**Features**:
- Pre-constraint validation (finds orphaned records)
- Data cleanup strategies (NULL, delete, placeholder)
- Multiple ON DELETE/UPDATE rules
- Composite foreign keys
- Supporting index creation
- Post-constraint validation

**Variables**:
- `{{FK_NAME}}` - Foreign key constraint name (e.g., fk_orders_user_id)
- `{{TABLE_NAME}}` - Table with the foreign key
- `{{COLUMN_NAME}}` - Foreign key column
- `{{REF_TABLE}}` - Referenced table
- `{{REF_COLUMN}}` - Referenced column
- `{{DESCRIPTION}}` - Relationship description

**ON DELETE/UPDATE Options**:
- `CASCADE` - Automatically delete/update child records
- `RESTRICT` - Prevent operation if children exist
- `SET NULL` - Nullify foreign key on parent delete
- `SET DEFAULT` - Use default value on parent delete
- `NO ACTION` - Similar to RESTRICT (deferred check)

**Example Usage**:
```sql
-- Replace {{FK_NAME}} with: fk_orders_user_id
-- Replace {{TABLE_NAME}} with: orders
-- Replace {{COLUMN_NAME}} with: user_id
-- Replace {{REF_TABLE}} with: users
-- Replace {{REF_COLUMN}} with: id
-- Choose ON DELETE CASCADE for orders when user is deleted
```

---

### 8. validate-schema.sql.template
**Purpose**: Comprehensive schema validation and health checks

**Features**:
- Table existence and metadata
- Column validation (types, constraints, nullability)
- Constraint verification (PK, FK, unique, check)
- Index analysis and usage statistics
- Trigger validation
- Data quality checks
- Referential integrity validation
- Performance metrics (table bloat, scan ratio)
- Summary report

**Variables**:
- `{{TABLE_NAME}}` - Table to validate
- `{{SCHEMA_NAME}}` - Schema name (default: public)
- `{{DATE}}` - Validation date

**Example Usage**:
```sql
-- Replace {{TABLE_NAME}} with: users
-- Replace {{SCHEMA_NAME}} with: public
-- Run entire script to generate validation report
```

---

### 9. db.changelog-master.xml.template
**Purpose**: Liquibase master changelog orchestration

**Features**:
- Multi-environment properties
- Database-specific properties (PostgreSQL, MySQL)
- Context-based changeset execution
- Preconditions and validation
- Common function definitions
- Organized includes by version
- Monitoring views
- Security and optimization sections

**Variables**:
- `{{PROJECT_NAME}}` - Project identifier
- `{{DATABASE_NAME}}` - Database name
- `{{ENVIRONMENT}}` - Target environment

**Example Usage**:
```xml
<!-- Replace {{PROJECT_NAME}} with: myapp -->
<!-- Replace {{DATABASE_NAME}} with: myapp_db -->

<!-- Add changelog includes:
<include file="db/changelog/v1.0/01-create-users.xml"/>
<include file="db/changelog/v1.0/02-create-orders.xml"/>
-->
```

**Version Organization**:
- `v1.0.x` - Foundation schema
- `v1.1.x` - Feature modules
- `v1.2.x` - Enhancements
- `v1.3.x` - Bug fixes

---

### 10. database.yml.template
**Purpose**: Multi-environment database configuration

**Features**:
- Environment-specific settings (dev, test, staging, prod)
- Connection pool configuration
- SSL/TLS settings
- Query timeouts and performance tuning
- Read replica support
- High availability configuration
- Liquibase integration
- Backup and monitoring configuration
- PostgreSQL-specific optimizations

**Variables**:
- `{{DB_NAME}}` - Database name
- `{{DB_HOST}}` - Database host
- `{{DB_PORT}}` - Database port (default: 5432)
- `{{DB_USER}}` - Database user
- `{{PROJECT_NAME}}` - Project name

**Environment Variables**:
All sensitive values support environment variable substitution:
- `${DB_HOST}` - Database host
- `${DB_PASSWORD}` - Database password
- `${DB_SSL_CERT_PATH}` - SSL certificate path

**Example Usage**:
```yaml
# Replace {{DB_NAME}} with: myapp
# Replace {{DB_HOST}} with: localhost
# Replace {{DB_USER}} with: myapp_user

# Set environment variables:
export DB_PASSWORD=secretpass
export DB_HOST=db.example.com
```

---

## Best Practices

### Naming Conventions

**Tables**: `snake_case`, plural nouns
```sql
users, order_items, product_categories
```

**Columns**: `snake_case`
```sql
user_id, created_at, email_address
```

**Indexes**: `idx_{table}_{columns}[_{suffix}]`
```sql
idx_users_email
idx_orders_user_id_created_at
idx_products_status_active  -- for partial index
```

**Foreign Keys**: `fk_{table}_{column}`
```sql
fk_orders_user_id
fk_order_items_order_id
```

**Constraints**: `{type}_{table}_{column}[_{suffix}]`
```sql
chk_users_age_positive
unq_users_email
pk_users
```

### Standard Audit Columns

Always include these columns in tables:
```sql
id BIGSERIAL PRIMARY KEY,
created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
deleted_at TIMESTAMP WITH TIME ZONE,  -- for soft delete
created_by VARCHAR(255),
updated_by VARCHAR(255)
```

### Soft Delete Pattern

```sql
-- Index for soft delete queries
CREATE INDEX idx_{table}_deleted_at ON {table}(deleted_at) 
WHERE deleted_at IS NULL;

-- Queries always filter by deleted_at
SELECT * FROM users WHERE deleted_at IS NULL;

-- Soft delete instead of hard delete
UPDATE users SET deleted_at = NOW() WHERE id = 123;
```

### Migration Workflow

1. **Create migration files**: Use `migration-up.sql.template` and `migration-down.sql.template`
2. **Test locally**: Run migration in development environment
3. **Validate**: Use `validate-schema.sql.template` to verify changes
4. **Review rollback**: Ensure down migration works correctly
5. **Deploy to staging**: Test with production-like data
6. **Deploy to production**: Use transaction, backup first

### Index Strategy

**Always index**:
- Primary keys (automatic)
- Foreign keys (manual)
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY clauses

**Consider indexing**:
- Columns in GROUP BY
- Columns with high cardinality
- Frequently searched columns

**Don't over-index**:
- Columns with low cardinality (few distinct values)
- Frequently updated columns (index maintenance overhead)
- Small tables (< 1000 rows)

### Transaction Guidelines

```sql
BEGIN;
  -- Make schema changes
  -- Validate changes
  -- If anything fails, PostgreSQL auto-rolls back
COMMIT;

-- For long-running migrations, consider:
-- 1. Breaking into smaller migrations
-- 2. Using CONCURRENTLY for indexes (can't be in transaction)
-- 3. Scheduling during low-traffic periods
```

## Usage Examples

### Example 1: Create Users Table

Using `create-table.sql.template`:

```sql
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    
    -- Custom columns
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    
    -- Audit timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_by VARCHAR(255),
    updated_by VARCHAR(255)
);

COMMENT ON TABLE users IS 'Application user accounts';

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status) WHERE deleted_at IS NULL;
```

### Example 2: Add Foreign Key Relationship

Using `add-foreign-key.sql.template`:

```sql
-- orders.user_id -> users.id
ALTER TABLE orders
ADD CONSTRAINT fk_orders_user_id
    FOREIGN KEY (user_id)
    REFERENCES users (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

CREATE INDEX idx_orders_user_id ON orders(user_id);
```

### Example 3: Create Performance Index

Using `create-index.sql.template`:

```sql
-- Composite index for common query pattern
CREATE INDEX CONCURRENTLY idx_orders_user_status_date
ON orders (user_id, status, created_at DESC)
WHERE deleted_at IS NULL;
```

### Example 4: Seed Development Data

Using `seed-data.sql.template`:

```sql
INSERT INTO users (id, email, full_name, password_hash, status)
VALUES
    (1, 'admin@example.com', 'Admin User', '$2a$10$...', 'active'),
    (2, 'user@example.com', 'Test User', '$2a$10$...', 'active'),
    (3, 'inactive@example.com', 'Inactive User', '$2a$10$...', 'inactive')
ON CONFLICT (id) DO NOTHING;

SELECT setval('users_id_seq', 100, true);
```

## Integration with CI/CD

### Liquibase Migration

```bash
# Run migrations
liquibase --changelog-file=db.changelog-master.xml update

# Rollback last changeset
liquibase --changelog-file=db.changelog-master.xml rollback-count 1

# Generate rollback SQL
liquibase --changelog-file=db.changelog-master.xml rollback-sql

# Validate checksums
liquibase --changelog-file=db.changelog-master.xml validate
```

### Custom Migration Script

```bash
# Run migration with validation
psql -f migration-up.sql
psql -f validate-schema.sql

# On failure, rollback
psql -f migration-down.sql
```

## Maintenance Tasks

### Regular Validation
```bash
# Weekly schema validation
psql -f validate-schema.sql > validation-report-$(date +%Y%m%d).txt
```

### Index Maintenance
```sql
-- Find unused indexes
SELECT * FROM v_index_usage WHERE usage_status = 'Unused';

-- Rebuild bloated indexes
REINDEX INDEX CONCURRENTLY index_name;
```

### Performance Monitoring
```sql
-- Check table sizes
SELECT * FROM v_table_sizes;

-- Check slow queries
SELECT * FROM pg_stat_statements 
ORDER BY mean_exec_time DESC 
LIMIT 20;
```

## Troubleshooting

### Migration Fails

1. **Check for data integrity issues**:
   ```sql
   -- Run validation queries from add-foreign-key template
   ```

2. **Review rollback script**:
   ```sql
   -- Test rollback in development first
   ```

3. **Check logs**:
   ```bash
   tail -f /var/log/postgresql/postgresql.log
   ```

### Slow Queries

1. **Run EXPLAIN ANALYZE**:
   ```sql
   EXPLAIN ANALYZE SELECT ...;
   ```

2. **Check for missing indexes**:
   ```sql
   -- Use validate-schema template to find sequential scans
   ```

3. **Update statistics**:
   ```sql
   ANALYZE table_name;
   ```

## Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Liquibase Documentation](https://docs.liquibase.com/)
- [PostgreSQL Best Practices](https://wiki.postgresql.org/wiki/Don%27t_Do_This)
- [Index Types](https://www.postgresql.org/docs/current/indexes-types.html)
