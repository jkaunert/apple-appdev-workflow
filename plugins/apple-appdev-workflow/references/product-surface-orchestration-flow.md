# Product Surface Orchestration Flow

Use this reference for broad product-surface review, redesign, and coherence work.

## Primary owner

- `apple-appdev-workflow:apple-product-surface-orchestrator` is the sole final owner for broad product-surface work.
- `apple-appdev-workflow:apple-design-system-ux` is the cross-cutting surface-quality station inside that brigade.
- Additional UI surface stations provide lane-local evidence and recommendations:
  - `apple-appdev-workflow:apple-swiftui-ui-patterns`
  - `apple-appdev-workflow:apple-swiftui-view-refactor`
  - `apple-appdev-workflow:apple-interface-writing`
  - `apple-appdev-workflow:apple-liquid-glass`

## When to use the brigade

Use the brigade when the request is about:
- broad product-surface design review
- broad SwiftUI surface review or design recommendation
- coherence across hierarchy, navigation, empty states, copy, and presentation
- making a product surface feel more intentional or production-ready across multiple UI specialist lanes

Do not use the brigade for:
- narrow copy rewrites explicitly addressed to `apple-appdev-workflow:apple-interface-writing`
- narrow SwiftUI refactor or file-cleanup asks explicitly addressed to `apple-appdev-workflow:apple-swiftui-view-refactor`
- narrow pattern-selection questions that fit `apple-appdev-workflow:apple-swiftui-ui-patterns`
- narrow Liquid Glass adoption or review explicitly addressed to `apple-appdev-workflow:apple-liquid-glass`

## Flow

1. Start with a discovery-first scan of the effective working root, reviewed surface, framework targets, and the UI concerns in scope.
   - For direct, trace-sensitive brigade validation, emit the literal first routing block from `product-surface-design-trace-template.md` before any other bundle-authored narration.
   - Suppress generic kickoff sentences such as `Reviewing...` or `I’ve got the project shape...` until after that route block is visible.
2. Treat broad surface review or redesign prompts as non-mutating unless the user explicitly asks for implementation in the same turn.
3. Activate `apple-appdev-workflow:apple-design-system-ux` for hierarchy, tokens, adaptive layout, and interaction-state coherence.
4. Activate exactly the additional stations needed for the reviewed surface.
5. If the task expands into code-changing implementation, return to the parent orchestrator's mutation flow before the first edit so branch policy and implementation routing are enforced.
6. Require every station to return evidence upward only; station-local wrap-ups and redesign prose must not become the final user-facing answer.
7. Do not let `apple-appdev-workflow:apple-design-system-ux` or another station become the final narrator in broad product-surface mode.
8. Aggregate the result into one brigade-owned final summary.

For trace-sensitive non-mutating validation, prefer review or `what should change first` wording over bare `redesign`.

## Final-summary rules

- The final answer must start with `Routing: orchestrator-led`.
- The brigade summary must be the first visible final output.
- Final `Activated skills` must preserve both `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-product-surface-orchestrator`.
- Do not prepend standalone findings, redesign bullets, or freeform station prose before `Routing`.
- Fold concrete issues into `Surface assessment` and `Coordinated recommendations` rather than emitting a separate pre-summary findings dump.
