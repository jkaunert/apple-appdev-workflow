---
name: apple-review-hardening
description: Focused hardening and release-risk review subskill for iOS/macOS apps. Use only for narrow hardening passes; broad branch-diff review must start with `apple-appdev-workflow:apple-app-orchestrator` and route through `apple-appdev-workflow:apple-review-orchestrator`.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Review Hardening

## Required context
- Load `../../references/generic-copilot-instructions.md`.
- Load `../../references/apple-mcp-workflow.md`.
- Use filled core context to judge release and store-readiness risk.

## Entry rule
- Use this skill directly only for focused hardening or release-risk review asks.
- When the request is a broad release-readiness, ship/no-ship, or multi-skill review workflow, start with `apple-appdev-workflow:apple-app-orchestrator` and let it hand off to `apple-appdev-workflow:apple-release-orchestrator`, which then activates this skill.
- When the request is a broad branch-diff, precommit, or premerge review workflow, start with `apple-appdev-workflow:apple-app-orchestrator` and let it hand off to `apple-appdev-workflow:apple-review-orchestrator`, which then activates this skill.
- If the parent prompt explicitly says the supplied evidence is the entire record and forbids repo/git/build work, switch to evidence-only mode: review the supplied material for release-risk implications and surface unresolved hardening proof as an open blocker or residual risk.
- If the parent prompt explicitly says this is a bounded non-mutating review acceptance pass and that the selected diff plus existing validation evidence is the entire record, also switch to evidence-only mode after the review owner has already selected the diff. Do not widen the investigation or wait on new build evidence in that mode.

## Workflow
1. Review privacy and data handling for changed paths.
   - Evidence-only fast path: if the prompt says the supplied evidence is complete and forbids repo/git/build work, or says this is a bounded non-mutating review acceptance pass where the selected diff plus existing validation evidence is the entire record, limit the pass to that material and do not try to gather new code or build evidence.
2. Review performance impacts (startup, rendering, memory, battery).
3. Review resilience under service/network failures, including cold-start bootstrap state, first-load recovery, optimistic connectivity defaults, and one-shot launch guards that may prevent clean retry after transient failure.
4. Activate `apple-appdev-workflow:apple-swift-concurrency-review` when concurrency correctness, cancellation, task structure, or data-race risk is material to the release.
5. Activate `apple-appdev-workflow:apple-swiftui-performance-audit` when SwiftUI runtime performance, hangs, hitches, or update storms materially affect release risk.
6. Activate `apple-appdev-workflow:apple-swiftdata-review` when SwiftData changes create data-loss, migration, history, or sync risk.
7. Activate `apple-appdev-workflow:apple-core-data-expert` when Core Data changes create migration, threading, batch/history, or CloudKit risk.
8. Activate `apple-appdev-workflow:apple-interface-writing` when release-critical interface copy, destructive wording, permissions language, or confusing recovery text is part of the risk surface.
9. Activate `apple-appdev-workflow:apple-liquid-glass` when Liquid Glass usage may affect fallback quality, coherence, or performance on supported systems.
10. Activate `apple-appdev-workflow:apple-app-store-release-notes` when release communication quality or storefront “What’s New” accuracy is part of the release risk surface.
11. Activate `apple-appdev-workflow:apple-app-store-aso` when App Store claims, screenshot messaging, or listing-positioning updates are being prepared with the release.
12. Activate `apple-appdev-workflow:apple-manual-validation` when ship confidence depends on real-device evidence, hardware-dependent behavior, or explicit release-doctor checks.
13. Activate `apple-appdev-workflow:apple-observability-diagnostics` when critical flows lack structured logs, analytics quality, crash breadcrumbs, or rollout monitoring.
14. Do not activate `apple-appdev-workflow:apple-decision-stress-test` inside this pass. If a release claim or go/no-go decision still needs challenge-review after hardening, recommend a separate isolated stress-test pass instead.
15. Carry forward unresolved P0/P1 findings from earlier review or hardening phases in the same session unless the current pass explicitly proves they were fixed or explicitly downgrades them with new evidence.
16. When the current pass includes blocker-remediation or ship-candidate claims, reconcile each earlier unresolved blocker before making any positive readiness conclusion.
17. Do not rescue unresolved blockers by silently redefining the target to a narrower `slice` or `current scope` unless that narrower scope was explicitly requested by the user or already documented in the discovered project context.
18. Review crash/telemetry diagnosability.
19. Classify findings as blockers or follow-ups.

## Output contract
- Routing: `focused subskill`
- Findings by severity
- Blockers with fix recommendation
- Residual risks
- Go/no-go recommendation
- If earlier unresolved blockers were carried forward, restate them or explicitly mark them resolved with evidence.
- Do not use `ship-candidate ready`, `ready to ship`, `no remaining blockers`, or equivalent closure unless each earlier unresolved blocker was explicitly resolved with concrete evidence or explicitly restated as still open.
- Do not present a narrower `slice` or `current scope` as the release target unless that narrower target was explicitly requested by the user or already documented in the discovered project context.

## Guardrails
- Do not let earlier unresolved P0/P1 findings disappear just because new tests or builds passed.
- Do not claim a blocker is gone unless the relevant source, tests, or release evidence changed enough to prove that conclusion.
- Do not let a broad blocker-remediation or hardening pass overclaim closure because one class of evidence improved while another earlier blocker remained unresolved.
- Do not let a broad blocker-remediation or hardening pass escape an app-level blocker by silently reframing the target as a smaller slice.
- In evidence-only mode, do not imply that missing hardening evidence was verified outside the supplied material.
- In bounded review-acceptance evidence-only mode, do not stall on whether more build or release evidence should be gathered. Surface the unresolved proof as a blocker or residual risk and return the pass upward.
