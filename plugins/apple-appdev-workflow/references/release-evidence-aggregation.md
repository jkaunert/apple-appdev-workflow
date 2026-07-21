# Release Evidence Aggregation

Broad release-readiness outputs should aggregate evidence, not just list tools or commands that ran.

## Required sections
- activated skills
- release scope
- overall status
- evidence reviewed
- manual-validation status
- release-ops status
- blockers
- residual risks
- recommendation

## Canonical outcomes
- `ready to ship`: full production or public-release readiness
- `ready only for narrower distribution`: internal QA, TestFlight, staged-endpoint, or other limited-distribution ship-candidate readiness
- `no-go`: not ready even for narrower distribution

Use these exact meanings consistently. Treat `ship-candidate` as a label for the second state, not as a synonym for `ready to ship`.

## Evidence categories
- effective working root and release target context
- automated validation and tests
- hardening or risk findings
- unresolved blockers carried forward from earlier review or hardening phases
- manual and device validation
- build and release-candidate evidence
- optional storefront or observability release inputs

## Rules
- the release brigade summary must start with `Routing: orchestrator-led`
- final `Activated skills` must preserve both `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-release-orchestrator`
- final release summaries should use the required sections in order rather than freeform narration
- the full release brigade summary must be the first visible final output; do not prepend standalone severity cards, blocker bullets, or other pre-summary prose before `Routing`
- inline structured review annotations such as `::code-comment{...}` are not a substitute for the release brigade summary
- when the prompt says the supplied patch or evidence is the entire release record, treat that supplied material as the release scope for the current pass and surface missing git/build/manual proof inside the required sections instead of stalling on more discovery
- when the lane is release readiness, do not substitute review headings such as `Review scope`, `Overall assessment`, `Findings`, or `Test coverage assessment` just because the supplied evidence is a patch or branch diff
- `release scope` must reflect the actual target under review and must not silently narrow the user's app-level or branch-level request
- if `release scope` is narrower than the user’s broad request, it must cite the user request or the discovered project document that already defined that narrower target
- `overall status` and `recommendation` should use the canonical outcome vocabulary consistently
- evidence reviewed should make the effective working root explicit when the shell directory differs from the real repo or package root
- repo-local scripts are evidence inputs, not final conclusions
- passing automation is not enough when manual/device evidence is still pending
- passing automation is not enough to erase earlier unresolved blockers; those must be resolved with new evidence or carried forward explicitly
- recommendations must be tied to explicit evidence, not implied confidence
- `only blocker left` claims require explicit closure or restatement of each earlier unresolved blocker
- `ship-candidate ready`, `ready to ship`, `no remaining blockers`, or equivalent closure claims also require explicit closure or restatement of each earlier unresolved blocker
- if any earlier unresolved blocker remains open or only partially verified, the overall status must stay below `ship-candidate ready`
- do not use `ship-candidate` as though it means full production readiness
- if any required section is omitted, the release-readiness pass is incomplete
