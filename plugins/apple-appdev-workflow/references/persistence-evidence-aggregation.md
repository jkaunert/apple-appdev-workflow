# Persistence Evidence Aggregation

Use this reference when evidence from multiple persistence stations must collapse into one brigade-owned persistence recommendation.

## Evidence priorities

Rank persistence evidence in this order:

1. data-loss risk
2. migration safety
3. rollout and coexistence risk
4. runtime correctness
5. maintainability and architecture fit

## Station contributions

### `apple-appdev-workflow:apple-swiftdata-foundations`

Use for:

1. schema shape
2. container and context ownership
3. history and sync constraints
4. migration design

### `apple-appdev-workflow:apple-swiftdata-review`

Use for:

1. concrete findings in existing code
2. delete-rule and relationship risk
3. context misuse
4. predicate and save-behavior defects

### `apple-appdev-workflow:apple-core-data-expert`

Use for:

1. Core Data production constraints
2. coexistence and migration bridge decisions
3. persistent history, batch, threading, and CloudKit realities

### `apple-appdev-workflow:fetch-apple-docs`

Use for:

1. current API support
2. migration or history API confirmation
3. Apple documentation needed to support availability or rollout guidance

## Aggregation rules

1. Preserve findings-first severity when the request is primarily review-oriented.
2. Preserve design clarity when the request is primarily strategy-oriented.
3. If stations disagree, prefer the safer rollout or migration position until the conflict is resolved.
4. Do not let low-severity schema polish hide migration or data-loss blockers.
5. If Core Data coexistence becomes material, surface it explicitly even when the user originally asked about SwiftData only.

## Final synthesis

The persistence brigade should collapse station evidence into:

1. what the persistence model should change first
2. what the migration or rollout risks are
3. what can stay direct specialist work afterward
4. a final `Activated skills` section that preserves both `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-persistence-orchestrator`
