---
name: apple-accessibility-foundations
description: Accessibility foundations for iOS and macOS UI work. Use whenever Apple UI code is created, edited, reviewed, or released so accessibility is handled from first draft through validation and App Store readiness.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Accessibility Foundations

## Required context
- Load `../../references/accessibility-foundations.md`.
- Load `../../references/accessibility-output-contract.md`.
- Load `../../references/accessibility-playbook.md` when patch patterns or common failures are relevant.
- Load `../../references/accessibility-qa-checklist.md` before concluding UI work.
- Load `../../references/accessibility-nutrition-labels.md` for release readiness or App Store claim guidance.

## Responsibilities
- Treat accessibility as a first-draft requirement, not a follow-up fix.
- Identify the active UI framework, platform targets, deployment floor, localization constraints, and assistive technologies in scope.
- Serve as the cross-framework accessibility station for `apple-appdev-workflow:apple-accessibility-orchestrator` during broad accessibility audits, mixed-stack review, and release-claim evaluation.
- Route detailed implementation and audits to the matching framework skill:
  - `apple-appdev-workflow:swiftui-accessibility-auditor`
  - `apple-appdev-workflow:uikit-accessibility-auditor`
  - `apple-appdev-workflow:appkit-accessibility-auditor`
- When macOS accessibility judgment depends on live runtime evidence, request `apple-appdev-workflow:apple-runtime-debugger-macos` as the evidence station instead of inventing ad hoc screenshot, `System Events`, or app-activation flows.
- Keep accessibility changes aligned with the design system and shared components before proposing one-off fixes.
- Require validation evidence before closing UI work.

## Workflow
1. Determine whether the task changes SwiftUI, UIKit, AppKit, or a mixed stack.
2. Identify the accessibility concerns in scope: VoiceOver, Voice Control, keyboard/focus, Dynamic Type, motion, contrast, non-color cues, media, or release claims.
3. Apply the first-draft rules from `../../references/accessibility-foundations.md`.
4. Activate exactly the framework-specific accessibility auditor needed for the affected code.
5. For mixed stacks, keep this skill loaded and add only the auditors that correspond to changed layers.
6. When the reviewed accessibility surface includes a launched macOS app and the result depends on live runtime evidence, route that evidence collection through `apple-appdev-workflow:apple-runtime-debugger-macos`; when screenshots are needed, prefer exact app-path window capture over generic desktop screenshots.
   If the answer references macOS accessibility tree inspection, `System Events`, launched-app state, or degraded path-aware macOS capture, ensure `apple-appdev-workflow:apple-runtime-debugger-macos` is surfaced in the parent `Activated skills` list.
7. Before concluding, run the QA checklist and call out any remaining device-only checks.
8. For release or App Store work, produce a qualified nutrition-label recommendation instead of an unconditional claim.
9. Use the shared foundations-led section order from `../../references/accessibility-output-contract.md`.
10. Keep concrete framework findings inside `Required implementation constraints`; do not emit a separate `Findings` section or severity-card preamble.

## Output contract
- `Accessibility scope`
- `Framework targets`
- `Activated auditors`
- `Required implementation constraints`
- `Validation checklist`
- `Manual checks`
- `Release-claim notes` when relevant

## Guardrails
- Do not duplicate framework-specific API details when a framework auditor should own them.
- Do not replace `apple-appdev-workflow:apple-accessibility-orchestrator` as the top-level owner when broad accessibility brigade routing is active.
- When `apple-appdev-workflow:apple-accessibility-orchestrator` is active, return evidence upward only; do not emit the final user-facing answer.
- Do not let a framework auditor replace this skill as the top-level owner when the task is mixed-stack, broad accessibility review, or release-claim evaluation.
- Do not prepend standalone P0/P1/P2 cards, dismiss blocks, or freeform findings before the required foundations-led sections.
- Do not add a separate `Findings` section to the foundations-led final answer.
- Do not emit inline review annotations such as `::code-comment{...}` in accessibility final answers.
- Do not recommend hard-coded visual fixes before checking shared design-system primitives.
- Do not mark accessibility work complete without manual validation guidance.
- Do not recommend App Store accessibility labels unless common-task coverage is established.
- Do not accept fullscreen desktop screenshots as proof of macOS app state when the exact launched `.app` path is known.
- Do not let macOS live-evidence details flow into the final answer under accessibility without a corresponding `apple-appdev-workflow:apple-runtime-debugger-macos` activation record.
