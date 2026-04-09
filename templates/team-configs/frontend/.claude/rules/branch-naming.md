# Frontend Branch Naming Convention

## Pattern

All branches must follow this pattern:

```
<type>/<component>/<description>
```

## Branch Types

- **feature**: New functionality or enhancements
- **fix**: Bug fixes and corrections
- **style**: UI/UX improvements, styling changes, design system updates
- **refactor**: Code restructuring without changing functionality
- **perf**: Performance optimizations
- **test**: Adding or updating tests
- **docs**: Documentation updates
- **chore**: Maintenance tasks, dependency updates

## Component Areas

Specify the primary area of the codebase being modified:

- **dashboard**: Dashboard pages and widgets
- **auth**: Authentication and authorization flows
- **orders**: Order management interface
- **payments**: Payment processing UI
- **products**: Product catalog and details
- **components**: Shared component library
- **design-system**: Design system updates
- **forms**: Form components and validation
- **navigation**: Navigation, routing, menus
- **settings**: User and application settings
- **analytics**: Analytics and reporting views
- **notifications**: Notification system
- **search**: Search functionality
- **api**: API integration layer
- **state**: State management (Redux/Zustand)
- **i18n**: Internationalization
- **a11y**: Accessibility improvements

## Description

- Use kebab-case (lowercase with hyphens)
- Be specific and descriptive
- Keep it concise (2-5 words)
- Use present tense verbs

## Examples

### Good Examples

```
feature/dashboard/analytics-chart
fix/auth/login-redirect-error
style/components/button-hover-state
refactor/orders/split-order-hooks
perf/products/lazy-load-images
feature/payments/stripe-integration
fix/navigation/mobile-menu-overflow
style/design-system/update-spacing-tokens
test/components/add-button-tests
a11y/forms/improve-error-messages
```

### Bad Examples

```
fix-bug                          # Missing component area
feature/NewFeature               # Use kebab-case, not PascalCase
updates                          # Missing type and component
feature/dashboard/add-new-chart-component-to-analytics-page  # Too long
fix/misc/stuff                   # Not descriptive enough
dashboard-updates                # Missing type
```

## Special Cases

### Hotfixes

For urgent production fixes:
```
hotfix/<component>/<description>
```

Example: `hotfix/payments/critical-checkout-error`

### Experimental Features

For experimental or research work:
```
experiment/<component>/<description>
```

Example: `experiment/dashboard/ai-recommendations`

### Design System Updates

For design system version upgrades:
```
style/design-system/v<version>-migration
```

Example: `style/design-system/v3-migration`

## Multi-Component Changes

If your branch affects multiple major components, choose the primary component area and mention others in the PR description. Consider splitting into multiple PRs if the changes are logically separable.

## Validation

Branch names are automatically validated on push. Non-compliant branches will be rejected with a helpful error message suggesting the correct format.

## Related Resources

- [Commit Message Template](./commit-template.md)
- [PR Requirements](./pr-requirements.md)
- [Team Guide](../../docs/TEAM_GUIDE.md)
