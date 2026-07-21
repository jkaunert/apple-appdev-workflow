# Core Data CloudKit

Use for `NSPersistentCloudKitContainer` guidance.

## Baseline
- Confirm CloudKit capabilities and container configuration.
- Treat production schema as immutable after promotion.
- Validate sync on multiple devices before release.

## Guardrails
- Do not assume CloudKit issues are purely local-database bugs.
- Do not recommend production schema changes casually.
