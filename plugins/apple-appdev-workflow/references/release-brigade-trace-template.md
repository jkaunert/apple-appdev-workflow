# Release Brigade Trace Template

Use this template when validating or tightening the broad release-readiness brigade.

## First routing block

Use this exact shape for the first structured routing block the bundle emits for the lane. Emit it before any bundle-authored setup prose, discovery narration, or lines such as `I'm treating this as...`, `I'm starting by checking...`, or `Using ...`. If a host/runtime build prepends one generic kickoff sentence first, treat that as host-layer noise and emit this block immediately after it:

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-release-orchestrator`, `apple-appdev-workflow:apple-testing-quality-gates`, `apple-appdev-workflow:apple-review-hardening`, `apple-appdev-workflow:apple-manual-validation`, `apple-appdev-workflow:apple-build-release-ops`
Reviewing the actual release target first, then aggregating validation evidence, blockers, residual risks, and ship recommendation into one brigade summary.
```

Do not replace those labels with paraphrases. Do not use first-person skill narration such as `I'm using apple-release-orchestrator...`. Do not substitute a parent-only kickoff block, a hybrid parent-plus-brigade block, checklist bullets, or a custom `Mode:` line for this block.

Until this block has been emitted, do not send any other bundle-authored progress update for the lane. In particular:
- do not narrate repo or branch discovery before the route block
- do not announce build, archive, or manual-validation steps before the route block
- do not let downstream review or hardening stations surface their own interim narration first

## Final summary headings

```text
Routing: orchestrator-led
Activated skills
Release scope
Overall status
Evidence reviewed
Manual-validation status
Release-ops status
Blockers
Residual risks
Recommendation
```

## Final `Activated skills` expectations

- Preserve `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-release-orchestrator` in the final summary.
- Include the release stations only when they materially shaped the pass.
