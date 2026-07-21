---
name: apple-debug-orchestrator
description: Debug-domain expediter for broad iOS/macOS runtime diagnosis workflows. Use after `apple-appdev-workflow:apple-app-orchestrator` scopes broad debugging requests about crashes, hangs, broken flows, or likely-cause analysis.
metadata:
  role: brigade-orchestrator
  entrypoint: delegated
  routing_scope: domain
---

# Apple Debug Orchestrator

## Required context
- Load `../../references/debug-orchestration-flow.md`.
- Load `../../references/debug-evidence-aggregation.md`.
- Load `../../references/debug-brigade-trace-template.md`.
- Load `../../references/apple-skill-orchestration.md`.
- Load `../../references/apple-branching-strategy.md`.
- Load `../../references/brigade-output-contract.md`.

## Entry rule
- Use this skill after `apple-appdev-workflow:apple-app-orchestrator` scopes a broad debugging workflow.
- Direct use is acceptable for focused internal validation of the debug brigade, but broad user-facing Apple workflows should still begin with `apple-appdev-workflow:apple-app-orchestrator`.
- When activated by `apple-appdev-workflow:apple-app-orchestrator`, this skill owns debug-domain sequencing and the required debug brigade shape, but it returns that structure to the parent orchestrator. It does not replace the parent route block or final-answer ownership.
- If the prompt explicitly says the provided evidence is the entire debugging record and also forbids repo inspection, app build, or simulator execution, treat the run as an evidence-only debug pass. In that mode, skip normal discovery-first runtime collection and synthesize the brigade summary from the provided evidence instead of trying to recreate missing runtime context.

## First output rule
- For a broad, non-mutating debug pass, emit the literal route block from `../../references/debug-brigade-trace-template.md` for the selected platform before any bundle-authored progress update.
- Apply the shared no-preamble and no-progress-bullets rules in `../../references/brigade-output-contract.md`.

## Scope
Use this skill when the request is about:
- reproducing and diagnosing a broken flow
- debugging a crash, hang, launch failure, or bad runtime state
- investigating a simulator-only or macOS runtime issue
- likely-cause analysis for runtime regressions
- broad debugging passes likely to require more than one station

## Workflow
1. Start with a discovery-first debug scan of the effective working root, target platform, runtime shape, existing validation evidence, and the reported failure mode.
   - Evidence-only fast path: if the prompt says the supplied evidence is the entire debugging record and forbids repo/build/simulator work, treat the supplied evidence as authoritative for this pass, state any missing runtime evidence as a validation gap, and continue without trying to inspect the repo or run tools.
2. Confirm whether the issue is iOS runtime, macOS runtime, package-native behavior, or a broader diagnosis that also needs observability or hardening input.
3. Make reproduction status explicit: what is expected, what is observed, and whether the issue reproduced cleanly, partially, or not yet at all.
4. Activate the required runtime station for the target:
   - `apple-appdev-workflow:apple-runtime-debugger-ios`
   - `apple-appdev-workflow:apple-runtime-debugger-macos`
5. Activate `apple-appdev-workflow:apple-testing-quality-gates` when failing coverage, missing repro coverage, or validation gaps materially affect the diagnosis.
   - Evidence-only fast path: if the prompt explicitly forbids repo/build/test work and already supplies the complete debugging record, do not activate `apple-appdev-workflow:apple-testing-quality-gates` only to restate that coverage is missing; carry that forward in `Validation gaps`.
6. Activate optional debug stations only when the evidence justifies them:
   - `apple-appdev-workflow:apple-observability-diagnostics`
   - `apple-appdev-workflow:apple-review-hardening`
   - `apple-appdev-workflow:apple-accessibility-foundations`
   - `apple-appdev-workflow:swiftui-accessibility-auditor`
   - `apple-appdev-workflow:uikit-accessibility-auditor`
   - `apple-appdev-workflow:appkit-accessibility-auditor`
   - `apple-appdev-workflow:apple-feature-implementation`
7. Aggregate runtime evidence, logs, screenshots, validation gaps, and specialist findings instead of letting any one station stand in for the final diagnosis.
8. Separate likely root cause, confidence, next diagnostic step, and recommended fix path.
9. Produce one coherent debug recommendation.
10. If this skill was activated by `apple-appdev-workflow:apple-app-orchestrator`, return the debug brigade content upward for parent emission rather than treating this skill as the top-level final narrator.
   - Evidence-only fast path: return a ready-to-emit brigade summary for the parent to surface with minimal restyling, instead of assuming the parent will do another discovery or station-selection pass.

## Output contract
- Apply the shared brigade rules in `../../references/brigade-output-contract.md`.
- The final user-facing debug summary must include these sections in this order:
  1. `Activated skills`
  2. `Debug scope`
  3. `Reproduction status`
  4. `Discovery findings`
  5. `Evidence reviewed`
  6. `Likely root cause`
  7. `Validation gaps`
  8. `Next diagnostic step`
  9. `Recommended fix path`
  10. `Residual risks`
- Use those exact section labels. Do not substitute headings such as `Findings`, `What to change first`, `Diagnosis`, `Recommendation`, or other freeform variants in place of the required labels.
- In authoritative broad debug summaries, `Activated skills` must preserve `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-debug-orchestrator`.
- `Activated skills` must also name each fully qualified station that materially shaped the result.
- Do not substitute a likely-cause paragraph plus a short fix recommendation for the required brigade summary; omitting any required debug section label makes the broad debug pass incomplete even if the diagnosis is correct.
- `Reproduction status` must explicitly say whether reproduction succeeded, partially succeeded, or remains unconfirmed.
- `Likely root cause` should include confidence and concrete file references when available.
- `Next diagnostic step` must be explicit when confidence is not yet high enough for a fix.
- `Recommended fix path` must distinguish between immediate corrective action and evidence still needed.
- `Evidence reviewed` must summarize the meaningful runtime, log, screenshot, UI-state, and validation evidence rather than replaying the investigation transcript.
- If the user asked for reproduction and diagnosis, omitting `Reproduction status`, `Likely root cause`, or `Next diagnostic step` makes the broad debug pass incomplete.

## Guardrails
- Do not let one runtime debugger become the first visible routing layer for broad debugging work.
- In orchestrator-led debug progress updates, do not narrate the run as `Using Apple App Orchestrator` plus runtime-station display names; describe the discovery, reproduction, and evidence-gathering steps instead.
- Do not skip the discovery-first debug scan and jump straight to logs or screenshots.
- In an evidence-only debug pass, do not override the prompt by trying to inspect the repo, build the app, or run the simulator anyway.
- Do not report missing repo or project state from a parent directory until discovery has attempted to recover a single clear child repo or package root.
- Do not imply ship confidence from a debug session.
- Do not treat simulator-only evidence as a real-device verdict unless the user asked for simulator-only diagnosis.
- Do not activate observability, accessibility, or hardening stations without evidence-based justification.
- Do not let ad hoc sections such as `Findings`, `What To Change First`, or `Recommended fix` replace the required brigade headings.
