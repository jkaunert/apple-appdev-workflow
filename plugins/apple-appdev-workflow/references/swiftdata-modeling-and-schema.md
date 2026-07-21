# SwiftData Modeling and Schema

Use for SwiftData model and schema design.

## Modeling baseline
- Use `@Model` for persistable types.
- Use `@Attribute` only when behavior differs from defaults.
- Use `@Relationship` explicitly when delete rule, inverse, or clarity matters.
- Use `@Transient` only for runtime-only state that truly should not persist.

## Schema rules
- Treat delete rules as business rules.
- Prefer explicit inverses when relationships are important to correctness.
- Use uniqueness and indexing only when supported by the deployment target and justified by real workload.
- Treat inheritance as opt-in and availability-gated.

## Guardrails
- Avoid hidden schema assumptions outside model code.
- Avoid leaving orphaning/nullification behavior implicit.
- Avoid using transient or computed-only data in persisted-query decisions.
