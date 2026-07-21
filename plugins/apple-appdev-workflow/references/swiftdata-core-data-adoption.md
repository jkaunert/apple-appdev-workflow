# SwiftData and Core Data Adoption

Use when existing Core Data systems are being compared with or migrated toward SwiftData.

## Default stance
- Prefer SwiftData for new persistence work.
- Use Core Data guidance when the project already has a Core Data stack or migration/coexistence requirement.

## Coexistence baseline
- Be explicit about ownership boundaries between SwiftData and Core Data stores.
- Plan migration incrementally, with rollback-safe checkpoints.
- Validate data parity, delete semantics, and sync behavior before cutting over.
