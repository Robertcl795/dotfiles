---
applyTo: "apps/**/*.html,libs/**/*.html"
---
# HTML Templates Instructions

This Angular enterprise application requires secure, optimized, and maintainable HTML templates. Review template files with focus on security, performance, and @covalent component usage.

## File Patterns

- `apps/**/*.html`
- `libs/**/*.html`

## Standards & Best Practices

- Use @covalent/components library components whenever possible
- Include Playwright test attributes (`data-pw`, `data-playwright-id`) for e2e testing
- Suggest OnPush change detection strategy for performance when applicable
- Use reactive forms (`FormControl`, `FormGroup`) over template-driven forms
- Avoid inline styles; use CSS classes instead
- Ensure proper use of Angular directives (`@if`, `@for`, etc.)
- Avoid complex logic in templates; move to component class
- Use Angular pipes for data transformation
- Use Angular pipes for translation (i18n)
- Avoid deep nesting of HTML elements
- Use async pipe (`| async`) with observables in templates
- Leverage `ng-container` and `ng-template` for structural patterns
- Use `[ngClass]` and `[ngStyle]` conditionally instead of many property bindings
- Implement trackBy functions with ngFor to optimize rendering
- Prefer `*ngIf="observable$ | async as value"` pattern
- Use content projection (`ng-content`) for reusable components

## Review Focus

- DO focus on template security (no unsafe bindings)
- DO focus on performance optimizations
- DO focus on proper reactive patterns with observables/signals
- DO focus on change detection optimization
- DO focus on Playwright test attributes
- DO focus on @covalent component usage
- DO suggest @covalent components instead of angular material or custom implementations
- DO focus on template complexity management
- DO focus on translation/i18n practices, no static text is acceptable
- DO suggest improvements for maintainability and readability
- DO NOT suggest business logic in templates
- DO NOT suggest accessibility improvements (aria attributes, keyboard nav)
- DO NOT focus on roles, slots, tabindex, or keydown handlers
- DO NOT suggest aria-controls or aria-label additions
- DO NOT focus on minor styling/formatting if business logic is sound
- DO NOT focus on minor naming issues if functionality is clear

## Security Considerations

- Avoid direct DOM manipulation
- Use Angular's built-in sanitization for dynamic content
- Be cautious with [innerHTML] bindings
- Don't pass unsanitized user input to templates
- Check for potential XSS vulnerabilities
- Check for proper external link handling
- Avoid using bypassSecurityTrust* methods unless absolutely necessary and input is validated
- Validate and sanitize data before property/attribute bindings
- Avoid dynamic component/template compilation with user input
- Check for open redirects in navigation/routing logic
- Validate file upload handling and MIME type restrictions
- Ensure proper escaping in interpolations with user data
