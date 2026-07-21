# Release Orchestration Flow

Use this reference to keep broad release-readiness workflows sequenced consistently.

## Required station set
- `apple-appdev-workflow:apple-testing-quality-gates`
- `apple-appdev-workflow:apple-review-hardening`
- `apple-appdev-workflow:apple-manual-validation`
- `apple-appdev-workflow:apple-build-release-ops`

## Optional station set
- `apple-appdev-workflow:apple-observability-diagnostics`
- `apple-appdev-workflow:apple-app-store-release-notes`
- `apple-appdev-workflow:apple-app-store-aso`
- `apple-appdev-workflow:apple-decision-stress-test`

## Sequence
1. confirm the release target, scope, and effective working root
   - when the prompt explicitly says the supplied patch or evidence is the entire release record and forbids repo or git inspection, treat that as an evidence-only release pass and skip branch discovery beyond the supplied evidence
   - if the supplied evidence is patch-shaped or branch-diff-shaped but the ask is still ship readiness, final validation, or go/no-go, keep release ownership and treat the patch as release evidence rather than switching to review ownership
   - when the prompt explicitly identifies itself as phase 2 of 2 and supplies a phase-1 findings memo, treat that as a synthesis-only continuation of the same release brigade rather than a fresh evidence-only kickoff
2. collect automated validation evidence
3. collect hardening findings
4. collect manual-validation status
5. collect release-ops status
6. add optional release-coupled stations only when required
7. aggregate blockers, residual risks, and recommendation

## Rule
- before the release lane emits discovery narration, station setup text, or generic kickoff prose, emit the literal release route block from `release-brigade-trace-template.md`
- do not let the parent orchestrator narrate the handoff with prose such as `Using apple-app-orchestrator and apple-review-orchestrator for a branch-level release-readiness pass` or `I'm starting by checking repo state ...` before that route block
- in an evidence-only release pass, do not replace the literal route block with `Using apple-release-orchestrator in evidence-only mode ...` or any other setup sentence
- in a phase-2 memo-sourced release pass, do not prepend `Routing the response ...`, `Synthesizing from the memo ...`, or similar continuation narration ahead of the literal route block
- no broad release-readiness output is complete until the required station set has been considered and manual-validation status is explicit
- the chosen working root must be explicit when the shell directory differs from the actual repo or package root
- do not conclude that release-target git state is unavailable from a parent directory until child-root recovery has been attempted
- in an evidence-only release pass, missing branch, build, or manual-validation proof should be carried forward explicitly rather than used to stall the brigade summary
- patch-shaped evidence does not justify review-shaped final sections when the lane is release readiness
