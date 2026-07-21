# Accessibility Orchestration Flow

Use this reference for broad accessibility audits, mixed-stack accessibility review, and accessibility release-claim evaluation.

## Primary owner

- `apple-appdev-workflow:apple-accessibility-orchestrator` is the sole final owner for broad accessibility work.
- `apple-appdev-workflow:apple-accessibility-foundations` is the cross-framework accessibility station inside that brigade.
- Framework auditors provide framework-local evidence and patch guidance:
  - `apple-appdev-workflow:swiftui-accessibility-auditor`
  - `apple-appdev-workflow:uikit-accessibility-auditor`
  - `apple-appdev-workflow:appkit-accessibility-auditor`
- `apple-appdev-workflow:apple-runtime-debugger-macos` is the macOS live-evidence station when accessibility judgment depends on launched-app state, screenshots, or other runtime capture.

## When to use the brigade

Use the brigade when the request is about:
- broad accessibility audit of a flow or app surface
- mixed-stack accessibility review
- release-claim or ship-readiness accessibility framing
- accessibility support claims that depend on more than one concern such as VoiceOver, Dynamic Type, focus, and validation evidence
- single-framework accessibility audits that are framed as a release gate or support-claim decision

Do not use the brigade for:
- direct framework-only accessibility audits explicitly addressed to a framework auditor
- narrow framework-only remediation where cross-framework claim framing is not needed and the prompt is not asking for a release or support claim decision

## Flow

1. Start with a discovery-first scan of the effective working root, active framework targets, platforms, and the accessibility concerns in scope.
2. Activate `apple-appdev-workflow:apple-accessibility-foundations` for cross-framework baselines, validation rules, and release-claim framing.
3. Activate exactly the framework auditors needed for the changed or reviewed layers.
4. When the pass needs live macOS runtime evidence, activate `apple-appdev-workflow:apple-runtime-debugger-macos` as an evidence-only station and prefer exact app-path window capture over fullscreen desktop screenshots.
5. If path-aware macOS capture is blocked, record degraded evidence explicitly rather than treating generic desktop screenshots as app-window proof.
6. Require every station to return evidence upward only; station-local findings, severity cards, inline annotations, and freeform wrap-ups must not become the final user-facing answer.
7. Do not let a framework auditor, `apple-appdev-workflow:apple-accessibility-foundations`, or `apple-appdev-workflow:apple-runtime-debugger-macos` become the final narrator in broad accessibility mode.
8. Aggregate the result into one brigade-owned final summary.

## Final-summary rules

- The final answer must start with `Routing: orchestrator-led`.
- The brigade summary must be the first visible final output.
- Do not prepend standalone severity cards, dismiss blocks, or other findings prose before `Routing`.
- Do not allow station-local `::code-comment{...}` output or any other inline review annotation to escape into the final accessibility answer.
- Fold concrete issues into `Overall assessment` and `Required implementation constraints` rather than emitting a separate pre-summary findings dump.
