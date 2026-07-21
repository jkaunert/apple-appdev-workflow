---
name: apple-accessibility-orchestrator
description: Accessibility-domain expediter for broad Apple accessibility audits, mixed-stack review, and accessibility release-claim evaluation. Use after `apple-appdev-workflow:apple-app-orchestrator` scopes broad accessibility work.
metadata:
  role: brigade-orchestrator
  entrypoint: delegated
  routing_scope: domain
---

# Apple Accessibility Orchestrator

## Required context
- Load `../../references/accessibility-orchestration-flow.md`.
- Load `../../references/accessibility-evidence-aggregation.md`.
- Load `../../references/apple-skill-orchestration.md`.
- Load `../../references/brigade-output-contract.md`.

## Entry rule
- Use this skill after `apple-appdev-workflow:apple-app-orchestrator` scopes a broad accessibility workflow.
- Direct use is acceptable for focused internal validation of the accessibility brigade, but broad user-facing Apple workflows should still begin with `apple-appdev-workflow:apple-app-orchestrator`.
- When activated by `apple-appdev-workflow:apple-app-orchestrator`, this skill owns accessibility-domain sequencing and the required accessibility brigade shape, but it returns that structure to the parent orchestrator. It does not replace the parent route block or final-answer ownership.
- When this skill is active, it is the sole final narrator for broad accessibility work at the accessibility-domain layer.

## Scope
Use this skill when the request is about:
- broad accessibility audits
- mixed-stack accessibility review
- accessibility release-claim evaluation
- whether an app or flow can safely claim accessibility support before release
- single-framework accessibility audits that are phrased as release gates, ship-readiness checks, or accessibility-support claim decisions

Keep direct framework-only accessibility asks out of this brigade unless the task explicitly expands into mixed-stack coordination, release-claim framing, or release-gate accessibility judgment.

## Workflow
1. Start with a discovery-first accessibility scan of the effective working root, reviewed flow or surface, framework targets, and the accessibility concerns in scope.
2. Confirm whether the pass is broad audit, mixed-stack review, or accessibility release-claim evaluation.
3. Treat phrases such as `before release`, `ship-readiness`, `can we safely claim accessibility support`, or equivalent accessibility go/no-go framing as brigade triggers even when the reviewed surface is only UIKit, only SwiftUI, or only AppKit.
4. Activate `apple-appdev-workflow:apple-accessibility-foundations` as the cross-framework accessibility station.
5. Activate exactly the framework auditors needed for the affected layers:
   - `apple-appdev-workflow:swiftui-accessibility-auditor`
   - `apple-appdev-workflow:uikit-accessibility-auditor`
   - `apple-appdev-workflow:appkit-accessibility-auditor`
6. When a macOS accessibility pass needs live runtime evidence, on-screen state, accessibility tree inspection, or screenshots of a launched app, activate `apple-appdev-workflow:apple-runtime-debugger-macos` as an evidence-only station before using shell-level `System Events`, path-aware screenshot capture, or other launched-app runtime inspection.
7. For macOS live evidence, require the exact built `.app` path from `build_run_macos` or `get_mac_app_path`; when shell screenshots are needed, route them through `scripts/capture_macos_app_screenshot.sh --app-path <AppPath> --window-only` instead of generic desktop capture.
8. If path-aware macOS capture is blocked by MCP, IDE-session, or assistive-access gaps, surface that as degraded evidence in the brigade summary instead of treating fullscreen desktop screenshots as app-window proof.
9. Keep `apple-appdev-workflow:apple-accessibility-foundations` responsible for cross-framework implementation constraints, validation strategy, and release-claim framing.
10. Keep framework auditors responsible for detailed framework-local findings and patch guidance.
11. Require every downstream station to return evidence upward only; do not allow station-local findings cards, `::code-comment` annotations, or freeform wrap-ups to become the final accessibility answer.
12. Aggregate the result into one brigade-owned accessibility summary instead of letting any one station narrate the final answer.
13. If this skill was activated by `apple-appdev-workflow:apple-app-orchestrator`, return the accessibility brigade content upward for parent emission rather than treating this skill as the top-level final narrator.

## Output contract
- Apply the shared brigade rules in `../../references/brigade-output-contract.md`.
- The final user-facing accessibility summary must include these sections in this order:
  1. `Activated skills`
  2. `Accessibility scope`
  3. `Framework targets`
  4. `Overall assessment`
  5. `Required implementation constraints`
  6. `Validation checklist`
  7. `Manual checks`
  8. `Release-claim notes` when release readiness or accessibility-support claims are in scope
- Use those exact section labels.
- `Activated skills` must name `apple-appdev-workflow:apple-accessibility-orchestrator`, `apple-appdev-workflow:apple-accessibility-foundations`, each fully qualified framework auditor that materially shaped the result, and `apple-appdev-workflow:apple-runtime-debugger-macos` whenever the result used launched macOS app state, accessibility tree inspection, `System Events`, `build_run_macos`, `get_mac_app_path`, path-aware screenshot capture, or degraded macOS screenshot evidence.
- Do not emit a separate `Findings` section or a findings preamble ahead of the brigade summary; fold concrete issues into `Overall assessment` and `Required implementation constraints`.
- Do not allow inline review annotations such as `::code-comment{...}` in the final accessibility answer.
- `Manual checks` must call out device-only or assistive-technology validation still required.
- `Release-claim notes` must stay qualified; do not turn incomplete evidence into an unconditional accessibility-support claim.

## Guardrails
- Do not let `apple-appdev-workflow:apple-accessibility-foundations` or a framework auditor become the first visible routing layer for broad user-facing accessibility work.
- Do not let a single-framework release-gate accessibility audit stay in a framework auditor just because only UIKit, SwiftUI, or AppKit is named.
- Do not skip the discovery-first accessibility scan and jump straight to findings.
- Do not turn a direct framework-only accessibility ask into a brigade pass solely because it is pre-release. Promote only when the prompt also asks for accessibility release judgment, ship-readiness, or whether the flow can safely claim accessibility support.
- Do not let framework-local severity cards escape ahead of the brigade summary.
- Do not let `apple-appdev-workflow:apple-accessibility-foundations` or a framework auditor replace the brigade as the final narrator in broad accessibility mode.
- Do not treat generic desktop `screencapture` output as macOS app-window evidence when an exact built `.app` path is known. Route live macOS evidence through `apple-appdev-workflow:apple-runtime-debugger-macos` and path-aware capture, or mark the evidence as degraded.
- Do not mention launched macOS app state, `System Events`, or degraded path-aware macOS screenshot evidence in the final answer without also surfacing `apple-appdev-workflow:apple-runtime-debugger-macos` in `Activated skills`.
