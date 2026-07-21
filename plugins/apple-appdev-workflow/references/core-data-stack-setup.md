# Core Data Stack Setup

Use for `NSPersistentContainer`, store setup, contexts, and merge-policy decisions.

## Baseline
- Identify the store type and whether CloudKit is enabled.
- Distinguish view context from background contexts before proposing fixes.
- Keep merge policies explicit when conflicts are possible.

## Guardrails
- Do not blur UI and background work into one context.
- Do not ignore store configuration or merge policy when diagnosing correctness issues.
