# Swift Testing Isolation and Async

Use this reference for flaky tests, callback bridging, async waiting, and shared-state remediation.

## Default execution model
- Swift Testing runs tests in parallel by default.
- Randomized execution helps expose hidden ordering dependencies.
- Treat parallel safety as the default target.

## Isolation-first guidance
- Remove hidden shared mutable state before considering `.serialized`.
- Prefer fresh test-local state, in-memory repositories, and explicit dependency injection.
- Keep globals, singletons, file-system state, and shared databases out of the fast path unless isolated per test.

## `.serialized` policy
- Use `.serialized` only as a targeted transition tool.
- Document why it is needed when used.
- Do not apply it broadly to paper over shared-state bugs.

## Async guidance
- Prefer native async tests for async code.
- Use `confirmation()` or equivalent bridging patterns for callback-based APIs.
- Keep async waits deterministic and bounded.
- Validate actor or main-thread behavior when correctness depends on it.
