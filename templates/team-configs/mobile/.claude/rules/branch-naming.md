# Branch Naming Convention

## Overview

Mobile team branches must follow a structured naming pattern that clearly identifies the platform and purpose of the work. This helps with code organization, CI/CD automation, and team coordination.

## Pattern

```
<type>/<platform>/<description>
```

### Components

**Type** - The nature of the work being done:
- `feature` - New functionality or capabilities
- `fix` - Bug fixes or corrections
- `refactor` - Code restructuring without changing behavior
- `chore` - Maintenance tasks, dependency updates
- `hotfix` - Critical production fixes
- `release` - Release preparation branches

**Platform** - The target platform(s):
- `ios` - iOS-specific code (Swift, Objective-C)
- `android` - Android-specific code (Kotlin, Java)
- `shared` - Cross-platform code affecting both iOS and Android
- `rn` - React Native specific changes
- `infra` - Build tools, CI/CD, configuration

**Description** - Brief, kebab-case description of the work:
- Use lowercase with hyphens
- Be specific but concise
- Maximum 50 characters
- No ticket numbers (use PR description for that)

## Examples

### Good Examples

```bash
feature/ios/push-notifications
fix/android/crash-on-startup
refactor/shared/network-layer
feature/rn/user-profile-screen
fix/ios/memory-leak-image-cache
chore/android/upgrade-kotlin-1.9
hotfix/shared/authentication-token
release/ios/v2.5.0
feature/shared/biometric-auth
refactor/infra/fastlane-automation
```

### Bad Examples

```bash
# ❌ No type specified
ios/push-notifications

# ❌ No platform specified
feature/add-notifications

# ❌ Too vague
fix/bug

# ❌ Includes ticket number
feature/ios/JIRA-1234-push-notifications

# ❌ CamelCase instead of kebab-case
feature/ios/PushNotifications

# ❌ Underscores instead of hyphens
feature/ios/push_notifications

# ❌ Too long
feature/ios/implement-advanced-push-notification-system-with-rich-media
```

## Platform Selection Guidelines

### When to use `ios`
- Changes only affect iOS codebase
- Swift or Objective-C files
- iOS-specific UI/UX implementations
- iOS framework integrations
- Xcode project configuration

### When to use `android`
- Changes only affect Android codebase
- Kotlin or Java files
- Android-specific UI/UX implementations
- Android library integrations
- Gradle configuration

### When to use `shared`
- Code changes affecting both platforms
- Native module interfaces
- Business logic shared across platforms
- API client changes
- Database schema modifications
- Shared utility functions
- Protocol/interface definitions

### When to use `rn`
- React Native component changes
- JavaScript/TypeScript code
- React Native navigation
- State management (Redux, MobX, etc.)
- React Native configuration
- Metro bundler settings

### When to use `infra`
- CI/CD pipeline changes
- Build scripts
- Fastlane configuration
- Code signing setup
- Testing infrastructure
- Linting/formatting rules

## Branch Lifecycle

### Creating a Branch

```bash
# From main/develop branch
git checkout main
git pull origin main

# Create new branch with proper naming
git checkout -b feature/ios/push-notifications
```

### Working on Multiple Platforms

If your work spans multiple platforms, create separate branches:

```bash
# iOS implementation
feature/ios/push-notifications

# Android implementation
feature/android/push-notifications

# Shared native module
feature/shared/push-notification-module
```

Coordinate PRs so they can be merged together or in sequence.

## CI/CD Integration

Our CI system uses branch names to determine which jobs to run:

- Branches with `ios` → Trigger iOS build and tests
- Branches with `android` → Trigger Android build and tests
- Branches with `shared` → Trigger both iOS and Android builds
- Branches with `rn` → Trigger React Native tests and both platform builds

## Branch Protection

Certain patterns have additional requirements:

- `hotfix/*` - Requires approval from team lead
- `release/*` - Requires passing all CI checks + manual QA sign-off
- `*/shared/*` - Requires review from both iOS and Android teams

## Cleaning Up

Delete branches after merging:

```bash
# After PR is merged
git branch -d feature/ios/push-notifications
git push origin --delete feature/ios/push-notifications
```

## Tools

### Branch Name Validator

A pre-push hook validates branch names:

```bash
#!/bin/bash
# .git/hooks/pre-push

branch=$(git symbolic-ref --short HEAD)
pattern="^(feature|fix|refactor|chore|hotfix|release)/(ios|android|shared|rn|infra)/[a-z0-9-]+$"

if ! echo "$branch" | grep -Eq "$pattern"; then
    echo "Error: Branch name '$branch' doesn't follow naming convention"
    echo "Expected: <type>/<platform>/<description>"
    exit 1
fi
```

### Branch Creation Helper

```bash
# Add to your shell profile
function new-mobile-branch() {
    local type=$1
    local platform=$2
    local description=$3
    
    if [ -z "$type" ] || [ -z "$platform" ] || [ -z "$description" ]; then
        echo "Usage: new-mobile-branch <type> <platform> <description>"
        echo "Example: new-mobile-branch feature ios push-notifications"
        return 1
    fi
    
    git checkout -b "$type/$platform/$description"
}
```

## FAQ

**Q: What if my change affects iOS, Android, AND React Native?**  
A: Use `shared` as the platform since it impacts all layers of the stack.

**Q: Can I use slashes in the description?**  
A: No, only use hyphens to separate words in the description.

**Q: Should I include the ticket number?**  
A: No, include ticket references in PR descriptions and commit messages, not branch names.

**Q: What if I'm working on documentation only?**  
A: Use `chore/infra/description` for documentation changes.

**Q: How do I handle a branch that started as iOS but expanded to shared?**  
A: Create a new branch with the correct name and cherry-pick your commits, or rename the branch if no PR exists yet.

## References

- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Git Branch Naming Best Practices](https://dev.to/couchcamote/git-branching-name-convention-cch)
- Mobile Team Runbook: `/docs/runbook.md`
