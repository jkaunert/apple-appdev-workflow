# SwiftData CloudKit

Use for SwiftData sync planning and CloudKit-specific constraints.

## Required setup
- iCloud capability and correct CloudKit container
- remote notifications capability where required by the sync design
- validated development schema before production promotion

## Constraints
- Review feature compatibility before enabling CloudKit-backed SwiftData.
- Treat production schema as additive-only after promotion.
- Be explicit about container selection when multiple CloudKit containers exist.

## Guardrails
- Do not enable sync without schema compatibility review.
- Do not assume eventual sync behavior is acceptable without multi-device validation.
