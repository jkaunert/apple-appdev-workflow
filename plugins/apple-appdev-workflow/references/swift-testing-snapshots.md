# Swift Testing Snapshots

Use this reference only when snapshot testing already exists in the project or the user explicitly requests snapshot guidance.

## Snapshot policy
- Snapshot testing is opt-in in this bundle.
- Do not introduce snapshot tooling by default for ordinary unit or integration coverage.

## When to use
- UI rendering regressions that already rely on snapshot tooling
- Structured textual snapshots for complex state comparisons when the project already uses that pattern

## Guardrails
- Prefer ordinary assertions for simple logic.
- Keep snapshot coverage targeted and stable.
- Do not let snapshot tests replace core behavior assertions.
