---
applyTo: "./**/*.util.ts"
---
# Utils Instructions

This Angular enterprise application uses utility functions for shared logic and complex algorithms. Review utility files with focus on reusability, performance, and testability.

## File Patterns

- `*.util.ts`

## Standards & Best Practices

- Implement pure functions whenever possible (no side effects)
- Properly type all parameters and return values
- Use generics for flexible, reusable utility functions
- Move CPU-intensive algorithms to Web Workers when appropriate
- Provide meaningful JSDoc comments for complex functions
- Export all functions individually (not as default exports)
- Keep functions focused on single responsibility
- Group related utilities in the same file
- Implement proper error handling and edge cases
- Optimize performance for frequently called utilities
- Use appropriate data structures for performance

## Review Focus

- DO focus on function purity and side effect avoidance
- DO focus on proper typing and type safety
- DO focus on edge case handling
- DO focus on algorithmic efficiency
- DO focus on identifying CPU-intensive operations for worker offloading
- DO focus on reusability across the application
- DO focus on proper error messaging
- DO suggest performance optimizations for complex algorithms
- DO focus on function complexity (suggest breaking down complex functions)
- DO NOT suggest adding state management to utilities
- DO NOT suggest changing utilities to services without clear reason
- DO NOT focus on minor formatting if functionality is sound

## Implementation Considerations

- Memoize expensive calculations when appropriate
- Use Web Workers for CPU-intensive operations that could block the UI thread
- Design worker-friendly utilities with serializable inputs/outputs
- Consider structured cloning limitations when passing data to/from workers
- Use early returns for edge cases
- Implement proper parameter validation
- Consider lazy evaluation for expensive operations
- Use functional programming patterns where appropriate
- Properly document complex algorithms with comments
- Consider browser compatibility for platform-specific utilities

## Worker Considerations

- Extract CPU-intensive algorithms to separate files for worker usage
- Design utilities to work both in and out of worker context when possible
- Implement proper messaging patterns for worker communication
- Consider worker pools for managing multiple intensive operations
- Add fallback mechanisms when workers aren't supported

## Testing Recommendations

- Ensure high test coverage for utility functions
- Test edge cases thoroughly
- Use property-based testing for math/algorithm utilities
- Benchmark performance-critical utilities
