# Swift Concurrency Foundations

Use this reference for the default concurrency model in Apple projects.

## Settings intake before advice
Before choosing migration-sensitive fixes, determine:
- Swift language mode
- strict concurrency setting
- default actor isolation
- whether approachable concurrency or related upcoming features are enabled

## Default policy
- Prefer structured concurrency over unstructured tasks.
- Prefer explicit isolation boundaries over thread-centric reasoning.
- Prefer actors or isolated state over shared mutable globals.
- Treat UI-bound code as `@MainActor` only when it is genuinely UI-owned.

## Boundary selection
- `@MainActor` for UI models, view-driven state, and UI-owned coordination.
- custom actors for shared mutable state that must be protected off the main actor.
- nonisolated work only when the code is truly safe and intended to run outside actor protection.
- isolated conformances when protocol requirements should stay on the actor.

## Escape-hatch policy
- `@unchecked Sendable`, `@preconcurrency`, and `nonisolated(unsafe)` are last resorts.
- If one is used, document the safety invariant and a follow-up plan.
