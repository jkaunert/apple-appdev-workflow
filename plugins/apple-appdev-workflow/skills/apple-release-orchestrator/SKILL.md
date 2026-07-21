---
name: apple-release-orchestrator
description: Release-domain expediter for broad iOS/macOS release-readiness workflows. Use after `apple-appdev-workflow:apple-app-orchestrator` scopes ship-readiness, final-validation, or go/no-go work.
metadata:
  role: brigade-orchestrator
  entrypoint: delegated
  routing_scope: domain
---

# Apple Release Orchestrator

## Required context
- Load `../../references/release-orchestration-flow.md`.
- Load `../../references/release-evidence-aggregation.md`.
- Load `../../references/release-brigade-trace-template.md`.
- Load `../../references/apple-skill-orchestration.md`.
- Load `../../references/apple-branching-strategy.md`.
- Load `../../references/brigade-output-contract.md`.

## Entry rule
- Use this skill after `apple-appdev-workflow:apple-app-orchestrator` scopes a broad release-readiness workflow.
- Direct use is acceptable for focused internal validation of the release brigade, but broad user-facing Apple workflows should still begin with `apple-appdev-workflow:apple-app-orchestrator`.
- When activated by `apple-appdev-workflow:apple-app-orchestrator`, this skill owns release-domain sequencing and the required release brigade shape, but it returns that structure to the parent orchestrator. It does not replace the parent route block or final-answer ownership.
- If the prompt explicitly says the supplied patch or evidence is the entire release record and forbids repo or git inspection, treat the run as an evidence-only release pass. In that mode, synthesize the release brigade summary from the supplied evidence and mark missing manual/build/repo proof explicitly instead of trying to discover more state.
- If the supplied evidence is a patch or branch diff but the user is asking for ship readiness, final validation, or go/no-go judgment, keep this skill as the owner. Do not downshift the route into `apple-appdev-workflow:apple-review-orchestrator` just because the evidence arrives as a diff.
- If the prompt explicitly identifies itself as phase 2 of 2 and supplies a phase-1 findings memo, treat the run as a synthesis-only continuation of the same release brigade. Do not narrate that continuation state; emit the literal route block and the final brigade summary only.

## First output rule
- For broad, evidence-only, or phase-2 memo-sourced release passes, emit the literal route block from `../../references/release-brigade-trace-template.md` before any bundle-authored progress update.
- When this lane is activated by `apple-appdev-workflow:apple-app-orchestrator`, parent route ownership is satisfied by surfacing that brigade block. Do not replace it with a parent-only, hybrid, or custom `Mode:` block.
- Apply the shared no-preamble and no-progress-bullets rules in `../../references/brigade-output-contract.md`.

## Scope
Use this skill when the request is about:
- release readiness
- ship or no-ship
- final validation
- release candidate readiness
- pre-release review
- release doctor pass
- go or no-go

## Workflow
1. Start with a discovery-first release scan of the branch, changed surfaces, existing validation artifacts, existing manual/release evidence, and the effective working root.
   - Evidence-only fast path: if the prompt says the supplied patch or evidence is the entire release record and forbids repo or git inspection, treat the supplied evidence as the release target for this pass, skip branch discovery, and carry missing branch/manual/build proof as explicit gaps.
2. Confirm the release target, branch, or candidate under review using the discovered reality.
3. Determine whether the release evidence is grounded in committed branch state, staged changes, or a dirty working tree.
4. If material candidate-defining changes are still uncommitted, treat the pass as provisional branch-state evidence and recommend a checkpoint commit before storefront finalization or strong release claims.
5. If the pass will use a narrower scope than the user’s broad app-level or branch-level request, verify that the narrower scope was either explicitly requested by the user or already documented in the discovered project context. Otherwise keep the broader scope.
6. Use the discovered working root for all git, build, test, and release-evidence collection rather than the ambient shell directory.
7. Activate the required release stations:
   - `apple-appdev-workflow:apple-testing-quality-gates`
   - `apple-appdev-workflow:apple-review-hardening`
   - `apple-appdev-workflow:apple-manual-validation`
   - `apple-appdev-workflow:apple-build-release-ops`
   - When XcodeBuildMCP is used during this pass, keep project or scheme defaults single-sourced through `session_set_defaults`, serialize Xcode actions, and treat duplicate `-scheme`, `build.db` lock, or MCP timeout failures as control-plane evidence that must be resolved before turning them into app-level release conclusions.
8. Activate optional release stations only when the release context requires them:
   - `apple-appdev-workflow:apple-observability-diagnostics`
   - `apple-appdev-workflow:apple-app-store-release-notes`
   - `apple-appdev-workflow:apple-app-store-aso`
9. Aggregate evidence from the activated stations instead of letting any one station act as the final summary.
10. Carry forward unresolved blockers from earlier review or hardening phases in the same session unless the current pass explicitly proves they were fixed or explicitly downgrades them with new evidence.
11. Classify blockers, residual risks, pending manual evidence, and provisional branch-state grounding separately.
12. Produce one release-readiness recommendation.
13. If this skill was activated by `apple-appdev-workflow:apple-app-orchestrator`, return the release brigade content upward for parent emission rather than treating this skill as the top-level final narrator.
   - Evidence-only fast path: return a ready-to-emit release brigade summary for the parent to surface with minimal restyling, instead of assuming the parent will reframe the answer as review output.

## Output contract
- Apply the shared brigade rules in `../../references/brigade-output-contract.md`.
- The final user-facing release summary must keep the release section order even when the evidence came from a patch or branch diff. Do not substitute review headings such as `Review scope`, `Overall assessment`, `Findings`, or `Test coverage assessment`.
- The final user-facing release summary must include these sections in this order:
  1. `Activated skills`
  2. `Release scope`
  3. `Overall status`
  4. `Evidence reviewed`
  5. `Manual-validation status`
  6. `Release-ops status`
  7. `Blockers`
  8. `Residual risks`
  9. `Recommendation`
- Use those exact section labels.
- In authoritative broad release summaries, `Activated skills` must preserve `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-release-orchestrator`.
- `Activated skills` must also name each fully qualified required release station that was used.
- `Release scope` must reflect the actual target under review and must not silently narrow the user’s requested target.
- If `Release scope` is narrower than the user’s broad app-level or branch-level request, it must explicitly cite the user request or the discovered project document that already defined that narrower target.
- `Overall status` and `Recommendation` should use the canonical outcome vocabulary:
  - `ready to ship` for full production/public release readiness
  - `ready only for narrower distribution` for internal QA, TestFlight, staged endpoint, or other limited-distribution ship-candidate readiness
  - `no-go` when the build is not ready even for narrower distribution
- `Evidence reviewed` must summarize the meaningful evidence, not list raw command transcripts.
- `Evidence reviewed` must explicitly state when the release conclusion is based on committed branch state versus dirty working-tree evidence if that distinction is material.
- `Evidence reviewed` should explicitly state when earlier review or hardening findings were carried forward, resolved, or downgraded.
- `Manual-validation status` and `Release-ops status` must always be present for broad release-readiness workflows, even if the status is incomplete or pending.
- `Recommendation` must explicitly say whether the result is `ready to ship`, `ready only for narrower distribution`, or `no-go`.
- Treat `ship-candidate` as a narrower-distribution label, not as a synonym for `ready to ship`. If ship-candidate language is used, tie it explicitly to `ready only for narrower distribution`.

## Guardrails
- Do not let one specialist skill speak for the full release workflow.
- Do not activate `apple-appdev-workflow:apple-decision-stress-test` inside the release brigade. If the user explicitly wants challenge-review of the release call, finish the release brigade and recommend a separate isolated stress-test pass.
- Do not skip the discovery-first release scan and jump straight to station activation.
- In an evidence-only release pass, do not override the prompt by trying to inspect git state, branch history, or build artifacts that were explicitly excluded.
- Do not report missing git state, branch ambiguity, or unavailable release evidence from a parent directory until discovery has attempted to recover a single clear child repo or package root.
- Do not omit manual-validation status from broad release-readiness outputs.
- Do not drop or silently forget earlier unresolved P0/P1 findings from the same session.
- Do not claim `only blocker left` unless each earlier unresolved blocker was either fixed with concrete evidence or explicitly restated.
- Do not silently redefine the release target to a narrower `slice`, `scoped slice`, `current scope`, or similar label unless that narrower scope was explicitly requested by the user or already documented in the discovered project context.
- Do not mix `ship-candidate ready` with `ready to ship` as though they are interchangeable.
- Do not let repo-local scripts or make targets replace the required release summary.
- Do not let pre-summary blocker dumps, station-local findings cards, or inline review annotations escape ahead of the brigade summary.
- If review or hardening stations produced findings, fold them into `Blockers`, `Residual risks`, and `Evidence reviewed` rather than surfacing them as a separate preamble.
- If commands, scripts, or MCP actions were used during the pass, collapse them into the required summary sections before answering.
- Keep storefront content work optional and release-coupled, not always-on.
- Do not present a dirty working tree as though it were already a stable branch release candidate without saying so explicitly.
- Do not let release-note or release-readiness outputs imply committed branch grounding when the relevant changes only exist in local uncommitted state.
