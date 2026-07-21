# Persistence Output Contract

Use this reference for persistence brigade output.

Treat this summary shape as the intended product-default behavior for broad persistence recommendation work, not merely a trace-validation format.

The final user-facing persistence summary should use these exact sections in this order:

1. `Routing`
2. `Activated skills`
3. `Persistence scope`
4. `Discovery findings`
5. `Persistence assessment`
6. `Coordinated recommendations`
7. `Migration and rollout notes`
8. `Direct follow-on lanes`

## Section intent

### `Routing`

Must start with:

```text
Routing: orchestrator-led
```

### `Activated skills`

Must explicitly name:

1. `apple-appdev-workflow:apple-app-orchestrator`
2. `apple-appdev-workflow:apple-persistence-orchestrator`
3. each persistence station that materially shaped the answer

### `Persistence scope`

State:

1. whether the pass was design-only, review-oriented, or mixed
2. whether the task covered SwiftData only, Core Data only, or coexistence

### `Discovery findings`

State:

1. persistence seams already present
2. whether migration, history, or coexistence is already implied by the current codebase

### `Persistence assessment`

State:

1. the highest-level persistence judgment
2. whether the main risk is schema shape, migration safety, rollout risk, or coexistence complexity

### `Coordinated recommendations`

State:

1. what should change first
2. what should stay narrow specialist work

### `Migration and rollout notes`

State:

1. migration safety implications
2. rollout risk
3. data-loss or compatibility warnings

### `Direct follow-on lanes`

State:

1. which specialist station should handle the next narrow task

## Guardrails

1. Do not emit implementation-oriented headings such as `Outcome`, `Validation Executed`, or `Branch-Diff Review Status` for non-mutating persistence review work.
2. Do not let `apple-appdev-workflow:apple-swiftdata-foundations` or `apple-appdev-workflow:apple-swiftdata-review` narrate the final answer directly once the brigade is active.
3. Do not use broad persistence review prompts as implicit permission to mutate code.
