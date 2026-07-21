---
name: appkit-accessibility-auditor
description: AppKit accessibility implementation and audit skill for macOS. Use when AppKit views, windows, tables, or custom controls change and need concrete accessibility fixes or prioritized findings.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# AppKit Accessibility Auditor

## Required context
- Load `../../references/accessibility-foundations.md`.
- Load `../../references/accessibility-output-contract.md`.
- Load `../../references/appkit-accessibility-checklist.md`.
- Load `../../references/accessibility-playbook.md` when patch patterns or common failures match the task.

## Responsibilities
- Own AppKit-specific accessibility implementation details and audits.
- Produce minimal, patch-ready fixes for VoiceOver labels and roles, key-view loops, keyboard-first navigation, table or outline semantics, announcements, and non-color cues.
- Preserve existing window and responder-chain behavior while improving accessibility.

## Workflow
1. Confirm whether the task is implementation, remediation, or audit.
2. Inspect labels, roles, help text, key-view flow, keyboard activation, grouping, table or outline semantics, announcements, and readable scaling.
3. If the AppKit audit depends on live runtime evidence from a launched macOS app, use `apple-appdev-workflow:apple-runtime-debugger-macos` or its exact app-path capture rules rather than generic desktop screenshots.
4. Prefer minimal, localized fixes in view or controller setup and custom control implementations.
5. Return prioritized findings when auditing, or direct patch guidance when implementing.
6. End with the relevant manual verification steps from `../../references/appkit-accessibility-checklist.md`.
7. Use the framework-auditor section order from `../../references/accessibility-output-contract.md`.
8. If this skill is directly invoked for an AppKit-only accessibility ask, keep this skill as the sole final narrator only when the task stays at the framework-audit lane and does not ask for accessibility release judgment, ship-readiness, or whether the flow can safely claim accessibility support.

## Output contract
- `Audit scope`
- `Mode`
- `Findings` for audit work, or `Fix plan` for implementation or remediation work
- `Patch-ready changes`
- `Manual verification`

## Guardrails
- Do not break keyboard navigation, focus loops, or responder-chain expectations.
- Do not add accessibility properties without a semantic reason.
- Do not let `apple-appdev-workflow:apple-accessibility-orchestrator` or `apple-appdev-workflow:apple-accessibility-foundations` lose final-answer ownership when broad accessibility brigade routing is active.
- When `apple-appdev-workflow:apple-accessibility-orchestrator` is active, return evidence upward only; do not emit the final user-facing answer.
- Do not take ownership of release-claim framing or mixed-stack coordination when `apple-appdev-workflow:apple-accessibility-foundations` is active.
- Do not stay in this direct AppKit lane when the prompt asks whether the flow is safe to ship, safe to claim accessibility support for, or otherwise uses accessibility as a release gate. Promote that work to `apple-appdev-workflow:apple-accessibility-orchestrator`.
- Do not pull in `apple-appdev-workflow:apple-accessibility-foundations` as a co-owner for a direct AppKit-only accessibility audit just because the work is pre-release; reserve that escalation for explicit mixed-stack or release-claim asks, and reserve brigade promotion for release-gate accessibility judgment.
- Do not treat fullscreen desktop capture as proof of AppKit window state when the exact launched app path is known.
- Do not prepend standalone severity cards or freeform prose before `Audit scope`.
- Do not emit inline review annotations such as `::code-comment{...}` in the final answer.
- Do not refactor broad window architecture when localized fixes are sufficient.
