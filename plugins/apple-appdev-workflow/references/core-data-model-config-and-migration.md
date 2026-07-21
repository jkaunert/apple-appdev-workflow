# Core Data Model Configuration and Migration

Use for constraints, model configuration, and migration planning.

## Baseline
- Prefer lightweight migration when it fits.
- Use staged migration when complexity or availability justifies it.
- Treat constraints, validation, and merge policies as part of correctness.

## Guardrails
- Do not ship schema changes without rehearsing migration on existing stores.
- Do not ignore compatibility issues just because a clean install works.
