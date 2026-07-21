# UI Decoupling Baseline (Apple)

## Layer responsibilities
- Pure View (`View`): declarative rendering and user intent callbacks only.
- ViewModel/Presenter: transform state, orchestrate actions, map errors/loading.
- Services: business workflows and side effects.
- Coordinator: navigation state and route transitions.

## Anti-patterns to avoid
- Networking or persistence calls directly in view bodies.
- Navigation mutation scattered across unrelated leaf views.
- Business logic inside view modifiers/callback closures without abstraction.

## Review checklist
- Can pure view be previewed/tested with mock data only?
- Can view model be tested without real network/storage?
- Are navigation transitions controlled by coordinator/service rather than inline hacks?
