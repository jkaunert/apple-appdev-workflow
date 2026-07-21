# Core Data Threading and Concurrency

Use for Core Data context confinement and Swift Concurrency interaction.

## Baseline
- `NSManagedObject` instances stay on their owning context.
- Pass `NSManagedObjectID` across contexts or tasks, then re-fetch.
- Use `perform` or `performAndWait` appropriately for context-confined work.

## Guardrails
- Do not pass `NSManagedObject` across contexts or actors.
- Do not hide concurrency problems with unsafe annotations.
- Escalate broader concurrency-model design to `apple-appdev-workflow:apple-swift-concurrency-foundations`.
