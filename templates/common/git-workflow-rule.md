# Git Workflow Guidelines

## Overview

Follow these Git workflow guidelines to maintain a clean, traceable history and enable effective collaboration.

## Branching Strategy

### Branch Types

- **`main`** - Production-ready code, always deployable
- **`develop`** - Integration branch for ongoing development
- **`feature/*`** - New features (e.g., `feature/user-authentication`)
- **`bugfix/*`** - Bug fixes (e.g., `bugfix/login-error`)
- **`hotfix/*`** - Urgent production fixes (e.g., `hotfix/security-patch`)
- **`release/*`** - Release preparation (e.g., `release/v1.2.0`)

### Branch Naming

**Format**: `type/short-description`

**Examples**:
- `feature/add-payment-gateway`
- `bugfix/fix-null-pointer`
- `hotfix/patch-security-vuln`

**Rules**:
- Use lowercase with hyphens
- Keep names short but descriptive
- Use present tense verbs

## Commit Guidelines

### Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, no logic change)
- **refactor**: Code refactoring (no feature/fix)
- **test**: Adding or updating tests
- **chore**: Maintenance tasks, dependencies

### Subject Line

- Use imperative mood ("Add feature" not "Added feature")
- Keep under 50 characters
- Don't end with a period
- Capitalize first letter

### Body (Optional)

- Explain **what** and **why**, not **how**
- Wrap at 72 characters
- Separate from subject with blank line

### Examples

```
feat: Add user authentication with JWT

Implements JWT-based authentication to secure API endpoints.
Users can now log in and receive a token for subsequent requests.

Closes #123
```

```
fix: Resolve null pointer exception in payment service

The payment service was throwing NPE when processing
refunds without a transaction ID.

Fixes #456
```

## Pull Request Workflow

### Creating a PR

1. **Branch from `develop`** (or `main` for hotfixes)
2. **Make changes** in small, logical commits
3. **Push** your branch to origin
4. **Create PR** with clear title and description
5. **Link** related issues
6. **Request review** from team members

### PR Requirements

Before requesting review:

- [ ] All tests pass locally
- [ ] Code follows style guidelines
- [ ] Commit messages follow conventions
- [ ] PR description is clear and complete
- [ ] Related issues are linked

### Merging PRs

- **Squash and merge** for feature branches (cleaner history)
- **Merge commit** for release branches (preserve branch history)
- **Rebase and merge** for small, clean commits

**After merging**:
- Delete the source branch
- Close related issues
- Deploy if applicable

## Protected Branches

### `main` Branch Protection

- Require pull request reviews (minimum 1)
- Require status checks to pass
- Require branches to be up to date
- No force pushes
- No deletions

### `develop` Branch Protection

- Require pull request reviews (minimum 1)
- Require status checks to pass
- Allow force pushes (with care)

## Best Practices

### Do's

- ✅ Commit often, push regularly
- ✅ Write meaningful commit messages
- ✅ Keep commits small and focused
- ✅ Pull frequently to stay updated
- ✅ Review your own changes before pushing
- ✅ Resolve conflicts promptly

### Don'ts

- ❌ Don't commit directly to `main` or `develop`
- ❌ Don't commit secrets or credentials
- ❌ Don't commit large binary files
- ❌ Don't force push to shared branches
- ❌ Don't leave branches stale for weeks
- ❌ Don't merge without review

## Emergency Procedures

### Reverting a Bad Commit

```bash
# Revert the last commit
git revert HEAD

# Revert a specific commit
git revert <commit-hash>
```

### Fixing a Bad Merge

```bash
# Reset to before the merge (if not pushed)
git reset --hard HEAD~1

# Revert the merge (if already pushed)
git revert -m 1 <merge-commit-hash>
```

### Recovering Lost Commits

```bash
# View reflog
git reflog

# Restore lost commit
git cherry-pick <commit-hash>
```

## Tools and Automation

- **Pre-commit hooks**: Run linters and tests
- **GitHub Actions**: Automated CI/CD
- **Branch protection**: Enforce workflow rules
- **CODEOWNERS**: Automatic review requests
