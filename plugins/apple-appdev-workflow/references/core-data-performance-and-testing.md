# Core Data Performance and Testing

Use for profiling, fetch efficiency, memory behavior, and test strategy.

## Baseline
- Profile performance-sensitive Core Data paths with Instruments when evidence matters.
- Use realistic store sizes when validating fetch behavior.
- Use in-memory stores or isolated test stores for deterministic tests.

## Guardrails
- Do not claim performance improvement without evidence.
- Do not treat test stores and production stores as equivalent without validating migration and store-configuration behavior.
