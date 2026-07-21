# Swift Concurrency Actors and Sendable

Use this reference when choosing actor boundaries, main-actor isolation, or Sendable strategy.

## Actor guidance
- Keep actor responsibilities narrow and centered on mutable shared state.
- Watch for reentrancy when actor methods read state, await, then write state.
- Prefer isolated conformances over pushing actor-owned protocol behavior into nonisolated code.

## `@MainActor` guidance
- Use it for UI-owned models and state transitions that must remain on the main actor.
- Do not use it as a blanket fix for all concurrency warnings.
- Revisit CPU-heavy work that accidentally remains on the main actor.

## Sendable guidance
- Prefer immutable value types or genuinely safe final classes.
- Avoid `@unchecked Sendable` unless internal synchronization is explicit and reviewable.
- Reduce closure captures before adding conformance.
