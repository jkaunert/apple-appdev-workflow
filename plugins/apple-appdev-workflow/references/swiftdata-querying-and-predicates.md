# SwiftData Querying and Predicates

Use for `@Query`, `FetchDescriptor`, filtering, sorting, and predicate safety.

## Query baseline
- Use `@Query` only inside SwiftUI views.
- Use `FetchDescriptor` from contexts/services when persistence code lives outside views.
- Prefer shared predicate builders and explicit sort order.
- Bound expensive fetches with limits, offsets, or narrower property loads when scale matters.

## Predicate safety
- Prefer supported store-backed predicate operations only.
- Avoid computed properties, transient values, regex, and unsupported collection transformations.
- Be careful with predicate forms that compile but crash at runtime.

## Guardrails
- Do not push ad hoc in-memory filtering into views when the store can do the work.
- Do not assume expensive queries are acceptable without explicit bounds and sort order.
