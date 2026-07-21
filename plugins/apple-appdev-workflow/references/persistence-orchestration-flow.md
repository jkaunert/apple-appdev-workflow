# Persistence Orchestration Flow

Use this reference for the persistence brigade. It defines how broad persistence requests should be coordinated when `apple-appdev-workflow:apple-persistence-orchestrator` owns the domain.

## Intended owner

Broad persistence work should route through:

1. `apple-appdev-workflow:apple-persistence-orchestrator`

That owner should be responsible for the final persistence-domain summary when the task spans more than one persistence specialist.

## Station activation model

The persistence brigade should activate only the stations needed for the current ask:

1. `apple-appdev-workflow:apple-swiftdata-foundations`
   - schema design
   - migration shape
   - history and sync constraints
   - container and context ownership
2. `apple-appdev-workflow:apple-swiftdata-review`
   - findings-first review
   - tactical remediation
   - unsafe patterns in existing persistence code
   - mandatory whenever a broad persistence review explicitly targets an existing SwiftData model, migration approach, or current SwiftData code path
3. `apple-appdev-workflow:apple-core-data-expert`
   - Core Data coexistence
   - migration bridge concerns
   - existing Core Data operational constraints
4. `apple-appdev-workflow:fetch-apple-docs`
   - current Apple API or migration documentation when needed

## Promotion rule

Broad persistence requests should promote when they require:

1. persistence design plus migration-risk framing
2. SwiftData/Core Data coexistence strategy
3. more than one persistence station
4. one final persistence recommendation rather than a narrow station answer

## Direct-lane rule

Keep these direct when they stay narrow:

1. SwiftData code review or remediation
2. narrow Core Data debugging or performance work
3. isolated SwiftData schema guidance that does not require cross-station risk framing

## Task mode rule

For trace-sensitive validation and broad planning prompts:

1. prefer `review`, `recommend`, or `what should change first` wording
2. treat those prompts as non-mutating by default
3. if the user explicitly asks to implement, re-enter normal mutation and branch-policy flow before editing

## Ownership rule

When the persistence brigade is active:

1. `apple-appdev-workflow:apple-persistence-orchestrator` is the sole final owner at the persistence-domain layer
2. `apple-appdev-workflow:apple-swiftdata-foundations`, `apple-appdev-workflow:apple-swiftdata-review`, and `apple-appdev-workflow:apple-core-data-expert` return evidence upward only
3. no persistence station should replace the already-active persistence owner
4. when the user explicitly asks to review an existing SwiftData model or migration approach inside a broad persistence pass, omitting `apple-appdev-workflow:apple-swiftdata-review` is a routing miss rather than an acceptable narrowing
5. the final `Activated skills` section must preserve both `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-persistence-orchestrator`

## Current status

Current working-tree state:

1. `apple-appdev-workflow:apple-persistence-orchestrator` exists as the broad persistence owner
2. broad persistence review and migration-risk prompts are intended to promote through the brigade
3. narrow persistence specialist work should remain direct
