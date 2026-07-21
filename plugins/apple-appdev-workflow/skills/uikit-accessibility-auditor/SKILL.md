---
name: uikit-accessibility-auditor
description: UIKit accessibility implementation and audit skill for iOS and iPadOS. Use when UIKit screens, cells, or custom controls change and need concrete accessibility fixes or prioritized findings.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# UIKit Accessibility Auditor

## Required context
- Load `../../references/accessibility-foundations.md`.
- Load `../../references/accessibility-output-contract.md`.
- Load `../../references/uikit-accessibility-checklist.md`.
- Load `../../references/accessibility-playbook.md` when patch patterns or common failures match the task.

## Responsibilities
- Own UIKit-specific accessibility implementation details and audits.
- Produce minimal, patch-ready fixes for labels, values, traits, grouping, announcements, Dynamic Type, hit testing, and non-color cues.
- Preserve existing architecture and event flow while improving accessibility behavior.

## Workflow
1. Confirm whether the task is implementation, remediation, or audit.
2. Inspect labels, values, traits, grouping, screen-change announcements, Dynamic Type support, hit targets, and discoverability of custom controls.
3. Prefer minimal, localized fixes in `viewDidLoad`, `configure`, cell setup, or custom control code.
4. Return prioritized findings when auditing, or direct patch guidance when implementing.
5. End with the relevant manual verification steps from `../../references/uikit-accessibility-checklist.md`.
6. Use the framework-auditor section order from `../../references/accessibility-output-contract.md`.
7. If this skill is directly invoked for a UIKit-only accessibility ask, keep this skill as the sole final narrator only when the task stays at the framework-audit lane and does not ask for accessibility release judgment, ship-readiness, or whether the flow can safely claim accessibility support.

## Output contract
- `Audit scope`
- `Mode`
- `Findings` for audit work, or `Fix plan` for implementation or remediation work
- `Patch-ready changes`
- `Manual verification`

## Guardrails
- Do not confuse test identifiers with VoiceOver labels.
- Do not overuse hints or announcements.
- Do not let `apple-appdev-workflow:apple-accessibility-orchestrator` or `apple-appdev-workflow:apple-accessibility-foundations` lose final-answer ownership when broad accessibility brigade routing is active.
- When `apple-appdev-workflow:apple-accessibility-orchestrator` is active, return evidence upward only; do not emit the final user-facing answer.
- Do not take ownership of release-claim framing or mixed-stack coordination when `apple-appdev-workflow:apple-accessibility-foundations` is active.
- Do not stay in this direct UIKit lane when the prompt asks whether the flow is safe to ship, safe to claim accessibility support for, or otherwise uses accessibility as a release gate. Promote that work to `apple-appdev-workflow:apple-accessibility-orchestrator`.
- Do not pull in `apple-appdev-workflow:apple-accessibility-foundations` as a co-owner for a direct UIKit-only accessibility audit just because the work is pre-release; reserve that escalation for explicit mixed-stack or release-claim asks, and reserve brigade promotion for release-gate accessibility judgment.
- Do not prepend standalone severity cards or freeform prose before `Audit scope`.
- Do not emit inline review annotations such as `::code-comment{...}` in the final answer.
- Do not break cell reuse, focus order, or control semantics while patching accessibility.
