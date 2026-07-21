# Review Evidence Aggregation

Broad review outputs should aggregate branch-diff findings and test evidence rather than listing raw commands or station-local notes.

## Required sections
- activated skills
- review scope
- discovery findings
- overall assessment
- findings
- test coverage assessment
- residual risks
- recommendation

## Evidence categories
- effective working root and diff context
- branch and diff context
- validation and test evidence
- hardening and risk findings
- unresolved blockers carried forward from earlier implementation, review, or hardening phases
- optional specialist review evidence

## Rules
- final review summaries should use the required sections in order rather than freeform narration
- final `Activated skills` must preserve both `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-review-orchestrator`
- a response that only includes findings bullets plus a short wrap-up does not satisfy the broad review summary requirement
- discovery findings should make the effective working root explicit when the shell directory differs from the real repo or package root
- discovery findings should make the chosen diff baseline explicit when an upstream branch exists
- if unrelated dirty or preexisting untracked state made the diff scope ambiguous, the review must make that explicit and `Branch-diff review status` should not be reported as `completed`
- earlier unresolved blockers from the same session must remain visible until they are explicitly resolved or downgraded with evidence
- blocker-remediation passes must not escalate to `no remaining blockers` or equivalent closure unless each earlier unresolved blocker is explicitly resolved with evidence or explicitly restated
- findings should be first among the substantive review sections
- test coverage assessment must explicitly call out missing, weak, or unverified coverage
- a precommit review must not say `ready to commit`, `ready with follow-ups`, or equivalent when the same final summary still names missing tests, missing manual validation, unverified behavior, unavailable runtime dependencies, or other unmet validation gates for the changed behavior
- a precommit review must also avoid softer commit-approval language such as `green-light`, `not blocked by`, `would not block`, or `no confirmed bug` when the same final summary still names unmet behavior-level evidence for changed UI state, async state transitions, notifications, controllers, cells, backend/service behavior, or mutation gating
- when changed UI/state behavior has only enum-level or model-copy coverage, treat the missing behavior coverage as a blocker unless the user explicitly narrows the review gate below changed-path behavior coverage
- if changed behavior depends on a local server, backend, external service, simulator runtime, or other non-source dependency, the review must report that dependency's validation status; when the dependency is not running or was not checked, treat it as a validation blocker rather than a non-blocking residual risk
- generic change summaries are not a substitute for findings
- findings alone are not a substitute for the full review brigade summary
- the full review brigade summary must be the first visible final output; do not prepend standalone severity cards or finding bullets before `Routing`
- inline review annotations such as `::code-comment{...}` are not a substitute for the brigade summary in broad review mode
- directly evidenced bugs belong in `Findings`, not only in `Residual risks`
- startup and first-load recovery defects belong in `Findings` when changed code flips a one-shot guard such as `hasLaunched`, `isInitialized`, or optimistic connectivity state before success is proven or retry remains possible
- if any required section is omitted, the broad review pass is incomplete
