# Commit Message Template

## Overview

Well-structured commit messages help the team understand changes, facilitate code review, enable better git history navigation, and support automated release note generation.

## Format

```
<type>(platform): <subject>

<body>

<footer>
```

### Components

**Type** - Nature of the change:
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code change that neither fixes a bug nor adds a feature
- `perf` - Performance improvement
- `test` - Adding or updating tests
- `docs` - Documentation changes
- `style` - Code style changes (formatting, missing semi-colons, etc.)
- `build` - Build system or external dependency changes
- `ci` - CI/CD configuration changes
- `chore` - Other changes that don't modify src or test files

**Platform** - Target platform:
- `ios` - iOS specific
- `android` - Android specific
- `shared` - Cross-platform/shared code
- `rn` - React Native
- `deps` - Dependencies/packages

**Subject** - Brief description:
- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize first letter
- No period at the end
- Maximum 72 characters

**Body** (optional but recommended):
- Explain what and why, not how
- Include OS version compatibility notes
- Describe any breaking changes
- Reference issue numbers

**Footer** (required for breaking changes):
- `BREAKING CHANGE:` description
- `Refs:` issue references
- `Tested-On:` OS versions and devices

## Examples

### Simple Feature

```
feat(ios): add biometric authentication support

Implement Face ID and Touch ID authentication for secure login.
Uses LocalAuthentication framework with fallback to passcode.

Tested-On: iOS 15.0+, iPhone 13, iPad Pro
Refs: #245
```

### Bug Fix with Platform Details

```
fix(android): resolve crash on startup with Android 13

The app was crashing on Android 13 due to new runtime permission
requirements for notifications. Added POST_NOTIFICATIONS permission
check before scheduling notifications.

Tested-On: Android 13 (API 33), Pixel 6, Samsung S22
Refs: #412
```

### Shared Module with Breaking Changes

```
refactor(shared): update authentication API interface

BREAKING CHANGE: Auth module now requires async initialization.
Call `await Auth.initialize()` before using auth methods.

Migration:
- Replace `Auth.login()` with `await Auth.login()`
- Initialize auth module during app startup
- Update error handling to use promises

This change improves error handling and allows for async token
refresh operations across both iOS and Android platforms.

Tested-On: iOS 15.0+, Android 12+ (API 31+)
Refs: #389
```

### Performance Improvement

```
perf(ios): optimize image loading and caching

Implement progressive JPEG loading and disk-based LRU cache.
Reduces memory usage by ~40% and improves scroll performance
in image-heavy screens.

Benchmarks:
- Image grid scroll: 60fps (was 45fps)
- Memory usage: 120MB (was 200MB)
- Cache hit rate: 85%

Tested-On: iOS 14.0+, iPhone 11, iPhone 13 Pro
Refs: #298
```

### React Native Component

```
feat(rn): create reusable button component library

Add customizable button components with platform-specific styling:
- PrimaryButton, SecondaryButton, TextButton
- Support for icons, loading states, disabled states
- Accessible with proper ARIA labels
- Matches design system tokens

Tested-On: iOS 15.0+, Android 12+
Refs: #156
```

### Dependency Update with Impact

```
build(android): upgrade Kotlin to 1.9.20

Update Kotlin and related dependencies to latest stable versions.
Enables new language features and improves build performance.

Changes:
- Kotlin: 1.8.10 → 1.9.20
- Coroutines: 1.6.4 → 1.7.3
- KSP: Updated to match Kotlin version

Build time reduced by ~15%. No API changes required.

Tested-On: Android 12+ (API 31+)
Refs: #445
```

### Hotfix Example

```
fix(shared): prevent token refresh infinite loop

Critical fix for production issue where expired tokens caused
infinite refresh attempts, leading to API rate limiting and
app freezes.

Root cause: Refresh token was not being properly validated
before attempting renewal.

Solution: Add expiry check and max retry limit (3 attempts)
with exponential backoff.

BREAKING CHANGE: Auth.refreshToken() now throws
MaxRetryExceededError after 3 failed attempts.

Tested-On: iOS 14.0+, Android 11+ (API 30+)
Refs: #501
```

## OS Version Compatibility Notes

Always include compatibility information when relevant:

### iOS
```
Tested-On: iOS 15.0+
Minimum iOS: 14.0
Features requiring iOS 16: Live Activities
```

### Android
```
Tested-On: Android 12+ (API 31+)
Minimum API: 26 (Android 8.0)
Features requiring API 33: New notification permissions
```

### React Native
```
Tested-On: RN 0.71.0+
Node: 18.x
Minimum iOS: 14.0, Android API: 26
```

## Breaking Changes for Shared Modules

When modifying shared code that affects both platforms:

```
refactor(shared): change network client initialization

BREAKING CHANGE: NetworkClient is now initialized asynchronously

iOS Migration:
```swift
// Before
let client = NetworkClient()

// After
let client = await NetworkClient.initialize()
```

Android Migration:
```kotlin
// Before
val client = NetworkClient()

// After
val client = NetworkClient.initialize().await()
```

Changes affect authentication flow initialization on both platforms.
Update app startup sequence to await network client initialization.

Tested-On: iOS 15.0+, Android 12+ (API 31+)
Refs: #378
```

## Git Commit Template Setup

Add to `.gitmessage` in project root:

```
# <type>(platform): <subject>
#
# <body>
#
# Tested-On: 
# Refs: #
#
# Type: feat, fix, refactor, perf, test, docs, style, build, ci, chore
# Platform: ios, android, shared, rn, deps
#
# Subject: imperative mood, lowercase, no period, max 72 chars
# Body: what and why, not how. Include OS compatibility notes.
# Footer: breaking changes, issue refs, test platforms
```

Configure git to use it:

```bash
git config commit.template .gitmessage
```

## Commit Hooks

Pre-commit hook validates commit message format:

```bash
#!/bin/bash
# .git/hooks/commit-msg

commit_msg=$(cat "$1")
pattern="^(feat|fix|refactor|perf|test|docs|style|build|ci|chore)\((ios|android|shared|rn|deps)\): .{1,72}$"

first_line=$(echo "$commit_msg" | head -n 1)

if ! echo "$first_line" | grep -Eq "$pattern"; then
    echo "Error: Commit message doesn't follow format"
    echo "Expected: <type>(platform): <subject>"
    echo "Got: $first_line"
    exit 1
fi
```

## Automated Release Notes

Our CI system generates release notes from commit messages:

- `feat` commits → "New Features" section
- `fix` commits → "Bug Fixes" section
- `perf` commits → "Performance Improvements" section
- `BREAKING CHANGE` → Highlighted at top

Example:

```markdown
## v2.5.0 (2026-04-09)

### Breaking Changes
- refactor(shared): Auth module now requires async initialization (#389)

### New Features (iOS)
- feat(ios): add biometric authentication support (#245)
- feat(ios): implement live activities for order tracking (#267)

### New Features (Android)
- feat(android): add predictive back gesture support (#289)

### Bug Fixes
- fix(ios): resolve memory leak in image cache (#234)
- fix(android): crash on startup with Android 13 (#412)

### Performance Improvements
- perf(ios): optimize image loading and caching (#298)
```

## Best Practices

1. **One logical change per commit** - Don't mix refactoring with features
2. **Write for future you** - Someone will debug this at 2am
3. **Include test information** - What devices/OS versions were tested
4. **Link to issues** - Provide context with issue references
5. **Explain breaking changes clearly** - Include migration instructions
6. **Use imperative mood** - "add feature" not "added feature"
7. **Test on multiple OS versions** - Especially for shared code
8. **Document platform-specific quirks** - Note workarounds or limitations

## FAQ

**Q: Should I reference Jira/Linear tickets?**  
A: Yes, in the footer with `Refs: PROJ-123` format.

**Q: How detailed should the body be?**  
A: Include enough detail that reviewers understand the "why" without reading code.

**Q: What if I forgot to include something?**  
A: For unpushed commits, use `git commit --amend`. For pushed commits, add a follow-up commit.

**Q: Should I squash commits before merging?**  
A: Follow team policy. Generally, squash feature commits but keep meaningful history for complex changes.

**Q: How do I handle commits that touch multiple platforms?**  
A: Use `(shared)` for the platform identifier and list all affected platforms in the body.

## References

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
- [Semantic Release](https://semantic-release.gitbook.io/)
- Mobile Team Runbook: `/docs/runbook.md`
