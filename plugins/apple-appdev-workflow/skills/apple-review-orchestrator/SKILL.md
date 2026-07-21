---
name: apple-review-orchestrator
description: Review-domain expediter for broad iOS/macOS branch-diff, precommit, and premerge review workflows. Use after `apple-appdev-workflow:apple-app-orchestrator` scopes broad review requests about bugs, regressions, risks, or missing tests.
metadata:
  role: brigade-orchestrator
  entrypoint: delegated
  routing_scope: domain
---

# Apple Review Orchestrator

## Required context
- Load `../../references/review-orchestration-flow.md` for baseline selection, staged review, frozen-evidence modes, and fallback boundaries.
- Load `../../references/review-brigade-trace-template.md` for first-route and final-summary templates.
- Load `../../references/review-evidence-aggregation.md` for findings, coverage, blocker continuity, and recommendation semantics.
- Load `../../references/brigade-output-contract.md` for shared brigade rules.
- Load `../../references/apple-skill-orchestration.md` and `../../references/apple-branching-strategy.md`.

## Entry rule
- Use this skill after `apple-appdev-workflow:apple-app-orchestrator` scopes a broad review workflow, or for direct trace-sensitive validation of this review brigade.
- Broad review routing is incomplete unless `apple-appdev-workflow:apple-review-orchestrator` is visibly active in the route or final `Activated skills`.
- Do not use this skill as the primary owner for release-readiness, ready-to-ship, final-validation, release-doctor, ship/no-ship, or go/no-go prompts; those belong to `apple-appdev-workflow:apple-release-orchestrator`.
- When activated by `apple-appdev-workflow:apple-app-orchestrator`, own review-domain sequencing and return the brigade content upward for parent final aggregation.
- For direct, trace-sensitive brigade validation, follow the literal first routing block from `../../references/review-brigade-trace-template.md` before any other bundle-authored setup or discovery prose.
- For direct bounded review validation, freeze the evidence set after baseline selection. Use selected diff, directly related tests, and human-authored validation evidence already present in the repo; do not run build, test, manual-validation, Apple-doc lookup, generated-artifact forensics, or broad git-history expansion unless the user explicitly asks for that wider pass.
- For direct inline-evidence validation, treat the supplied repo facts, diff stat, inline hunks, and validation notes as the entire evidence record. Do not inspect live repo state, git history, or shell output after inline evidence is provided.
- For broad product review on large or high-risk diffs, staged findings collection followed by synthesis-only brigade output is intentional behavior.

## Scope
Use this skill for:
- current branch-diff review
- staged, precommit, or premerge review
- bugs, regressions, missing tests, and changed-risk review before commit or merge
- broad code review that needs testing and hardening stations

Do not use this skill as the primary owner for release-readiness or final ship decisions.

## Workflow
1. Run discovery first: effective working root, branch state, dirty state, changed files, changed surfaces, and existing validation evidence.
2. Choose the baseline in this order: working tree or staged diff for uncommitted local changes; tracking-branch diff when upstream exists; `main...HEAD` only for integration or release scope, or when no tracking branch exists.
3. Make the chosen baseline explicit in `Review scope` or `Discovery findings`.
4. Inspect diff hunks first, then open only the smallest surrounding code needed to confirm behavior. In bounded validation, inspect only the highest-risk few slices and cap context aggressively.
5. Explicitly review changed startup, first-load, bootstrap, one-shot initialization, optimistic connectivity, and retry-gating paths. A guard such as `hasLaunched`, `isInitialized`, or `didBootstrap` that flips before success is proven is a live defect candidate.
6. Activate required review stations: `apple-appdev-workflow:apple-testing-quality-gates` and `apple-appdev-workflow:apple-review-hardening`. In bounded validation, use both in evidence-only mode inside the frozen evidence set.
7. Add optional stations only when the diff justifies them: accessibility, observability, Swift concurrency, SwiftData, Core Data, or manual validation.
8. Keep `XcodeBuildMCP` as the default control plane for fresh Xcode validation. Raw `xcodebuild` fallback is allowed only after the trace names the MCP gap, timeout, lock, or tool-state defect.
9. Aggregate evidence from all activated stations into one findings-first brigade summary. Separate findings, test coverage, residual risks, and recommendation.
10. Carry forward unresolved blockers from earlier implementation, review, or hardening phases until current evidence explicitly resolves or downgrades them.
11. Before finalizing, verify the answer contains no malformed structured-review markup, half-open `::code-comment{...}` blocks, or standalone severity cards before the brigade summary.

## Output contract
- Apply `../../references/brigade-output-contract.md`, `../../references/review-evidence-aggregation.md`, and `../../references/review-brigade-trace-template.md`.
- The final user-facing review summary must start with `Routing: orchestrator-led`.
- When this skill is invoked directly for trace-sensitive or read-only routing validation, still emit the compact three-line route block from `../../references/review-brigade-trace-template.md` before any final `Activated skills` heading or actual/proposed evidence.
- In that first route block, the second line must literally start with `Activated skills:` and contain fully qualified skill ids inline. Do not replace it with `First route:`, arrows, `Review mode:`, `Evidence boundary:`, or any other route-prose substitute.
- For direct forecast-only or routing-only validation where file reads, shell, MCP tools, and repo inspection are forbidden, do not refuse, add a preamble, or wrap the route block in a fenced code block. Use this self-contained first route block:
  ```text
  Routing: orchestrator-led
  Activated skills: `apple-appdev-workflow:apple-review-orchestrator`, `apple-appdev-workflow:apple-testing-quality-gates`, `apple-appdev-workflow:apple-review-hardening`
  Reviewing the forecast-only review request in no-op mode, then separating actual injected evidence from proposed/not-run review work.
  ```
- The final user-facing review summary must include these sections in this order: `Activated skills`, `Review scope`, `Discovery findings`, `Overall assessment`, `Findings`, `Test coverage assessment`, `Residual risks`, `Recommendation`.
- Use those exact section labels.
- In authoritative broad review summaries and direct trace-sensitive validation summaries, `Activated skills` must preserve `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-review-orchestrator`.
- `Activated skills` must also name each fully qualified review station that materially shaped the result.
- Do not substitute a findings-only or partial wrap-up for the required brigade summary; omitting any required review section label makes the broad review pass incomplete even when findings are accurate.
- Do not emit a separate findings preamble ahead of the brigade summary; put findings inside `Findings`.
- Do not emit inline structured review annotations unless the user explicitly asked for inline review comments.
- Directly evidenced defects belong in `Findings`, not only in `Residual risks`.
- If no findings are discovered, state that explicitly and still report residual risks or test gaps.
- `Recommendation` must say whether the branch is ready to commit or merge, ready only with follow-ups, pending validation, or blocked.

## Guardrails
- Do not let `apple-appdev-workflow:apple-review-hardening` become the first visible routing layer for broad review work.
- Do not skip discovery, baseline selection, or changed-test coverage assessment.
- Do not silently widen a precommit or premerge review from tracking-branch diff to `main...HEAD`.
- Do not hide missing tests, missing manual validation, unavailable backend/server/runtime dependencies, or changed-path behavior gaps behind green build output.
- Do not recommend `ready to commit`, `ready with follow-ups`, `green-light`, or equivalent approval when the same answer still names unmet behavior-level evidence for the changed path.
- Do not use raw `xcodebuild` while `XcodeBuildMCP` is healthy; if fallback appears, the MCP limitation must be explicit first.
- Do not drop earlier unresolved blockers unless the current review explicitly resolves or downgrades them with evidence.
- Do not widen direct bounded validation beyond the frozen evidence set unless the user explicitly asks for broader validation or artifact forensics.
