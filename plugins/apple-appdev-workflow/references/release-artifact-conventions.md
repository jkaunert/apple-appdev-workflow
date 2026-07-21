# Release Artifact Conventions

## Goal
Keep release artifacts traceable to the validated code and workflow evidence.

## Each artifact should map to
- commit SHA
- scheme/target
- configuration
- platform
- release candidate label or build number

## Naming guidance
- prefer stable, searchable names
- include enough information to distinguish debug vs release and platform
- avoid ad hoc labels that cannot be tied back to a commit or validation record

## Guardrails
- do not promote artifacts that cannot be traced to verified validation evidence
- do not mix artifact identity with storefront messaging or release-note wording
