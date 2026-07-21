---
name: apple-testing-quality-gates
description: Focused testing and quality-gates subskill for iOS/macOS projects. Use for targeted validation passes, usually after `apple-appdev-workflow:apple-app-orchestrator` scopes the broader code or release workflow.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Testing Quality Gates

## Required context
- Load `../../references/swift-testing-baseline.md`.
- Load `../../references/testing-baselines.md`.
- Load `../../references/apple-mcp-workflow.md`.
- Load `../../references/accessibility-qa-checklist.md` when UI behavior or primary user journeys changed.
- Load `../../references/swift-concurrency-testing.md` when concurrency-sensitive behavior changed.
- Load `../../references/swiftdata-migrations-and-history.md` when SwiftData schemas, migrations, history, or sync behavior changed.
- Load `../../references/core-data-performance-and-testing.md` when Core Data stores, migrations, or performance-sensitive persistence paths changed.
- Activate `apple-appdev-workflow:apple-swift-testing-foundations` when new unit or integration tests are being written, XCTest unit or integration suites are being migrated, flaky shared-state tests are being debugged, or traits, tags, and parameterization decisions are needed.
- Activate `apple-appdev-workflow:apple-manual-validation` when primary user journeys changed materially, hardware-dependent behavior changed, or release confidence depends on device evidence.
- Use Swift Testing as default for new unit/integration tests.
- Mention or preserve XCTest only when UI/legacy gaps are actually present in the task or codebase.

## Entry rule
- Use this skill directly only for focused test-validation asks.
- When the request combines testing with manual validation, hardening, release readiness, or other multi-skill Apple workflow concerns, start with `apple-appdev-workflow:apple-app-orchestrator` and let it activate this skill.
- When the request is a broad branch-diff, precommit, or premerge review workflow, start with `apple-appdev-workflow:apple-app-orchestrator` and let it hand off to `apple-appdev-workflow:apple-review-orchestrator`, which then activates this skill.
- If the parent prompt explicitly says the supplied evidence is the entire record and forbids build/test execution, switch to evidence-only mode: summarize what test evidence exists, what is missing, and what cannot be claimed without trying to run tests.
- If the parent prompt explicitly says this is a bounded non-mutating review acceptance pass and that the selected diff plus existing validation evidence is the entire record, also switch to evidence-only mode. Do not spend budget deciding whether to run new tests in that mode; report missing validation as a gap and return the test-quality read upward.

## Workflow
1. Map tests to acceptance criteria.
   - Evidence-only fast path: if the prompt says the supplied evidence is complete and disallows build/test work, or says this is a bounded non-mutating review acceptance pass where the selected diff plus existing validation evidence is the entire record, keep the acceptance-criteria mapping conceptual and treat missing automation as a reported gap rather than a task to execute now.
2. Validate from the discovered working root. Do not run git or test conclusions from a parent directory once discovery has identified the real repo or package root.
3. Use `apple-appdev-workflow:apple-swift-testing-foundations` for authoring, modernization, migration, and flaky-test remediation guidance when needed.
4. Require adequate test coverage for changed behavior; if coverage is missing, add or expand tests before treating the work as complete.
5. Run focused Swift Testing unit tests for changed logic.
   - Skip execution in evidence-only mode; report the missing or stale unit evidence instead.
6. Run integration tests for contracts and service boundaries.
   - Skip execution in evidence-only mode; report the missing or stale integration evidence instead.
7. Keep UI automation, performance metrics, and legacy/tooling-gap coverage on XCTest only when those surfaces are actually in scope.
8. Use `XcodeBuildMCP` as the default Xcode-aware validation path and use raw `xcodebuild` only as fallback.
   - Show or set XcodeBuildMCP session defaults once, then use defaults-backed `build_*`, `test_*`, or `build_run_*` calls without restating project/workspace/scheme/simulator identity unless intentionally changing defaults.
   - Set `derivedDataPath` in XcodeBuildMCP session defaults before the first build or test. The path must be absolute, outside the repo, and unique per Codex thread or validation run.
   - Use a path shape such as `/tmp/apple-appdev-deriveddata/<repo-slug>-<thread-or-run-id>` or `$CODEX_HOME/tmp/DerivedData/<repo-slug>-<thread-or-run-id>`. Do not use repo-local `DerivedData/`.
   - If repo-local `DerivedData/` already exists before validation, leave it untouched and route validation to an external `derivedDataPath`.
   - Serialize Xcode actions. Do not start a second build or test while a previous XcodeBuildMCP action may still be running against the same DerivedData location.
   - If XcodeBuildMCP validation times out or reports `build.db` / `database is locked`, treat that as tool-state contention or MCP wall-clock exhaustion. Clear the contention, or fall back to raw `xcodebuild`, instead of reporting the app as failed on that evidence alone.
   - Do not switch to raw `xcodebuild` for convenience checks such as `-showBuildSettings`, ad hoc destination inspection, or because MCP defaults are already set. Use shell fallback only after a concrete MCP gap, timeout, lock, or setup defect has already been made explicit in the transcript.
9. Run UI or smoke tests for critical journeys.
10. Add accessibility QA coverage for changed UI flows and note device-only validation gaps.
11. Add concurrency-sensitive validation guidance when actor, task, cancellation, or async-interop behavior changed.
12. Add persistence-sensitive validation guidance when models, stores, migrations, history consumers, or sync behavior changed.
13. When primary journeys, hardware capabilities, or release confidence require device evidence, activate `apple-appdev-workflow:apple-manual-validation` and keep automated vs manual evidence separate.
14. Require the relevant test set to be green before commit or merge.
15. For commit or merge requests on code changes, run the final branch-diff review and test-gap check before allowing the commit or merge to proceed.
16. Enforce merge and release gates based on pass criteria.

## Fallback command examples
```bash
xcodebuild test -scheme <Scheme> -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -derivedDataPath /tmp/apple-appdev-deriveddata/<repo-slug>-<run-id> -only-testing:<UnitTarget>
xcodebuild test -scheme <Scheme> -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -derivedDataPath /tmp/apple-appdev-deriveddata/<repo-slug>-<run-id> -only-testing:<UITarget>
```

## Gate model
- Gate 1: changed-unit scope
- Gate 2: integration scope
- Gate 3: critical UI journey smoke
- Gate 4: manual device validation when materially required

## Policy notes
- Routing should be visible. Use `Routing: focused subskill` when this skill is run directly and keep orchestrator-led runs responsible for the top-level routing statement.
- Review test quality, not just presence. Tests must exercise the changed behavior meaningfully enough to catch regressions.
- Do not let validation summaries casually mention XCTest when the tested surface is already pure Swift Testing.
- For code changes, pair this validation pass with an explicit review of the current branch diff before commit or merge.
- New feature work and changed behavior should be treated as missing validation if tests were not added or updated.
- Do not let passing automation imply ship readiness when device-only evidence is still pending.
- Treat raw `xcodebuild test` examples as fallback guidance, not the default validation path for this bundle.
- In review, release, or feature-validation lanes, do not let raw `xcodebuild` appear as a quick first resort while `XcodeBuildMCP` is healthy; if shell fallback is used, the transcript must first make the MCP failure or limitation explicit.
- In evidence-only mode, do not imply that missing automated validation ran; surface it as a validation gap.
- In bounded review-acceptance evidence-only mode, do not stall on whether more validation should run. Report the gap and return the current best test-quality read upward.
- If validation creates repo-local `DerivedData/`, remove it only when it was absent before the current run or otherwise proven to be generated by the current run. Leave preexisting user or project DerivedData untouched, report the control-plane leak, and rerun with an external `derivedDataPath` before trusting the validation result.
- For broad code-changing feature work, ensure the final response visibly includes `apple-appdev-workflow:apple-testing-quality-gates` in `Activated skills` when this pass supplied the concluding validation evidence.
- For broad code-changing feature work, ensure `Branch-diff review status` is reported as `completed`, `pending before commit`, or `unavailable`; do not allow softer substitutes.
- For broad code-changing feature work, do not allow `Branch-diff review status: completed` when unrelated dirty or preexisting untracked state makes the review scope ambiguous. If the pass had to rely on source-surface inspection instead of a clean diff baseline, require `pending before commit`.
