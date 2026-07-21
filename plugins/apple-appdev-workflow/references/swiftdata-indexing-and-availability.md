# SwiftData Indexing and Availability

Use when recommending indexes, uniqueness macros, or newer schema features.

## Availability baseline
- Check deployment target before recommending `#Unique`, `#Index`, inheritance patterns, or newer history features.
- Prefer the best compatible fallback when the target blocks newer APIs.

## Indexing guidance
- Add indexes only for real query paths.
- Remember indexes help reads but add write cost.
- Keep compound indexes aligned with actual predicate and sort usage.
