# Core Data Saving and Fetching

Use for save behavior, fetch requests, fetched results controllers, and aggregates.

## Baseline
- Save on the correct context for the work being performed.
- Use fetch requests that are scoped, sorted, and efficient.
- Use fetched-results-controller patterns when UI needs incremental change updates from Core Data.

## Guardrails
- Do not assume a save reached the intended context chain without checking.
- Do not use overly broad fetches when narrower predicates or batch sizes are possible.
