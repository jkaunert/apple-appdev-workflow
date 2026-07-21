---
name: apple-persistence-orchestrator
description: Persistence-domain expediter for broad Apple persistence review, migration strategy, coexistence planning, and rollout-risk work spanning SwiftData and Core Data. Use this first for recommendation-first prompts about migration approach, data-loss risk, rollout risk, or what should change first, even when SwiftData is the main persistence surface.
metadata:
  role: brigade-orchestrator
  entrypoint: delegated
  routing_scope: domain
---

# Apple Persistence Orchestrator

## Required context
- Load `../../references/persistence-orchestration-flow.md`.
- Load `../../references/persistence-evidence-aggregation.md`.
- Load `../../references/persistence-output-contract.md`.
- Load `../../references/persistence-brigade-trace-template.md` for non-mutating persistence review and recommendation passes.
- Load `../../references/apple-skill-orchestration.md`.
- Load `../../references/brigade-output-contract.md`.

## Entry rule
- Use this skill after `apple-appdev-workflow:apple-app-orchestrator` scopes a broad persistence workflow.
- Direct use is acceptable for focused internal validation of the persistence brigade, but broad user-facing Apple workflows should still begin with `apple-appdev-workflow:apple-app-orchestrator`.
- When activated by `apple-appdev-workflow:apple-app-orchestrator`, this skill owns persistence-domain sequencing and the required brigade shape, but it returns that structure to the parent orchestrator. It does not replace the parent route block or final-answer ownership.
- When this skill is active, it is the sole final narrator for broad persistence work at the domain layer.
- The current brigade summary shape is the intended product-default behavior for broad recommendation-first persistence work. Do not treat it as a temporary acceptance convenience.
- For direct, trace-sensitive brigade validation, emit the literal first routing block from `../../references/persistence-brigade-trace-template.md` and apply the shared no-preamble rules in `../../references/brigade-output-contract.md`.

## Scope
Use this skill when the request is about:
- broad persistence review
- persistence model and migration review with rollout or data-loss risk framing
- SwiftData and Core Data coexistence strategy
- persistence architecture and risk work that spans more than one persistence specialist
- deciding what should change first in persistence before rollout, migration, or release-sensitive work

Keep narrow SwiftData review, narrow Core Data debugging, and isolated schema work out of this brigade unless the task explicitly expands into multi-station persistence coordination.

## Workflow
1. For direct, non-mutating review or recommendation passes, emit the exact first structured routing block from `../../references/persistence-brigade-trace-template.md` before any other bundle-authored progress update.
2. Start with a discovery-first persistence scan of the effective working root, current persistence seams, storage technologies in play, and the specific risks in scope.
3. Confirm whether the pass is broad persistence review, migration strategy, coexistence planning, or rollout-risk framing.
4. Treat broad persistence review and recommendation prompts as non-mutating unless the user explicitly asks to implement, edit files, or carry the plan into code in the same turn.
5. Activate `apple-appdev-workflow:apple-swiftdata-foundations` as the cross-cutting SwiftData design and migration station.
6. Activate exactly the additional stations needed for the current persistence surface:
   - `apple-appdev-workflow:apple-swiftdata-review` for existing-code risk, findings, and tactical remediation evidence
   - `apple-appdev-workflow:apple-core-data-expert` when Core Data, coexistence, migration bridges, batch/history, or CloudKit production constraints are in scope
   - `apple-appdev-workflow:fetch-apple-docs` when current Apple persistence documentation is needed
7. When a broad persistence review prompt explicitly asks to review an existing SwiftData model, migration approach, or current SwiftData code path, treat `apple-appdev-workflow:apple-swiftdata-review` as mandatory rather than heuristic. Do not let brigade mode collapse into `apple-appdev-workflow:apple-swiftdata-foundations` plus `apple-appdev-workflow:apple-core-data-expert` alone.
8. When current Apple docs are needed, route that lookup through `apple-appdev-workflow:fetch-apple-docs` before generic web search or raw `developer.apple.com` search.
9. Keep `apple-appdev-workflow:apple-swiftdata-foundations` responsible for schema, container, migration, history, and sync design evidence.
10. Keep the additional stations responsible for narrow findings or platform-specific persistence evidence.
11. Require every downstream station to return evidence upward only; do not allow station-local summaries or findings-first wrap-ups to become the final user-facing answer.
12. Aggregate the result into one brigade-owned persistence summary instead of letting any one station narrate the final answer.
13. If the task legitimately expands into code-changing implementation, return to the parent orchestrator's mutation policy before the first edit: enforce branch policy, activate `apple-appdev-workflow:apple-feature-implementation` as needed, and do not mutate the ambient branch opportunistically.
14. If this skill was activated by `apple-appdev-workflow:apple-app-orchestrator`, return the brigade content upward for parent emission rather than treating this skill as the top-level final narrator.

## Output contract
- Apply the shared brigade rules in `../../references/brigade-output-contract.md`.
- For non-mutating persistence review passes, follow the literal routing block and final section headings from `../../references/persistence-brigade-trace-template.md`.
- The final user-facing persistence summary must include these sections in this order:
  1. `Activated skills`
  2. `Persistence scope`
  3. `Discovery findings`
  4. `Persistence assessment`
  5. `Coordinated recommendations`
  6. `Migration and rollout notes`
  7. `Direct follow-on lanes`
- Use those exact section labels.
- In authoritative broad persistence summaries, `Activated skills` must preserve `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-persistence-orchestrator`.
- `Activated skills` must also name `apple-appdev-workflow:apple-swiftdata-foundations` and each additional fully qualified station that materially shaped the result.
- When the reviewed surface explicitly includes an existing SwiftData model, migration approach, or current SwiftData code path, `Activated skills` must also name `apple-appdev-workflow:apple-swiftdata-review`; omitting it makes the broad persistence pass incomplete.
- Do not emit implementation-oriented headings such as `Outcome`, `Tests Added Or Updated`, `Validation Executed`, or `Branch-Diff Review Status` in a design-only pass.

## Guardrails
- Do not let `apple-appdev-workflow:apple-swiftdata-foundations`, `apple-appdev-workflow:apple-swiftdata-review`, or `apple-appdev-workflow:apple-core-data-expert` become the first visible routing layer for broad persistence work.
- Do not turn a narrow SwiftData review, narrow Core Data debugging request, or narrow schema-guidance ask into a brigade pass when the task does not require multi-station persistence coordination.
- For trace-sensitive non-mutating validation, prefer `review`, `recommend`, or `what should change first` framing over bare `design` prompts.
- Do not turn a review-only persistence prompt into implementation work unless the user explicitly asks for code changes in the same turn.
- Do not use generic web search or raw `developer.apple.com` search for Apple persistence APIs before routing through `apple-appdev-workflow:fetch-apple-docs` when current Apple docs are needed.
- Do not let downstream station-local prose replace the brigade as the final narrator in broad persistence mode.
