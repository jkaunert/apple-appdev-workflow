# Debug Orchestration Flow

Use this reference to keep broad debugging workflows sequenced consistently.

## Required station set
- one runtime station:
  - `apple-appdev-workflow:apple-runtime-debugger-ios`
  - `apple-appdev-workflow:apple-runtime-debugger-macos`
- `apple-appdev-workflow:apple-testing-quality-gates` when the current pass is actually collecting additional validation evidence and missing repro coverage materially changes the diagnosis

## Optional station set
- `apple-appdev-workflow:apple-observability-diagnostics`
- `apple-appdev-workflow:apple-review-hardening`
- `apple-appdev-workflow:apple-accessibility-foundations`
- `apple-appdev-workflow:swiftui-accessibility-auditor`
- `apple-appdev-workflow:uikit-accessibility-auditor`
- `apple-appdev-workflow:appkit-accessibility-auditor`
- `apple-appdev-workflow:apple-feature-implementation`

## Sequence
1. confirm the target platform, issue shape, and effective working root
   - when the prompt explicitly says the supplied evidence is the entire debugging record and forbids repo/build/simulator work, treat that as an evidence-only debug pass and skip repo/runtime discovery beyond the supplied evidence
2. tighten reproduction: expected behavior, observed behavior, and whether the failure reproduces cleanly
3. collect runtime evidence through the correct runtime station
4. collect test or validation evidence when missing coverage affects confidence
5. add optional specialist debug stations only when justified by the evidence
6. aggregate likely cause, confidence, next step, fix path, and residual risks

## Rule
- before the debug lane emits discovery narration, runtime-station setup text, or generic kickoff prose, emit the literal debug route block from `debug-brigade-trace-template.md`
- no broad debug output is complete until reproduction status is explicit
- the chosen working root must be explicit when the shell directory differs from the actual repo or package root
- do not conclude that debug-target repo or project state is unavailable from a parent directory until child-root recovery has been attempted
- logs and screenshots are evidence, not the final diagnosis
- in an evidence-only pass, missing runtime logs or simulator reproduction should be recorded as validation gaps rather than treated as a reason to ignore the supplied evidence
- in an evidence-only pass, do not prolong the route by adding testing or hardening stations solely to restate that evidence is missing
- runtime stations supply evidence and reproduction detail; they do not replace the top-level debug brigade summary
- required brigade section labels should remain exact; do not replace them with freeform headings like `Findings` or `What To Change First`
