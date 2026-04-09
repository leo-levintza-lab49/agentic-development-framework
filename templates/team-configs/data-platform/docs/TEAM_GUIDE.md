# Data Platform Team Guide

## Overview
Welcome to the Data Platform team. This guide covers our workflows, tools, conventions, and best practices for managing database schemas, migrations, and data pipelines.

## Table of Contents
1. [Team Workflow](#team-workflow)
2. [Creating Migrations](#creating-migrations)
3. [Testing Requirements](#testing-requirements)
4. [Deployment Process](#deployment-process)
5. [Rollback Procedures](#rollback-procedures)
6. [Tools and Setup](#tools-and-setup)
7. [Common Scenarios](#common-scenarios)
8. [Troubleshooting](#troubleshooting)

---

## Team Workflow

### 1. Planning Phase
- Review requirements with product and engineering teams
- Assess impact on existing schema and data
- Design schema changes with backwards compatibility in mind
- Document breaking changes and coordination requirements

### 2. Development Phase
- Create feature branch following naming convention
- Develop migration scripts with comprehensive tests
- Run local validation and testing
- Commit with proper message format

### 3. Review Phase
- Open PR with complete documentation
- Address automated check failures
- Respond to review comments
- Ensure 2+ approvals (data + backend)

### 4. Deployment Phase
- Merge to main after approvals
- Monitor CI/CD pipeline
- Execute migration in staging
- Verify in staging environment
- Deploy to production
- Monitor production metrics

### 5. Post-Deployment
- Verify data integrity
- Monitor performance metrics
- Update documentation
- Close related issues

---

## Creating Migrations

### Step 1: Generate Migration File
```bash
# Using Alembic
alembic revision -m "add users table"

# This creates: migrations/versions/m_20260408_001_add_users_table.py
```

### Step 2: Implement Upgrade Function
```python
"""add users table

Migration ID: m_20260408_001
Created: 2026-04-08
Author: data-platform-team

Adds users table with authentication and profile fields.
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

# revision identifiers
revision = 'm_20260408_001'
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    """
    Create users table with authentication fields.
    
    Runtime: ~15 seconds
    Data Impact: None (new table)
    Rollback: Safe (no data loss)
    """
    op.create_table(
        'users',
        sa.Column('id', UUID(as_uuid=True), primary_key=True),
        sa.Column('email', sa.String(255), nullable=False, unique=True),
        sa.Column('username', sa.String(100), nullable=False, unique=True),
        sa.Column('password_hash', sa.String(255), nullable=False),
        sa.Column('email_verified_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, 
                  server_default=sa.text('NOW()')),
        sa.Column('updated_at', sa.DateTime(), nullable=False, 
                  server_default=sa.text('NOW()')),
        sa.Column('deleted_at', sa.DateTime(), nullable=True),
    )
    
    # Create indexes
    op.create_index('idx_users_email', 'users', ['email'])
    op.create_index('idx_users_created_at', 'users', ['created_at'])
    op.create_index('idx_users_deleted_at', 'users', ['deleted_at'], 
                    postgresql_where=sa.text('deleted_at IS NULL'))

def downgrade():
    """
    Remove users table.
    
    Data Impact: ALL user data will be lost
    Rollback Time: ~5 seconds
    Dependencies: Must remove dependent tables first
    """
    op.drop_index('idx_users_deleted_at', 'users')
    op.drop_index('idx_users_created_at', 'users')
    op.drop_index('idx_users_email', 'users')
    op.drop_table('users')
```

### Step 3: Create Comprehensive Tests
```python
# tests/migrations/test_m_20260408_001.py
import pytest
from sqlalchemy import inspect, text
from alembic.config import Config
from alembic import command

@pytest.fixture
def alembic_config(test_db_url):
    """Alembic configuration for testing."""
    config = Config()
    config.set_main_option("script_location", "migrations")
    config.set_main_option("sqlalchemy.url", test_db_url)
    return config

class TestMigration_m_20260408_001:
    """Test suite for users table migration."""
    
    def test_upgrade_creates_users_table(self, alembic_config, db_connection):
        """Verify users table is created with correct schema."""
        # Run migration
        command.upgrade(alembic_config, "m_20260408_001")
        
        # Verify table exists
        inspector = inspect(db_connection)
        assert 'users' in inspector.get_table_names()
        
        # Verify columns
        columns = {col['name']: col for col in inspector.get_columns('users')}
        assert 'id' in columns
        assert 'email' in columns
        assert 'username' in columns
        assert 'password_hash' in columns
        assert 'email_verified_at' in columns
        assert 'created_at' in columns
        assert 'updated_at' in columns
        assert 'deleted_at' in columns
        
        # Verify column types
        assert str(columns['email']['type']) == 'VARCHAR(255)'
        assert columns['email']['nullable'] is False
        
    def test_upgrade_creates_indexes(self, alembic_config, db_connection):
        """Verify all indexes are created."""
        command.upgrade(alembic_config, "m_20260408_001")
        
        inspector = inspect(db_connection)
        indexes = {idx['name']: idx for idx in inspector.get_indexes('users')}
        
        assert 'idx_users_email' in indexes
        assert 'idx_users_created_at' in indexes
        assert 'idx_users_deleted_at' in indexes
        
    def test_upgrade_creates_constraints(self, alembic_config, db_connection):
        """Verify primary key and unique constraints."""
        command.upgrade(alembic_config, "m_20260408_001")
        
        inspector = inspect(db_connection)
        
        # Check primary key
        pk = inspector.get_pk_constraint('users')
        assert pk['constrained_columns'] == ['id']
        
        # Check unique constraints
        unique_constraints = inspector.get_unique_constraints('users')
        unique_cols = [uc['column_names'] for uc in unique_constraints]
        assert ['email'] in unique_cols
        assert ['username'] in unique_cols
        
    def test_downgrade_removes_users_table(self, alembic_config, db_connection):
        """Verify rollback removes table cleanly."""
        # Run migration
        command.upgrade(alembic_config, "m_20260408_001")
        
        # Verify table exists
        inspector = inspect(db_connection)
        assert 'users' in inspector.get_table_names()
        
        # Rollback
        command.downgrade(alembic_config, "-1")
        
        # Verify table removed
        inspector = inspect(db_connection)
        assert 'users' not in inspector.get_table_names()
        
    def test_upgrade_is_idempotent(self, alembic_config, db_connection):
        """Verify migration can run multiple times safely."""
        # This should not raise an error
        command.upgrade(alembic_config, "m_20260408_001")
        command.upgrade(alembic_config, "m_20260408_001")
        
    def test_insert_and_query_users(self, alembic_config, db_connection):
        """Verify table is functional for basic operations."""
        command.upgrade(alembic_config, "m_20260408_001")
        
        # Insert test user
        db_connection.execute(text("""
            INSERT INTO users (id, email, username, password_hash)
            VALUES (
                gen_random_uuid(),
                'test@example.com',
                'testuser',
                'hashed_password'
            )
        """))
        
        # Query user
        result = db_connection.execute(text(
            "SELECT email, username FROM users WHERE email = 'test@example.com'"
        ))
        row = result.fetchone()
        
        assert row is not None
        assert row[0] == 'test@example.com'
        assert row[1] == 'testuser'
        
    def test_email_uniqueness_constraint(self, alembic_config, db_connection):
        """Verify email unique constraint is enforced."""
        command.upgrade(alembic_config, "m_20260408_001")
        
        # Insert first user
        db_connection.execute(text("""
            INSERT INTO users (id, email, username, password_hash)
            VALUES (
                gen_random_uuid(),
                'test@example.com',
                'testuser1',
                'hashed_password'
            )
        """))
        
        # Attempt to insert duplicate email
        with pytest.raises(Exception) as exc_info:
            db_connection.execute(text("""
                INSERT INTO users (id, email, username, password_hash)
                VALUES (
                    gen_random_uuid(),
                    'test@example.com',
                    'testuser2',
                    'hashed_password'
                )
            """))
        
        assert 'unique constraint' in str(exc_info.value).lower()
```

### Step 4: Run Local Tests
```bash
# Run all tests
pytest tests/migrations/test_m_20260408_001.py -v

# Run with coverage
pytest tests/migrations/test_m_20260408_001.py --cov=migrations --cov-report=html

# View coverage report
open htmlcov/index.html
```

### Step 5: Test on Local Database
```bash
# Apply migration
alembic upgrade head

# Verify schema
psql -d local_dev -c "\d users"

# Test rollback
alembic downgrade -1

# Verify removal
psql -d local_dev -c "\d users"

# Re-apply for continued development
alembic upgrade head
```

---

## Testing Requirements

### Minimum Coverage: 80%
Every migration must achieve at least 80% test coverage.

### Required Test Scenarios

#### 1. Schema Tests
- Table creation/modification
- Column existence and types
- Constraint validation
- Index creation

#### 2. Data Tests
- Insert operations
- Update operations
- Delete operations
- Query performance

#### 3. Constraint Tests
- Primary key enforcement
- Foreign key validation
- Unique constraint enforcement
- Check constraint validation

#### 4. Rollback Tests
- Clean rollback execution
- Data cleanup verification
- Schema restoration

#### 5. Edge Case Tests
- Empty table migration
- Large dataset handling
- Concurrent operation handling
- Error condition handling

### Test Data Guidelines
- Use realistic data volumes (1K-100K rows minimum)
- Include edge cases (null values, empty strings, boundary values)
- Test with production-like data distributions
- Validate performance with representative queries

---

## Deployment Process

### Staging Deployment
```bash
# 1. Merge PR to develop branch
git checkout develop
git merge feature/schema/v2.3.0/add-users-table

# 2. CI/CD automatically deploys to staging

# 3. Verify migration in staging
alembic -c staging.ini history
alembic -c staging.ini current

# 4. Run smoke tests
pytest tests/integration/test_users_api.py --env=staging

# 5. Verify data integrity
python scripts/validate_data_integrity.py --env=staging
```

### Production Deployment
```bash
# 1. Merge to main (requires approvals)
git checkout main
git merge develop

# 2. Tag release
git tag -a v2.3.0 -m "Release v2.3.0: Add users table"
git push origin v2.3.0

# 3. CI/CD runs pre-production checks

# 4. Manual approval required for production deployment

# 5. Monitor deployment
watch -n 5 'alembic -c production.ini current'

# 6. Verify in production
python scripts/validate_data_integrity.py --env=production

# 7. Monitor metrics
# - Database CPU/Memory
# - Query performance
# - Application error rates
# - API response times
```

### Deployment Checklist
- [ ] All tests passing in CI/CD
- [ ] Code reviewed and approved (2+ reviewers)
- [ ] Deployed successfully to staging
- [ ] Smoke tests passed in staging
- [ ] Stakeholders notified
- [ ] Maintenance window scheduled (if required)
- [ ] Rollback plan reviewed
- [ ] Monitoring alerts configured
- [ ] On-call engineer available

---

## Rollback Procedures

### When to Rollback
- Migration fails during execution
- Data corruption detected
- Severe performance degradation
- Application errors related to schema changes
- Unexpected side effects discovered

### Rollback Steps

#### Immediate Rollback (Staging)
```bash
# 1. Identify current migration
alembic current

# 2. Rollback one migration
alembic downgrade -1

# 3. Verify schema restored
python scripts/validate_schema.py

# 4. Check for data issues
python scripts/check_data_integrity.py
```

#### Production Rollback (Requires Approval)
```bash
# 1. Create incident ticket
gh issue create --title "Production Rollback: Migration m_20260408_001" \
  --label incident,rollback

# 2. Notify stakeholders
python scripts/notify_rollback.py --migration m_20260408_001

# 3. Execute rollback (requires data lead approval)
alembic -c production.ini downgrade -1

# 4. Verify application health
python scripts/health_check.py --env=production

# 5. Monitor metrics for 1 hour

# 6. Document incident
python scripts/create_postmortem.py --incident INC-2026-0408-001
```

### Rollback Validation
```python
# scripts/validate_rollback.py
def validate_rollback(migration_id):
    """Validate schema after rollback."""
    checks = [
        check_schema_matches_baseline(),
        check_no_orphaned_tables(),
        check_no_orphaned_indexes(),
        check_foreign_keys_intact(),
        check_data_integrity(),
        check_application_queries(),
    ]
    
    results = [check() for check in checks]
    
    if all(results):
        print(f"✓ Rollback of {migration_id} successful")
        return True
    else:
        print(f"✗ Rollback validation failed")
        return False
```

---

## Tools and Setup

### Required Tools
```bash
# Database tools
brew install postgresql@15
brew install pgcli

# Python environment
python -m venv venv
source venv/bin/activate
pip install -r requirements-dev.txt

# Migration tools
pip install alembic psycopg2-binary

# Validation tools
pip install sqlfluff migra great-expectations

# Testing tools
pip install pytest pytest-cov pytest-postgresql
```

### Local Development Setup
```bash
# 1. Clone repository
git clone git@github.com:polybase-poc/data-platform.git
cd data-platform

# 2. Set up Python environment
python -m venv venv
source venv/bin/activate
pip install -r requirements-dev.txt

# 3. Configure database
cp .env.example .env
# Edit .env with local database credentials

# 4. Create local database
createdb data_platform_dev

# 5. Run migrations
alembic upgrade head

# 6. Verify setup
pytest tests/ -v
```

### Development Workflow
```bash
# Create new migration
alembic revision -m "add feature"

# Edit migration file
vim migrations/versions/m_YYYYMMDD_NNN_add_feature.py

# Test migration
pytest tests/migrations/test_m_YYYYMMDD_NNN.py -v

# Apply locally
alembic upgrade head

# Create feature branch
git checkout -b schema/v2.3.0/add-feature

# Commit with proper message
git commit -m "schema(m_YYYYMMDD_NNN): add feature"

# Push and create PR
git push origin schema/v2.3.0/add-feature
gh pr create
```

---

## Common Scenarios

### Adding a New Table
See [Creating Migrations](#creating-migrations) section above.

### Adding a Column to Existing Table
```python
def upgrade():
    """Add email_verified_at column to users table."""
    op.add_column('users',
        sa.Column('email_verified_at', sa.DateTime(), nullable=True)
    )
    
    # Create index for performance
    op.create_index('idx_users_email_verified_at', 'users', 
                    ['email_verified_at'])

def downgrade():
    """Remove email_verified_at column."""
    op.drop_index('idx_users_email_verified_at', 'users')
    op.drop_column('users', 'email_verified_at')
```

### Renaming a Column (Breaking Change)
```python
def upgrade():
    """
    Rename customer_id to user_id in orders table.
    
    BREAKING CHANGE: Application must support both column names
    Requires coordinated deployment with app v2.5.0+
    """
    # Step 1: Add new column
    op.add_column('orders',
        sa.Column('user_id', sa.BigInteger(), nullable=True)
    )
    
    # Step 2: Copy data
    op.execute('UPDATE orders SET user_id = customer_id')
    
    # Step 3: Make new column non-nullable
    op.alter_column('orders', 'user_id', nullable=False)
    
    # Step 4: Add foreign key
    op.create_foreign_key('fk_orders_user_id', 'orders', 'users',
                          ['user_id'], ['id'])
    
    # Step 5: Drop old column (only after app deployment)
    # op.drop_column('orders', 'customer_id')
    # NOTE: This step should be in a separate migration after app deployment

def downgrade():
    """Restore customer_id column."""
    op.add_column('orders',
        sa.Column('customer_id', sa.BigInteger(), nullable=True)
    )
    op.execute('UPDATE orders SET customer_id = user_id')
    op.alter_column('orders', 'customer_id', nullable=False)
    op.drop_constraint('fk_orders_user_id', 'orders')
    op.drop_column('orders', 'user_id')
```

### Data Backfill Migration
```python
def upgrade():
    """
    Backfill email verification status from auth logs.
    
    Data Impact: Updates ~50,000 user records
    Runtime: ~5 minutes
    """
    # Use batch processing for large datasets
    op.execute("""
        WITH verified_users AS (
            SELECT DISTINCT user_id, MIN(created_at) as verified_at
            FROM auth_logs
            WHERE event_type = 'email_verified'
            GROUP BY user_id
        )
        UPDATE users u
        SET email_verified_at = v.verified_at
        FROM verified_users v
        WHERE u.id = v.user_id
        AND u.email_verified_at IS NULL
    """)

def downgrade():
    """
    Revert email verification status.
    
    Data Impact: Sets all email_verified_at to NULL
    """
    op.execute("UPDATE users SET email_verified_at = NULL")
```

---

## Troubleshooting

### Migration Fails with Foreign Key Error
```bash
# Check foreign key dependencies
SELECT
    tc.table_schema, 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name,
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name='your_table';
```

### Rollback Fails
```bash
# Force downgrade (use with caution)
alembic downgrade m_20260408_001

# If that fails, manually drop objects
psql -d your_db -c "DROP TABLE IF EXISTS problematic_table CASCADE;"

# Then stamp the database to correct revision
alembic stamp m_20260408_001
```

### Slow Migration Performance
```sql
-- Create indexes concurrently (doesn't lock table)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Analyze table after bulk operations
ANALYZE users;

-- Check for blocking queries
SELECT pid, query, state, wait_event
FROM pg_stat_activity
WHERE state != 'idle';
```

### Test Coverage Below 80%
```bash
# Generate coverage report
pytest tests/ --cov=migrations --cov-report=html

# Identify uncovered lines
open htmlcov/index.html

# Add missing test cases
# Focus on error paths, edge cases, and rollback scenarios
```

---

## Additional Resources

### Documentation
- [Branch Naming Convention](../.claude/rules/branch-naming.md)
- [Commit Message Template](../.claude/rules/commit-template.md)
- [PR Requirements](../.claude/rules/pr-requirements.md)

### External Resources
- [Alembic Documentation](https://alembic.sqlalchemy.org/)
- [SQLFluff Documentation](https://docs.sqlfluff.com/)
- [PostgreSQL Best Practices](https://wiki.postgresql.org/wiki/Don%27t_Do_This)

### Team Contacts
- Data Platform Lead: @data-platform-lead
- Backend Team Lead: @backend-lead
- On-Call Engineer: Check #on-call channel

### Incident Response
- Incident Channel: #incidents
- Escalation Path: data-platform-lead → engineering-director → CTO
- Post-Mortem Template: `templates/postmortem.md`
