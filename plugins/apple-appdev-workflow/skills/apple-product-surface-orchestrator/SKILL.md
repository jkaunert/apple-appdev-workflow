---
name: apple-product-surface-orchestrator
description: Product-surface domain expediter for broad Apple UI surface review, redesign, and coherence work that spans hierarchy, SwiftUI composition, copy, and stylistic refinement. Use this first for recommendation-first prompts about navigation, empty states, on-screen copy, product-surface coherence, or what should change first, even when SwiftUI is the main surface.
metadata:
  role: brigade-orchestrator
  entrypoint: delegated
  routing_scope: domain
---

# Apple Product Surface Orchestrator

## Required context
- Load `../../references/product-surface-orchestration-flow.md`.
- Load `../../references/product-surface-evidence-aggregation.md`.
- Load `../../references/product-surface-output-contract.md`.
- Load `../../references/product-surface-design-trace-template.md` for non-mutating redesign passes.
- Load `../../references/apple-skill-orchestration.md`.
- Load `../../references/brigade-output-contract.md`.

## Entry rule
- Use this skill after `apple-appdev-workflow:apple-app-orchestrator` scopes a broad product-surface workflow.
- For recommendation-first prompts about navigation, empty states, on-screen copy, product-surface coherence, or what should change first, treat this brigade as the preferred domain owner instead of a downstream UI station.
- Direct use is acceptable for focused internal validation of the product-surface brigade, but broad user-facing Apple workflows should still begin with `apple-appdev-workflow:apple-app-orchestrator`.
- When activated by `apple-appdev-workflow:apple-app-orchestrator`, this skill owns product-surface domain sequencing and the required brigade shape, but it returns that structure to the parent orchestrator. It does not replace the parent route block or final-answer ownership.
- When this skill is active, it is the sole final narrator for broad product-surface work at the domain layer.
- The current brigade summary shape is the intended product-default behavior for broad recommendation-first product-surface work. Do not treat it as a temporary acceptance convenience.
- For direct, trace-sensitive brigade validation, emit the literal first routing block from `../../references/product-surface-design-trace-template.md` and apply the shared no-preamble rules in `../../references/brigade-output-contract.md`.
- When this lane is activated by `apple-appdev-workflow:apple-app-orchestrator`, parent route ownership is satisfied by surfacing that brigade block. Do not replace it with a parent-only, hybrid, or custom `Mode:` block.

## Scope
Use this skill when the request is about:
- broad product-surface design review
- broad SwiftUI surface review or design recommendation
- navigation, empty-state, hierarchy, and on-screen-copy coherence as one combined product-surface request
- making an app surface feel more intentional, coherent, or production-ready across multiple UI specialist lanes

Keep narrow specialist asks out of this brigade unless the task explicitly expands into multi-skill surface coordination.

## Workflow
1. For direct, non-mutating review or recommendation passes, emit the exact first structured routing block from `../../references/product-surface-design-trace-template.md` before any other bundle-authored progress update.
2. Start with a discovery-first product-surface scan of the effective working root, reviewed surface, framework targets, and the specific UI concerns in scope.
3. Confirm whether the pass is broad surface review, design recommendation, or product-surface coherence work.
4. Treat broad product-surface review and redesign prompts as non-mutating unless the user explicitly asks to implement, edit files, or carry the recommendations into code in the same turn.
5. Activate `apple-appdev-workflow:apple-design-system-ux` as the cross-cutting surface-quality station.
6. Activate exactly the additional stations needed for the reviewed surface:
   - `apple-appdev-workflow:apple-swiftui-ui-patterns` for composition, shell, navigation, sheet, form, list, or focus concerns
   - `apple-appdev-workflow:apple-swiftui-view-refactor` for structural cleanup or stable-view-tree recommendations
   - `apple-appdev-workflow:apple-interface-writing` for end-user copy quality
   - `apple-appdev-workflow:apple-liquid-glass` when Liquid Glass is explicitly in scope
7. Keep `apple-appdev-workflow:apple-design-system-ux` responsible for hierarchy, token, adaptive-layout, and interaction-state coherence.
8. Keep the additional stations responsible for detailed lane-local findings and recommendations.
9. If the task legitimately expands into code-changing implementation, return to the parent orchestrator's mutation policy before the first edit: enforce branch policy, activate `apple-appdev-workflow:apple-feature-implementation` as needed, and do not mutate the ambient branch opportunistically.
10. Require every downstream station to return evidence upward only; do not allow station-local wrap-ups, lane-local summaries, or freeform redesign prose to become the final user-facing answer.
11. Aggregate the result into one brigade-owned product-surface summary instead of letting any one station narrate the final answer.
12. If this skill was activated by `apple-appdev-workflow:apple-app-orchestrator`, return the brigade content upward for parent emission rather than treating this skill as the top-level final narrator.

## Output contract
- Apply the shared brigade rules in `../../references/brigade-output-contract.md`.
- For non-mutating redesign passes, follow the literal routing block and final section headings from `../../references/product-surface-design-trace-template.md`.
- The final user-facing product-surface summary must include these sections in this order:
  1. `Activated skills`
  2. `Surface scope`
  3. `Discovery findings`
  4. `Surface assessment`
  5. `Coordinated recommendations`
  6. `Validation and rollout notes`
  7. `Direct follow-on lanes`
- Use those exact section labels.
- In authoritative broad product-surface summaries, `Activated skills` must preserve `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-product-surface-orchestrator`.
- `Activated skills` must also name `apple-appdev-workflow:apple-design-system-ux` and each additional fully qualified station that materially shaped the result.
- Do not emit a separate `Findings` section or findings preamble ahead of the brigade summary; fold concrete issues into `Surface assessment` and `Coordinated recommendations`.
- Do not emit implementation-oriented headings such as `Outcome`, `Tests Added Or Updated`, `Validation Executed`, or `Branch-Diff Review Status` in a design-only pass.

## Guardrails
- Do not let `apple-appdev-workflow:apple-design-system-ux` or another UI specialist become the first visible routing layer for broad product-surface work.
- Do not turn a narrow copy rewrite, narrow SwiftUI refactor, narrow pattern-selection question, or narrow Liquid Glass review into a brigade pass when the task does not require multi-skill surface coordination.
- Do not turn a redesign-only or review-only prompt into an implementation pass unless the user explicitly asked for code changes in the same turn.
- For trace-sensitive non-mutating validation, prefer review or `what should change first` framing over bare `redesign` wording.
- Do not edit files on the ambient branch from inside this brigade without first re-entering the parent orchestrator's branch-policy gate.
- Do not skip the discovery-first surface scan and jump straight to redesign advice.
- Do not let downstream station-local prose replace the brigade as the final narrator in broad product-surface mode.
