# Core Concepts & Error Handling Patterns

## Core Concepts

### 1. Error Handling Philosophies
**Exceptions vs Result Types:**
- **Exceptions**: Traditional try-catch, disrupts control flow (Java, Python, JS). Use for unexpected errors, exceptional conditions.
- **Result Types**: Explicit success/failure, functional approach (Rust, Elm). Use for expected errors, validation failures.
- **Error Codes**: C-style, requires discipline.
- **Option/Maybe Types**: For nullable values.
- **Panics/Crashes**: Unrecoverable errors, programming bugs.

### 2. Error Categories
- **Recoverable Errors**: Network timeouts, Missing files, Invalid user input, API rate limits.
- **Unrecoverable Errors**: Out of memory, Stack overflow, Programming bugs (null pointer, etc.).

## Language-Specific Patterns

### Python Error Handling
- **Custom Exception Hierarchy**: Base `ApplicationError`, specifics like `ValidationError`, `NotFoundError`.
- **Context Managers**: Use `contextlib` for resource cleanup (DB transactions).
- **Decorators**: Implement retry logic with exponential backoff using decorators.

### TypeScript/JavaScript Error Handling
- **Custom Error Classes**: Extend `Error` with `statusCode` and `details`.
- **Result Pattern**: Use a `Result<T, E>` type for explicit handling without try-catch.
- **Async Handling**: Proper use of `async/await` with `try-catch` blocks and handling specific error instances.

### Rust Error Handling
- **Result and Option**: Extensive use of `Result<T, E>` and `Option<T>` with pattern matching and `?` operator.
- **Custom Enums**: Define `AppError` enums for domain-specific errors.

### Go Error Handling
- **Explicit Returns**: Functions return `(value, error)`.
- **Wrapping**: Use `fmt.Errorf("... %w", err)` to wrap errors.
- **Sentinel Errors**: Predefined variables like `ErrNotFound`.

## Universal Patterns

### Pattern 1: Circuit Breaker
Prevent cascading failures in distributed systems by monitoring failure rates and "opening" the circuit to fail fast when thresholds are met.

### Pattern 2: Error Aggregation
Collect multiple errors (e.g., in form validation) instead of failing on the first one, presenting a complete list of issues to the user.

### Pattern 3: Graceful Degradation
Provide fallback functionality (e.g., cache, default values) when primary services fail to ensure the application remains partially usable.

## Best Practices
- **Fail Fast**: Validate input early.
- **Preserve Context**: Include stack traces, metadata, and timestamps.
- **Meaningful Messages**: Explain what happened and how to fix it.
- **Log Appropriately**: Expected failures shouldn't spam logs.
- **Handle at Right Level**: Catch where you can meaningfully handle (or recover).
- **Clean Up Resources**: Use try-finally, context managers, defer.
- **Don't Swallow Errors**: Log or re-throw, don't silently ignore.
