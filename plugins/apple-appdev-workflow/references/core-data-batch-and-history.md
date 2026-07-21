# Core Data Batch Operations and History

Use for batch insert, update, delete, and persistent history tracking.

## Baseline
- Batch operations are not complete until UI merge/update behavior is accounted for.
- Persistent history tracking is often required to make batch work visible to interested consumers.
- Treat history retention and cleanup as operational concerns.

## Guardrails
- Do not recommend batch operations without explaining how changes propagate back to readers.
- Do not enable history without a token and cleanup strategy.
