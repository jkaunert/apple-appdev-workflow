# Review Orchestration Flow

Use this reference to keep broad branch-diff and precommit review workflows sequenced consistently.

## Intended owner
- `apple-appdev-workflow:apple-review-orchestrator`

## Required station set
- `apple-appdev-workflow:apple-testing-quality-gates`
- `apple-appdev-workflow:apple-review-hardening`

## Optional station set
- `apple-appdev-workflow:apple-accessibility-foundations`
- `apple-appdev-workflow:swiftui-accessibility-auditor`
- `apple-appdev-workflow:uikit-accessibility-auditor`
- `apple-appdev-workflow:appkit-accessibility-auditor`
- `apple-appdev-workflow:apple-observability-diagnostics`
- `apple-appdev-workflow:apple-swift-concurrency-review`
- `apple-appdev-workflow:apple-swiftdata-review`
- `apple-appdev-workflow:apple-core-data-expert`
- `apple-appdev-workflow:apple-manual-validation`

## Sequence
1. confirm the review target, scope, and effective working root
2. choose the baseline in this order:
   - local working tree or staged diff for uncommitted precommit review
   - tracking-branch diff when upstream exists
   - `main...HEAD` only for integration or release scope, or when there is no tracking branch
3. collect discovery findings from the chosen branch diff
   - for direct, bounded, non-mutating review acceptance, freeze the evidence set here: selected diff, directly related tests, and validation evidence already present in the repo
   - for direct, bounded, non-mutating review acceptance, treat that validation evidence as human-authored only; do not widen into generated build outputs, `.xcresult` bundles, `build/TestResults`, coverage artifacts, or `DerivedData` unless the user explicitly asked for artifact forensics
   - for direct, bounded, evidence-only inline-evidence review acceptance, treat the supplied repo facts, diff stat, inline diff hunks, and any supplied human-authored validation notes as the already-frozen evidence set; do not reopen repo discovery, git history, or shell inspection after that
4. inspect diff hunks first and pull only minimal surrounding code needed to confirm behavior; avoid full-file dumps unless a changed hunk or symbol genuinely requires wider context
   - for direct, bounded, non-mutating review acceptance, inspect only the highest-risk few diff slices first and cap surrounding context aggressively; do not page through broad `--unified=40`-style dumps once the likely findings are already clear
5. keep changed-test inspection proportional; once coverage quality is clear, do not spend the review budget paging through long placeholder or scaffold-heavy test files
6. collect testing and validation evidence
   - for direct, bounded, non-mutating review acceptance, use `apple-appdev-workflow:apple-testing-quality-gates` in evidence-only mode and do not run build or test commands
   - for direct, bounded, non-mutating review acceptance, do not mine generated test-result or coverage artifacts for evidence; prefer committed or human-authored validation notes and treat missing validation as a gap
   - when the review lane needs fresh Xcode validation, keep `XcodeBuildMCP` as the default control plane. Raw `xcodebuild` is allowed only after an explicit MCP gap, timeout, lock, or other tool-state defect has already been called out.
7. collect hardening or risk findings
   - for direct, bounded, non-mutating review acceptance, use `apple-appdev-workflow:apple-review-hardening` in evidence-only mode and do not wait on new build or release evidence
   - for direct, bounded, non-mutating review acceptance, do not widen the run into Apple-doc or other external documentation lookup; report unresolved API semantics as a risk or validation gap instead
8. add optional specialist review stations only when justified by the diff
9. when the diff or risk surface is broad, preserve a short brigade-owned findings memo from the frozen evidence and use that memo as the only input to final synthesis
10. aggregate findings, test gaps, residual risks, and recommendation
11. in direct, bounded, non-mutating review acceptance, synthesize immediately once the frozen evidence set supports a likely finding or a no-finding conclusion; do not spend late budget reloading bundle references or reopening base-file history just to polish the answer shape

## Rule
- broad review routing is incomplete unless `apple-appdev-workflow:apple-review-orchestrator` is visibly active in the route and later named in `Activated skills`
- review ownership is wrong when explicit release-outcome language is present; prompts asking `ready to ship`, `release readiness`, `final validation`, `release doctor`, or `go/no-go` belong to the release brigade even if the prompt also says `review` or `audit`
- no broad review output is complete until the required station set has been considered and findings are reported before summary commentary
- baseline choice must be explicit when the review could reasonably target either upstream diff or `main...HEAD`
- the chosen working root must be explicit when the shell directory differs from the actual repo or package root
- do not conclude that review baseline or git state is unavailable from a parent directory until child-root recovery has been attempted
- before the review lane emits discovery narration, diff commentary, or station-local setup text, emit the literal review route block from `review-brigade-trace-template.md`
- for direct, bounded, evidence-only inline-evidence review acceptance, the third line of that first route block must say `Reviewing the provided inline evidence first...`, not `Reviewing the actual branch diff first...`
- for broad review with fresh validation, do not let raw `xcodebuild` appear for convenience-only checks such as `-showBuildSettings` while `XcodeBuildMCP` is healthy; if shell fallback happens, the MCP problem must be explicit first
- for direct, bounded, non-mutating review acceptance, do not widen the frozen evidence set into active validation work after the baseline and diff are already known
- for direct, bounded, non-mutating review acceptance, do not widen the frozen evidence set into Apple-doc or other external documentation lookup after the baseline and diff are already known
- for direct, bounded, non-mutating review acceptance, do not widen the frozen evidence set into generated build outputs, `.xcresult` bundles, `build/TestResults`, coverage artifacts, or `DerivedData`
- for direct, bounded, non-mutating review acceptance, do not reopen bundle references or trace templates after the route block has already been emitted just to align final-summary wording or checker shape
- for direct, bounded, non-mutating review acceptance, do not reopen upstream/base file history or extra git-baseline context after the changed hunks already support the likely findings unless one unresolved ambiguity specifically requires it
- for broad review, staged findings collection followed by a synthesis-only brigade summary is an intended product behavior when that shape preserves evidence discipline better than a single monolithic turn
- for precommit review, do not recommend `ready to commit` when the same answer still names missing behavior tests, missing manual validation, unavailable backend/server/runtime dependencies, or other validation prerequisites; keep the recommendation blocked or pending until those gates are either satisfied or explicitly scoped out by the user
- do not downgrade changed-path UI/state coverage gaps into conditional approval phrasing such as `green-light for local commit`, `not blocked by source bug`, or `ready with follow-ups`; if the review names missing behavior-level evidence for changed UI state, async state transitions, notifications, controllers, cells, backend/service behavior, or mutation gating, keep the final recommendation blocked or pending
- when the diff touches network-backed or service-backed behavior, discover whether the repo documents a required local server, backend, or service dependency and surface its status in the review; an unchecked or stopped required dependency is a validation blocker, not an optional follow-up
