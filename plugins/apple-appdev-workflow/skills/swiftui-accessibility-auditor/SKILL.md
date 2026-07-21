---
name: swiftui-accessibility-auditor
description: SwiftUI accessibility implementation and audit skill for iOS and macOS. Use when SwiftUI views change and you need concrete accessibility fixes, findings, or validation guidance.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# SwiftUI Accessibility Auditor

## Required context
- Load `../../references/accessibility-foundations.md`.
- Load `../../references/accessibility-output-contract.md`.
- Load `../../references/swiftui-accessibility-checklist.md`.
- Load `../../references/accessibility-playbook.md` when patch patterns or common failures match the task.

## Responsibilities
- Own SwiftUI-specific accessibility implementation details and audits.
- Produce minimal, patch-ready fixes for labels, grouping, focus, Dynamic Type, motion, and non-color affordances.
- Respect platform differences between iOS and macOS while preserving shared SwiftUI patterns.

## Workflow
1. Confirm whether the task is implementation, remediation, or audit.
2. Check icon-only controls, semantic grouping, headers, reading order, Dynamic Type scaling, focus behavior, touch targets, motion handling, and state communication.
3. Prefer native semantic controls before custom accessibility modifiers.
4. Return prioritized findings when auditing, or direct patch guidance when implementing.
5. End with the relevant manual verification steps from `../../references/swiftui-accessibility-checklist.md`.
6. Use the framework-auditor section order from `../../references/accessibility-output-contract.md`.
7. If this skill is directly invoked for a SwiftUI-only accessibility ask, keep this skill as the sole final narrator only when the task stays at the framework-audit lane and does not ask for accessibility release judgment, ship-readiness, or whether the flow can safely claim accessibility support.

## Output contract
- `Audit scope`
- `Mode`
- `Findings` for audit work, or `Fix plan` for implementation or remediation work
- `Patch-ready changes`
- `Manual verification`

## Guardrails
- Do not add redundant `.accessibilityLabel` when visible text is already correct.
- Do not rely on fixed font sizes or color-only state.
- Do not let `apple-appdev-workflow:apple-accessibility-orchestrator` or `apple-appdev-workflow:apple-accessibility-foundations` lose final-answer ownership when broad accessibility brigade routing is active.
- When `apple-appdev-workflow:apple-accessibility-orchestrator` is active, return evidence upward only; do not emit the final user-facing answer.
- Do not take ownership of release-claim framing or mixed-stack coordination when `apple-appdev-workflow:apple-accessibility-foundations` is active.
- Do not stay in this direct SwiftUI lane when the prompt asks whether the flow is safe to ship, safe to claim accessibility support for, or otherwise uses accessibility as a release gate. Promote that work to `apple-appdev-workflow:apple-accessibility-orchestrator`.
- Do not pull in `apple-appdev-workflow:apple-accessibility-foundations` as a co-owner for a direct SwiftUI-only accessibility audit just because the work is pre-release; reserve that escalation for explicit mixed-stack or release-claim asks, and reserve brigade promotion for release-gate accessibility judgment.
- Do not prepend standalone severity cards or freeform prose before `Audit scope`.
- Do not emit inline review annotations such as `::code-comment{...}` in the final answer.
- Do not change architecture or shared component ownership unless the user asked for it.
