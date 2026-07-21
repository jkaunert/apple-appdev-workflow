# Debug Evidence Aggregation

Broad debug outputs should aggregate reproduction evidence and likely-cause analysis rather than listing raw tool output.

## Required sections
- activated skills
- debug scope
- reproduction status
- discovery findings
- evidence reviewed
- likely root cause
- validation gaps
- next diagnostic step
- recommended fix path
- residual risks

## Evidence categories
- effective working root and target platform
- reproduction evidence
- runtime logs, screenshots, or UI-state evidence
- validation or test-gap evidence
- optional observability, accessibility, or hardening evidence

## Rules
- final debug summaries should use the required sections in order rather than freeform narration
- final `Activated skills` must preserve both `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-debug-orchestrator`
- the full debug brigade summary must be the first visible final output; do not prepend standalone diagnosis prose or likely-cause bullets before `Routing`
- required sections should use the exact brigade labels rather than substitutes like `Findings`, `What To Change First`, or `Diagnosis`
- a likely-cause paragraph plus a short fix recommendation is not a substitute for the full debug brigade summary
- when the prompt says the supplied evidence is the entire debugging record, treat that evidence as the source of truth for the current pass and surface missing runtime or repo inspection as `Validation gaps` instead of stalling on more discovery
- reproduction status must explicitly say whether the issue reproduced, partially reproduced, or remains unconfirmed
- discovery findings should make the effective working root explicit when the shell directory differs from the real repo or package root
- likely root cause should separate confidence from speculation
- evidence reviewed should summarize the decisive evidence rather than replaying the full investigation log
- if any required section is omitted, the broad debug pass is incomplete
