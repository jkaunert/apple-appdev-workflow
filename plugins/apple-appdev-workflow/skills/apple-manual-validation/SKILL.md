---
name: apple-manual-validation
description: Focused manual device-validation subskill for iOS/macOS apps. Use for device-only checks, release-doctor walkthroughs, and explicit human-validation evidence, usually after `apple-appdev-workflow:apple-app-orchestrator` scopes the broader workflow.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Manual Validation

## Required context
- Load `../../references/manual-validation-matrix.md`.
- Load `../../references/device-only-checks.md`.
- Load `../../references/release-doctor-checklist.md`.
- Load `../../references/manual-validation-evidence.md`.
- Load `../../references/accessibility-qa-checklist.md` when UI behavior or accessibility claims are in scope.

## Scope
Use this skill when:
- the user asks for manual QA, release-doctor checks, or device validation
- primary user journeys changed materially
- hardware-dependent features changed
- release confidence depends on real-device evidence
- simulator evidence alone is insufficient

## Entry rule
- Use `apple-appdev-workflow:apple-app-orchestrator` first when the request is broad, release-oriented, or likely to activate multiple Apple bundle skills.
- For broad release-readiness, ship/no-ship, final-validation, or release-doctor workflows, expect `apple-appdev-workflow:apple-app-orchestrator` to hand off to `apple-appdev-workflow:apple-release-orchestrator`, which then activates this skill.
- Do not use this skill as the top-level entrypoint for ship-readiness, final-validation, or release go/no-go workflows unless the user explicitly asks to bypass the orchestrator.
- Use this skill directly only for focused manual-validation asks such as device checks, release-doctor walkthroughs, or explicit manual QA evidence collection.
- If the parent prompt explicitly says the supplied evidence is the entire release record and device checks are out of scope, treat this skill as an evidence-only status station: report what manual evidence exists, what is still pending, and what cannot be claimed.

## Workflow
1. Define the validation target: feature, release candidate, or full app.
   - Evidence-only fast path: if the prompt says the supplied evidence is complete and does not permit device work, treat the validation target as the supplied scope and skip device-matrix expansion beyond what the evidence justifies.
2. Select a pragmatic device and OS matrix from the risk surface.
3. Separate simulator-capable checks from device-only checks.
4. Identify the primary user journeys that require manual walkthrough.
5. Define the session lifecycle before testing: device/app identity, install or launch step, launch arguments or environment overrides, interaction sequence, evidence to capture before and after each step, and cleanup or session closure.
6. Apply the release-doctor checklist to the changed surface.
7. Call out any hardware-only, OS-setting, permission, or lifecycle checks still pending.
8. Record explicit evidence, pending items, blockers, and accepted risk.
9. If manual evidence is incomplete, do not imply ship readiness.

## Output contract
- Routing: `focused subskill`
- Validation scope
- Selected device and OS matrix
- Journeys requiring manual validation
- Device-only checks required
- Device or app session lifecycle
- Evidence collected
- Pending manual checks
- Blockers and follow-ups
- Ship-readiness status

## Guardrails
- Simulator validation is not full release validation.
- Hardware-dependent features require device evidence.
- Missing manual checks must be named explicitly.
- Do not recommend ship readiness without clear manual-validation status.
- If device access is unavailable, state what remains unverified.
- Do not leave long-running device or app sessions implicit. State whether the session was closed, still needs cleanup, or was never started.
- In evidence-only mode, do not pretend pending device validation happened; surface it as pending.
