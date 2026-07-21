---
name: apple-build-release-ops
description: Focused build and release-operations subskill for iOS/macOS applications. Use for archive, signing, release-candidate, and rollout steps, usually after `apple-appdev-workflow:apple-app-orchestrator` scopes the broader release workflow.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Build Release Ops

## Required context
- Load `../../references/apple-mcp-workflow.md`.
- Load `../../references/ci-gate-layout.md`.
- Load `../../references/testflight-handoff.md` when tester distribution or beta handoff is in scope.
- Load `../../references/release-candidate-policy.md`.
- Load `../../references/staged-rollout-and-rollback.md`.
- Load `../../references/release-artifact-conventions.md`.

## Entry rule
- Use this skill directly only for focused archive, signing, release-candidate, CI gate, TestFlight, or rollout operations asks.
- When the request is broad release readiness, ship/no-ship, or multi-skill release review, start with `apple-appdev-workflow:apple-app-orchestrator` and let it hand off to `apple-appdev-workflow:apple-release-orchestrator`, which then activates this skill.
- If the parent prompt explicitly says the supplied evidence is the entire release record and forbids repo/git/build work, switch to evidence-only mode: summarize what the supplied release-ops evidence proves and what remains unverified without trying to build or archive anything.

## Workflow
1. Define build matrix (debug/release, iOS/macOS targets).
   - Evidence-only fast path: if the prompt forbids repo/git/build work and says the supplied evidence is complete, infer the build/release target only from the provided evidence and mark artifact identity, signing, and archive proof as unknown when they are not supplied.
2. Define which CI or validation gates must pass before a build is treated as a release candidate.
3. Validate signing, provisioning, entitlements, versioning, and bundle settings.
4. Use `XcodeBuildMCP` as the default Xcode-aware path for archive and validation steps.
   - Show or set XcodeBuildMCP session defaults once, then avoid repeating project/workspace/scheme/destination identity on ordinary archive or validation calls unless intentionally changing defaults.
   - Keep Xcode actions serialized. Do not overlap archive, build, test, or run calls against the same DerivedData path.
   - If an MCP build step times out or reports `build.db` / `database is locked`, treat that as build-system contention or MCP wall-clock exhaustion first; clear it or fall back explicitly before calling the candidate itself broken.
5. Build and archive the release candidate, and tie the artifact to the validated commit and configuration.
6. Run release smoke tests and confirm artifact traceability.
7. Activate `apple-appdev-workflow:apple-manual-validation` when final rollout confidence depends on device evidence or release-doctor style signoff.
8. Activate `apple-appdev-workflow:apple-observability-diagnostics` when launch monitoring, rollout diagnostics, or post-release signals need to be defined before ship.
9. Activate `apple-appdev-workflow:apple-app-store-release-notes` when release-prep needs user-facing “What’s New” text.
10. Activate `apple-appdev-workflow:apple-app-store-aso` when release-prep includes storefront metadata, screenshot strategy, or listing-message updates.
11. Do not activate `apple-appdev-workflow:apple-decision-stress-test` inside this skill. If rollout sequencing or rollback assumptions need challenge-review, recommend a separate isolated stress-test pass instead.
12. Prepare TestFlight or tester handoff guidance when broader beta validation is in scope.
13. Stage rollout and document pause/rollback triggers.

## Output contract
- Routing: `focused subskill`
- Build matrix and release target
- Required gates and their status
- Release candidate identity and commit mapping
- Artifact traceability notes
- Manual validation and hardening dependencies
- TestFlight or tester handoff notes when applicable
- Rollout and rollback plan
- Blockers and residual risks
- Recommendation

## Fallback command examples
```bash
xcodebuild -scheme <Scheme> -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcodebuild -scheme <Scheme> -destination 'platform=macOS' build
xcodebuild -scheme <Scheme> -configuration Release archive
```

## Guardrails
- Every release candidate maps to verified commit and test evidence.
- CI green alone is not sufficient when manual validation or release-risk review is still pending.
- Manual device-validation status must be explicit before claiming ship readiness.
- Release candidates must have clear artifact identity and traceability.
- Rollback path is documented before rollout.
- Keep storefront content work separate from archive/signing mechanics.
- Treat raw `xcodebuild` commands as fallback examples, not the default bundle execution path.
- Repo-local scripts or make targets may be used as evidence inputs, but they do not replace the required release summary structure.
- In evidence-only mode, do not imply that archive, signing, or artifact traceability proof exists unless it was supplied explicitly.
