# Apple Pattern Selection Criteria

## DI and composition
- Use initializer injection for deterministic feature units.
- Use environment injection at composition roots for app-wide concerns.
- Reject patterns that hide dependencies or prevent isolated tests.

## State and concurrency
- Prefer `@Observable` state models for SwiftUI updates.
- Use actors/services for shared mutable state across async boundaries.
- Reject approaches that require unsafe cross-thread mutation.

## Navigation
- Single-flow/simple app: lightweight coordinator may be enough.
- Multi-flow/deep-link app: explicit coordinator service required.

## Testing framework
- Swift Testing default for new logic tests.
- XCTest retained for UI/legacy needs.
