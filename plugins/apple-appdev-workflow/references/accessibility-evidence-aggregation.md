# Accessibility Evidence Aggregation

Broad accessibility outputs should aggregate cross-framework constraints, framework-local findings, and release-claim risk into one brigade summary.

## Required sections

- activated skills
- accessibility scope
- framework targets
- overall assessment
- required implementation constraints
- validation checklist
- manual checks
- release-claim notes when release-readiness or accessibility-support claims are in scope

## Evidence categories

- effective working root and reviewed surface
- framework and platform targets
- assistive technologies and accessibility concerns in scope
- framework-local findings returned by the auditors
- runtime, simulator, or code-review evidence that materially shaped the result
- for macOS live evidence, exact app-path capture from `apple-appdev-workflow:apple-runtime-debugger-macos`, or an explicit degraded-evidence note when that capture path was blocked
- remaining device-only validation gaps
- qualified release-claim risk

## Rules

- the accessibility brigade summary must start with `Routing: orchestrator-led`
- final accessibility summaries should use the required sections in order rather than freeform narration
- the full accessibility brigade summary must be the first visible final output; do not prepend standalone severity cards, dismiss blocks, or other pre-summary findings before `Routing`
- when the accessibility brigade is active, `apple-appdev-workflow:apple-accessibility-foundations` and the framework auditors must return evidence upward only; they must not emit the final user-facing answer
- inline review annotations such as `::code-comment{...}` are not a substitute for the accessibility brigade summary and must not appear in the final accessibility answer
- if framework-local findings are severe, reflect that inside `Overall assessment` and `Required implementation constraints` instead of creating a separate `Findings` section
- `Activated skills` must name `apple-appdev-workflow:apple-accessibility-orchestrator`, `apple-appdev-workflow:apple-accessibility-foundations`, only the framework auditors that materially shaped the result, and `apple-appdev-workflow:apple-runtime-debugger-macos` when live macOS runtime evidence materially shaped the result
- `Manual checks` must explicitly distinguish device-only or assistive-technology validation still required
- `Release-claim notes` must stay qualified; do not convert incomplete validation into an unconditional accessibility-support claim
- fullscreen desktop screenshots do not count as macOS app-window evidence when the exact launched app path was known
- if any required section is omitted, the broad accessibility pass is incomplete
