# Product Surface Evidence Aggregation

Use this reference when `apple-appdev-workflow:apple-product-surface-orchestrator` is active.

## Ownership split

- `apple-appdev-workflow:apple-product-surface-orchestrator` owns domain sequencing and the brigade summary.
- `apple-appdev-workflow:apple-design-system-ux` owns cross-cutting surface-quality evidence:
  - visual hierarchy
  - tokens
  - adaptive layout
  - interaction-state coherence
- `apple-appdev-workflow:apple-swiftui-ui-patterns` owns SwiftUI composition, shell, routing, presentation, and focus-pattern evidence.
- `apple-appdev-workflow:apple-swiftui-view-refactor` owns structural cleanup and stable-view-tree evidence.
- `apple-appdev-workflow:apple-interface-writing` owns end-user copy evidence.
- `apple-appdev-workflow:apple-liquid-glass` owns Liquid Glass evidence when that styling mode is explicitly in scope.

## Aggregation rules

- When the brigade is active, every downstream station must return evidence upward only; no station may replace the brigade as the final narrator.
- `Activated skills` must name `apple-appdev-workflow:apple-app-orchestrator`, `apple-appdev-workflow:apple-product-surface-orchestrator`, `apple-appdev-workflow:apple-design-system-ux`, and only the additional stations that materially shaped the result.
- Keep the brigade summary coherent across:
  - hierarchy
  - structure
  - copy
  - style
  - rollout or validation needs

## What must not leak

Do not allow:

- standalone findings sections ahead of the brigade summary
- freeform station-local redesign prose
- multiple competing final recommendation blocks
