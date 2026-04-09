# Frontend Commit Message Template

## Format

```
<type>(component): <subject>

<body>

<footer>
```

## Type

Must be one of the following:

- **feat**: New feature or enhancement
- **fix**: Bug fix
- **style**: UI/UX changes (not code style)
- **refactor**: Code restructuring without changing functionality
- **perf**: Performance improvement
- **test**: Adding or updating tests
- **docs**: Documentation changes
- **build**: Build system or dependency changes
- **ci**: CI/CD configuration changes
- **chore**: Maintenance tasks
- **a11y**: Accessibility improvements

## Component (Scope)

The component area being modified (same as branch naming):

- dashboard, auth, orders, payments, products
- components, design-system, forms, navigation
- state, api, i18n, a11y, etc.

## Subject

- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize first letter
- No period at the end
- Maximum 72 characters
- Be specific and descriptive

## Body (Optional but Recommended)

- Explain the "what" and "why", not the "how"
- Wrap at 72 characters per line
- Include motivation for the change
- Contrast current vs. previous behavior

### Required Body Elements for Certain Changes

**For accessibility changes:**
```
Accessibility Impact:
- [Description of how this improves accessibility]
- WCAG 2.1 Level: [A/AA/AAA]
- Assistive tech tested: [Screen readers, keyboard nav, etc.]
```

**For component library changes:**
```
Design System Version: [e.g., v2.3.0]
Breaking Changes: [Yes/No - if yes, describe]
Migration Guide: [Link or brief description]
```

**For performance optimizations:**
```
Performance Impact:
- Before: [metrics]
- After: [metrics]
- Improvement: [percentage or description]
```

## Footer (Optional)

- Reference related issues: `Closes #123` or `Relates to #456`
- Note breaking changes: `BREAKING CHANGE: description`
- Credit contributors: `Co-authored-by: Name <email>`

## Examples

### Feature Addition

```
feat(dashboard): add real-time analytics chart

Implement WebSocket-based real-time data updates for the analytics
dashboard. Chart automatically refreshes when new data arrives without
requiring page reload.

Design System Version: v2.4.0
Component: LineChart with real-time data adapter

Closes #234
```

### Bug Fix

```
fix(auth): prevent login redirect loop

Users were getting stuck in redirect loop when accessing protected
routes while unauthenticated. Fixed by properly clearing auth state
and using replace instead of push for navigation.

The issue occurred because the auth middleware was checking stale
token data. Now properly validates token expiration before redirect.

Closes #456
```

### Accessibility Improvement

```
a11y(forms): improve error message announcements

Enhanced form error handling to properly announce validation errors
to screen readers using ARIA live regions.

Accessibility Impact:
- Error messages now announced immediately on validation
- WCAG 2.1 Level: AA (3.3.1 Error Identification)
- Tested with: NVDA, JAWS, VoiceOver
- Keyboard navigation flow preserved

Previous implementation only showed visual errors without proper
ARIA attributes, making forms difficult for screen reader users.

Closes #789
```

### Style Update

```
style(components): update button hover states

Redesigned button hover and focus states to match new brand guidelines.
Improved visual feedback and ensured sufficient color contrast.

Design System Version: v2.5.0
Breaking Changes: No
Updated components: Button, IconButton, LinkButton

Accessibility Impact:
- Maintained 4.5:1 contrast ratio for all states
- Added focus-visible styles for keyboard navigation
- WCAG 2.1 Level: AA compliant
```

### Performance Optimization

```
perf(products): implement virtual scrolling for product list

Replaced standard list rendering with virtual scrolling for product
catalog. Significantly improves performance when displaying large
product sets.

Performance Impact:
- Before: ~2000ms initial render (500 products)
- After: ~300ms initial render (500 products)
- Improvement: 85% faster, maintains 60fps scrolling

Uses react-window for efficient windowing. Only renders visible items
plus small buffer, dramatically reducing DOM nodes.

Closes #321
```

### Refactoring

```
refactor(state): migrate from Redux to Zustand

Simplified state management by replacing Redux with Zustand.
Reduces boilerplate and improves developer experience while
maintaining the same functionality.

Benefits:
- 40% less code in state management layer
- No more action creators and reducers boilerplate
- Better TypeScript inference
- Simpler testing

Migration maintains backward compatibility with existing
component interfaces. No UI changes or functionality differences.

Relates to #567
```

### Component Library Update

```
feat(components): add skeleton loading components

Add new Skeleton component family for loading states throughout
the application. Provides better UX during data fetching.

Design System Version: v2.6.0
Components added:
- Skeleton (base)
- SkeletonText
- SkeletonImage
- SkeletonCard

Usage:
- Replaces generic spinners in cards and lists
- Maintains layout during loading
- Accessible with proper ARIA labels

Accessibility Impact:
- aria-busy and aria-live attributes included
- Respects prefers-reduced-motion
- Sufficient contrast for shape visibility

Closes #890
```

## Common Mistakes to Avoid

### Bad Examples

```
# Too vague
fix: bug fixes

# Wrong tense
feat(dashboard): added new chart

# Capitalized subject
feat(auth): Add login button

# Period at end
fix(orders): resolve display issue.

# Missing component
feat: new feature

# Too long subject (>72 chars)
feat(products): add new product filtering system with advanced search capabilities and sorting
```

## Validation

Commit messages are validated using commitlint. Non-compliant commits will be rejected with guidance on the correct format.

## Tools

Consider using:
- `git commit` with template flag
- Commitizen CLI for guided commits
- IDE plugins for commit message formatting

## Related Resources

- [Branch Naming Convention](./branch-naming.md)
- [PR Requirements](./pr-requirements.md)
- [Team Guide](../../docs/TEAM_GUIDE.md)
