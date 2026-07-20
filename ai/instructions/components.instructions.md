---
applyTo: "apps/**/*.component.ts,libs/**/*.component.ts"
---
# Component Source Code Instructions

This Angular enterprise application requires optimized, maintainable component logic. Review component source files with focus on performance, reactivity, and architecture.

## File Patterns

- `apps/**/*.component.ts`
- `libs/**/*.component.ts`

## Standards & Best Practices

- Prefer OnPush change detection strategy implementation for components
- Allow OnInit for complex initialization logic, if it clearly benefits from a dedicated lifecycle method
- Discourage OnDestroy if it's only used for RxJS cleanup, prefer takeUntilDestroyed() or DestroyRef instead
- Encourage constructor initializations for complex initializations
- Extract complex algorithmic logic into utility functions
- Use proper dependency injection patterns
- Follow container/presentational component pattern
- Prefer signals and observable state over direct property mutation
- Implement proper error handling for async operations
- Use `@Input()` decorator or `input()` signal setters for derived property calculations
- Leverage pure pipes for expensive calculations
- Keep component methods small and focused
- Use decorators appropriately (@HostListener, @ViewChild, etc.)
- Properly type all properties and methods
- Implement proper change detection handling for @covalent components

## Review Focus

- DO focus on change detection optimization
- DO focus on memory leak prevention
- DO focus on proper reactive patterns
- DO focus on component performance
- DO focus on state management approaches
- DO focus on component composition
- DO focus on proper dependency injection
- DO focus on proper typing
- DO focus on module federation boundaries
- DO focus on error handling completeness
- DO focus on initialization logic
- DO focus on proper event handling
- DO focus on code complexity reduction
- DO focus on cross-component communication patterns
- DO NOT focus on minor formatting issues
- DO NOT suggest extensive refactoring without clear benefits
- DO NOT suggest pattern changes that conflict with established codebase

## Architecture Patterns

- Smart components (containers): manage state and data fetching
- Presentational components: focus on UI rendering, minimal logic
- Utilities: handle complex calculations, transformations, and business logic
- State management: prefer observables/signals over direct mutation
- Lazy loading: implement proper module boundaries
- Module federation: maintain proper remote module interfaces

## Performance Considerations

- Avoid expensive calculations in change detection cycle
- Prefer OnPush strategy implementations
- Extract complex algorithms to utility functions
- Properly manage subscriptions to prevent memory leaks
- Use shareReplay() to prevent duplicate HTTP requests
- Consider lazy-loading patterns for heavy services
- Implement debouncing/throttling for frequent service calls
- Avoid deep component hierarchies
- Consider web workers for CPU-intensive operations
- Use appropriate change detection triggers
- Minimize DOM interactions
