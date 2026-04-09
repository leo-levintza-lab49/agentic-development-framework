# Frontend Pull Request Requirements

## Overview

All PRs must meet these requirements before merging. Automated checks enforce most requirements, but reviewers verify adherence to all guidelines.

## Code Quality Requirements

### Test Coverage

**Minimum 70% code coverage required**

- Unit tests with React Testing Library
- Integration tests for complex user flows
- Component tests for all UI components
- Hook tests for custom React hooks

#### Testing Best Practices

```javascript
// Good: Test user behavior, not implementation
test('submits form when submit button is clicked', () => {
  render(<LoginForm />);
  fireEvent.change(screen.getByLabelText(/email/i), {
    target: { value: 'user@example.com' }
  });
  fireEvent.click(screen.getByRole('button', { name: /sign in/i }));
  expect(mockSubmit).toHaveBeenCalledWith({ email: 'user@example.com' });
});

// Bad: Testing implementation details
test('updates state when typing in email input', () => {
  const { result } = renderHook(() => useLoginForm());
  act(() => result.current.setEmail('user@example.com'));
  expect(result.current.email).toBe('user@example.com');
});
```

### Accessibility Tests

**WCAG 2.1 AA compliance required**

All PRs must include:

1. **Automated accessibility tests**
   ```javascript
   import { axe } from 'jest-axe';
   
   test('has no accessibility violations', async () => {
     const { container } = render(<MyComponent />);
     const results = await axe(container);
     expect(results).toHaveNoViolations();
   });
   ```

2. **Keyboard navigation tests**
   ```javascript
   test('can navigate form with keyboard', () => {
     render(<RegistrationForm />);
     userEvent.tab();
     expect(screen.getByLabelText(/name/i)).toHaveFocus();
     userEvent.tab();
     expect(screen.getByLabelText(/email/i)).toHaveFocus();
   });
   ```

3. **Screen reader considerations**
   - Proper ARIA labels and descriptions
   - Logical heading hierarchy
   - Focus management for dynamic content
   - Live region announcements for status updates

#### Accessibility Checklist

- [ ] All interactive elements keyboard accessible
- [ ] Focus indicators visible and meet 3:1 contrast ratio
- [ ] Color contrast meets WCAG AA (4.5:1 for text, 3:1 for UI)
- [ ] Form inputs have associated labels
- [ ] Error messages properly announced
- [ ] Images have alt text (or alt="" for decorative)
- [ ] Dynamic content changes announced to screen readers
- [ ] No keyboard traps
- [ ] Respects prefers-reduced-motion for animations

### Visual Regression Tests

**Required for component library changes**

Component library PRs must include visual regression tests:

```javascript
// playwright-visual.spec.ts
test('Button component visual regression', async ({ page }) => {
  await page.goto('/storybook/button');
  
  // Default state
  await expect(page.locator('.button-default')).toHaveScreenshot('button-default.png');
  
  // Hover state
  await page.locator('.button-default').hover();
  await expect(page.locator('.button-default')).toHaveScreenshot('button-hover.png');
  
  // Focus state
  await page.locator('.button-default').focus();
  await expect(page.locator('.button-default')).toHaveScreenshot('button-focus.png');
});
```

Visual tests automatically run on PRs labeled with `component-library`.

### Performance Budgets

**Lighthouse scores required:**

- Performance: ≥90
- Accessibility: ≥95
- Best Practices: ≥90
- SEO: ≥90

**Bundle size limits:**

- Main bundle: ≤250KB gzipped
- Route chunks: ≤100KB gzipped each
- Total bundle increase: ≤10KB per PR

Performance degradation requires justification and optimization plan.

### Code Style

**Automated enforcement:**

- ESLint (no errors, warnings acceptable with explanation)
- Prettier (automatic formatting)
- TypeScript (strict mode, no `any` types)

**Manual review:**

- Follow React best practices and hooks rules
- Proper component composition and reusability
- Clear naming conventions
- Appropriate comments for complex logic

## PR Structure Requirements

### Title

Follow conventional commit format:

```
<type>(component): <description>
```

Example: `feat(dashboard): add real-time analytics chart`

### Description Template

```markdown
## Summary
Brief description of what this PR accomplishes (1-2 sentences)

## Changes
- Bullet point list of key changes
- Each change should be a logical unit
- Include removed functionality if applicable

## Motivation
Why is this change needed? What problem does it solve?

## Screenshots/Recordings
For UI changes, include before/after screenshots or screen recordings

## Testing
How was this tested? Include:
- Unit/integration test additions
- Manual testing steps
- Browser/device testing matrix

## Accessibility
- [ ] Keyboard navigation tested
- [ ] Screen reader tested (specify which: NVDA/JAWS/VoiceOver)
- [ ] Color contrast verified
- [ ] Focus management appropriate

## Performance Impact
- Bundle size impact: [increase/decrease/neutral]
- Lighthouse score changes: [if applicable]
- Any performance optimizations included

## Design System
- Design System Version: [e.g., v2.4.0]
- Breaking changes: [Yes/No]
- Migration notes: [if applicable]

## Dependencies
- New dependencies added: [list or "none"]
- Dependency updates: [list or "none"]

## Deployment Notes
Any special considerations for deployment?
- Feature flags required?
- Environment variables needed?
- Database migrations needed?

## Related Issues
Closes #123
Relates to #456

## Checklist
- [ ] Tests added/updated and passing
- [ ] Accessibility tests passing
- [ ] Documentation updated
- [ ] Storybook stories updated (if component change)
- [ ] No console errors or warnings
- [ ] Reviewed my own code for quality
- [ ] Tested in Chrome, Firefox, Safari
- [ ] Tested on mobile viewport
```

## Component Library Specific Requirements

When modifying the component library:

1. **Documentation**
   - Update component documentation
   - Add/update Storybook stories
   - Include usage examples
   - Document props and their types

2. **Versioning**
   - Follow semantic versioning
   - Document breaking changes
   - Provide migration guide for breaking changes

3. **Additional Reviews**
   - Requires design team approval
   - Tech lead review for API changes

4. **Testing**
   - Visual regression tests required
   - Accessibility tests for all interactive states
   - Test with multiple data scenarios
   - Cross-browser testing

## Review Process

### Before Requesting Review

1. Self-review your own code
2. Run all tests locally
3. Test in multiple browsers
4. Verify accessibility with keyboard and screen reader
5. Check bundle size impact
6. Update documentation
7. Address all linter warnings

### During Review

- Respond to feedback promptly
- Explain design decisions when needed
- Be open to suggestions
- Request clarification on unclear feedback

### Approval Requirements

- **Standard PRs**: 1 approval from frontend team
- **Component library changes**: 2 approvals (frontend + design)
- **Infrastructure changes**: Tech lead approval required
- **All PRs**: All CI checks must pass (green)

### Merge Requirements

- [ ] All required approvals received
- [ ] All CI checks passing
- [ ] No merge conflicts
- [ ] Branch up to date with base branch
- [ ] All review comments resolved

## Common Rejection Reasons

PRs will be sent back for revision if they:

1. Have failing tests or CI checks
2. Reduce test coverage below 70%
3. Introduce accessibility violations
4. Exceed bundle size budgets without justification
5. Lack proper documentation or tests
6. Have TypeScript errors or use `any` types
7. Don't follow code style guidelines
8. Missing required screenshots for UI changes
9. Incomplete PR description

## Time Expectations

- **Review SLA**: Reviews started within 24 hours
- **Small PRs (<200 lines)**: Reviews completed within 1 day
- **Medium PRs (200-500 lines)**: Reviews completed within 2 days
- **Large PRs (>500 lines)**: Consider splitting or expect longer review time

## Tips for Faster Reviews

1. **Keep PRs small and focused**
   - Single logical change per PR
   - Split large features into multiple PRs
   - Easier to review = faster approval

2. **Provide context**
   - Clear description and motivation
   - Screenshots/recordings for UI changes
   - Link to design specs or requirements

3. **Test thoroughly**
   - Include comprehensive tests
   - Verify in multiple browsers
   - Test edge cases

4. **Clean code**
   - No commented-out code
   - Remove debug statements
   - Clear variable and function names

5. **Proactive communication**
   - Mention reviewers in comments for urgent items
   - Explain complex changes upfront
   - Ask questions during development, not after PR

## Related Resources

- [Branch Naming Convention](./branch-naming.md)
- [Commit Message Template](./commit-template.md)
- [Team Guide](../../docs/TEAM_GUIDE.md)
- [Design System Documentation](https://design-system.polybase.io)
- [Accessibility Guidelines](../../docs/ACCESSIBILITY.md)
