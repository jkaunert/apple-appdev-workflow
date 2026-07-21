# Release Candidate Policy

## A release candidate should have
- a specific commit SHA
- explicit validation evidence
- explicit unresolved risk list
- clear go/no-go owner or decision frame
- artifact identity that matches the validated build

## Promotion rule
Do not treat a build as a release candidate until:
- required automated validation is green
- manual-validation status is explicit when required
- high-risk release findings are classified
- rollback assumptions are stated for risky changes

## Useful output shape
- commit
- scheme/configuration
- build identity
- validation summary
- blockers
- residual risks
- rollout recommendation
