# SwiftData Migrations and History

Use for schema evolution, release upgrades, and change tracking.

## Migration baseline
- Start by evaluating lightweight migration.
- Use `VersionedSchema` and `SchemaMigrationPlan` when changes exceed lightweight capabilities.
- Treat renames, deletes, relationship changes, and identity changes as migration work.

## Persistent history
- Use history when cross-process or time-based change consumption matters.
- Persist history tokens after successful processing.
- Filter and clean history deliberately to avoid unbounded growth.
- Preserve delete-tombstone values only when the product truly needs them.

## Guardrails
- Do not ship schema changes without rehearsing migration on existing data.
- Do not delete history before all consumers are accounted for.
