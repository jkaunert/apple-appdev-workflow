---
name: apple-swift-concurrency-foundations
description: Swift Concurrency foundations for Apple projects. Use when writing, migrating, or modernizing async code; defining actor or Sendable boundaries; converting callbacks to async/await; fixing isolation or cancellation issues; or adopting Swift 6 concurrency settings safely.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Swift Concurrency Foundations

## Required context
- Load `../../references/swift-concurrency-foundations.md`.
- Load `../../references/swift-concurrency-migration.md` when concurrency settings, Swift 6 migration, or strict concurrency rollout is involved.
- Load `../../references/swift-concurrency-actors-and-sendable.md` when actor boundaries, `@MainActor`, isolated conformances, shared state, or `Sendable` are involved.
- Load `../../references/swift-concurrency-tasks-and-cancellation.md` when tasks, task groups, cancellation, or SwiftUI `.task` usage are involved.
- Load `../../references/swift-concurrency-interop-and-streams.md` when continuations, delegate or callback bridging, GCD or Core Data interop, Combine interop, or async streams are involved.
- Load `../../references/swift-concurrency-swift-6-2.md` only when the project's settings indicate Swift 6.2 or approachable concurrency features are relevant.
- Load `../../references/swift-concurrency-testing.md` when concurrency-sensitive tests or validation strategy need to be updated.

## Responsibilities
- Own implementation and migration guidance for Swift Concurrency in Apple code.
- Require settings intake before giving migration-sensitive advice: Swift version, strict concurrency level, default actor isolation, and approachable concurrency mode.
- Prefer structured concurrency and explicit isolation boundaries over ad hoc task spawning.
- Treat `@MainActor`, `@unchecked Sendable`, `@preconcurrency`, and `nonisolated(unsafe)` as exceptional choices that require explicit justification.
- Hand diagnostics-led review output to `apple-appdev-workflow:apple-swift-concurrency-review` and execution or release gates to existing Apple skills.

## Workflow
1. Determine whether the task is new async code, migration, remediation, interop, or performance-sensitive concurrency design.
2. Capture project concurrency settings before choosing fixes that depend on language mode or default isolation behavior.
3. Identify the intended isolation boundary: UI-bound `@MainActor`, actor isolation, isolated conformance, or genuinely nonisolated work.
4. Apply the smallest safe concurrency fix that preserves behavior.
5. Prefer structured concurrency, cancellation-aware code, and explicit ownership of shared mutable state.
6. Escalate to `apple-appdev-workflow:apple-swift-concurrency-review` when the task is diagnostics-heavy, review-first, or hotspot remediation.
7. Hand testing updates to `apple-appdev-workflow:apple-swift-testing-foundations` and `apple-appdev-workflow:apple-testing-quality-gates` when concurrency-sensitive validation changes are needed.

## Output contract
- Concurrency settings assumed or discovered
- Recommended isolation boundary and why
- Minimal safe implementation or migration approach
- Risks, escape hatches, and required follow-up if exceptional annotations are used
- Concurrency-sensitive testing implications when relevant

## Guardrails
- Do not assume Swift 6.2 or approachable concurrency unless settings justify it.
- Do not recommend blanket `@MainActor` as a migration shortcut.
- Do not solve shared-state problems with unstructured tasks.
- Do not suggest `@unchecked Sendable` unless the thread-safety invariant is explicit and reviewable.
