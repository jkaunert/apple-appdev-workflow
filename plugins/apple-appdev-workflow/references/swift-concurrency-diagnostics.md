# Swift Concurrency Diagnostics

Use this reference to map strict-concurrency errors to likely fixes.

## Common diagnostics
- Sending a value risks causing data races:
  - check whether the value truly crosses isolation
  - prefer actors, `sending`, or genuine `Sendable` conformance before unsafe suppression
- Static or global property is not concurrency-safe:
  - isolate shared state, often on `@MainActor` for app code, or move mutable state behind an actor
- Capture of non-Sendable type in `@Sendable` closure:
  - avoid broad captures, pass smaller values, or redesign the boundary
- Main actor-isolated API used from nonisolated context:
  - either move the caller onto the correct actor or redesign the boundary
- Actor-isolated protocol conformance mismatch:
  - prefer isolated conformances when the protocol behavior belongs on the actor

## Review priority
1. data races and isolation mismatches
2. actor reentrancy risks
3. unstructured task leakage or lost cancellation
4. unsafe escape hatches
