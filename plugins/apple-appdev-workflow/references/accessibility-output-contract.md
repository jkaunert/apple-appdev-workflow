# Accessibility Output Contract

Use this reference to keep the accessibility skill family aligned.

## Foundations-led output

When `apple-appdev-workflow:apple-accessibility-foundations` is active as the coordinating skill, use these sections in this order:

1. `Accessibility scope`
2. `Framework targets`
3. `Activated auditors`
4. `Required implementation constraints`
5. `Validation checklist`
6. `Manual checks`
7. `Release-claim notes` when release readiness or App Store accessibility claims are in scope

Rules:
- `Activated auditors` should name only the framework auditors actually needed.
- When those auditors are bundle-contributed skills in a parent brigade summary, surface them with fully qualified ids such as `apple-appdev-workflow:uikit-accessibility-auditor`.
- `Required implementation constraints` should stay cross-cutting and framework-agnostic where possible.
- If concrete issues must be prioritized, summarize them inside `Required implementation constraints` rather than adding a separate `Findings` section.
- `Manual checks` should call out device-only or assistive-technology checks that static review or simulator work cannot prove.
- `Release-claim notes` should be omitted when release claims are not in scope.
- Do not prepend standalone severity cards, dismiss blocks, or free-floating findings prose before the foundations-led sections.
- When a broad accessibility answer includes launched macOS app state, accessibility tree inspection, `System Events`, `build_run_macos`, `get_mac_app_path`, path-aware macOS screenshot capture, or degraded macOS screenshot evidence, the parent `Activated skills` block must also surface `apple-appdev-workflow:apple-runtime-debugger-macos`.

## Framework-auditor output

When a framework auditor is answering directly, or when it is supplying detailed findings under foundations-led coordination, use these sections in this order:

1. `Audit scope`
2. `Mode`
3. `Findings` for audit work, or `Fix plan` for implementation or remediation work
4. `Patch-ready changes`
5. `Manual verification`

Rules:
- `Mode` should be one of `audit`, `implementation`, or `remediation`.
- For `audit`, `Findings` should be prioritized as `P0`, `P1`, and `P2` where relevant.
- For `implementation` or `remediation`, `Fix plan` should stay concrete and localized.
- `Patch-ready changes` should remain framework-specific; cross-framework release or nutrition-label guidance belongs to foundations.
- Do not prepend severity cards or other prose before `Audit scope`.

## Ownership split

- When the accessibility brigade is active, `apple-appdev-workflow:apple-accessibility-orchestrator` is the sole final owner for broad accessibility work.
- `apple-appdev-workflow:apple-accessibility-foundations` owns cross-framework constraints, mixed-stack accessibility guidance, and release-claim framing inside that brigade.
- Framework auditors own the concrete SwiftUI, UIKit, or AppKit findings and patch guidance.
- `apple-appdev-workflow:apple-runtime-debugger-macos` owns live macOS runtime evidence when broad accessibility work depends on launched-app state, accessibility tree inspection, or path-aware screenshot capture.
- In the parent brigade answer, the final `Activated skills` block should surface those bundle-contributed stations with fully qualified ids such as `apple-appdev-workflow:apple-accessibility-orchestrator`.
- When the brigade is active, both `apple-appdev-workflow:apple-accessibility-foundations` and the framework auditors must return detailed evidence upward rather than narrating the final answer.
- When `apple-appdev-workflow:apple-runtime-debugger-macos` is active under the accessibility brigade, it must return evidence upward only and the parent answer must surface that activation in `Activated skills`.
- When a framework auditor is directly invoked for a framework-specific audit or remediation ask, it should remain the sole final narrator unless the task explicitly requires mixed-stack coordination or accessibility release-claim framing.
