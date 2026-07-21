# Apple Architecture Baselines (iOS/macOS)

Derived from production patterns but written as reusable, project-agnostic defaults.

## SwiftUI + Swift 6 baseline
- Use `@Observable` for observable state models.
- Use explicit dependency injection with protocol-typed services.
- Keep UI updates MainActor-safe; isolate concurrent work behind actors/services.
- Enforce Sendable boundaries for cross-concurrency data.

## Dependency injection baseline
- Define service protocols first.
- Inject via initializers for feature units; use environment keys only at composition boundaries.
- Avoid concrete service creation inside views/view models.

## Service-based architecture baseline
- Place business workflows in services/use-cases.
- Keep ServiceContainer composition at app/container boundary.
- Keep feature code dependent on protocols, not concrete container internals.

## Navigation service baseline
- Use a coordinator/router service to hold route state and transitions.
- Keep route mutation out of pure views.
- Keep deep-link translation centralized in coordinator layer.

## Strict decoupling baseline
- Pure view: rendering + callbacks only.
- Container/presenter/viewmodel: orchestration, state transitions, side effects.
- Services: business logic + IO boundaries.
- Repositories/adapters: persistence/network implementation details.

## Error/loading baseline
- Centralize error and loading state management patterns.
- Preserve consistent retry/cancel UX across features.
