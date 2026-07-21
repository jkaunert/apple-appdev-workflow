# SwiftData Review Rules

Use behind `apple-appdev-workflow:apple-swiftdata-review` for tactical review and bugfix work.

## High-priority checks
- Missing or unsafe delete rules
- Implicit or incorrect inverse relationships
- `@Query` used outside SwiftUI views
- Dangerous predicate patterns
- Save behavior that relies on unpredictable autosave timing
- Context or actor misuse
- Migration-sensitive schema edits without a plan
- CloudKit-incompatible schema changes

## Medium-priority checks
- Missing uniqueness or indexing opportunities when workload justifies them
- Fetches lacking explicit sort order or realistic bounds
- Identity or selection logic that relies on unsaved model IDs
