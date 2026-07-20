---
applyTo: "./**/*.scss"
---
# SCSS Instructions

This Angular enterprise application uses SCSS for component styling. Review stylesheet files with focus on maintainability, performance, and consistency.

## File Patterns

- `*.scss`

## Standards & Best Practices

- Use SCSS variables for colors, spacing, and typography
- Use `@covalent` theme variables where possible
- Implement nested selectors (max 3 levels deep)
- Use mixins for reusable style patterns
- Use placeholder selectors (`%placeholder`) for shared styles
- Use `&` for parent selector references
- Keep component styles encapsulated (avoid global styles)
- Keep specificity low to avoid override issues
- Use grid/flex for layouts rather than absolute positioning
- Leverage BEM naming conventions for style composition


## Review Focus

- DO focus on proper use of SCSS features (variables, mixins, functions)
- DO focus on selector specificity and potential conflicts
- DO focus on style organization and maintainability
- DO focus on potential performance issues (complex selectors, animations)
- DO focus on consistent units (px, rem, em, %)
- DO suggest optimization for repeated style patterns
- DO NOT focus on design aesthetic choices
- DO NOT suggest global style changes in component files
- DO NOT focus on minor formatting if style functionality is sound
- DO NOT suggest extensive refactoring if styles are working properly

## Performance Considerations

- Be cautious with shadow DOM boundary-crossing selectors
- Limit use of expensive CSS properties (box-shadow, filter, etc.)
- Prefer transform/opacity for animations
