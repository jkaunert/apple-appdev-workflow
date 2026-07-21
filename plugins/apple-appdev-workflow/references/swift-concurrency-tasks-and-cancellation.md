# Swift Concurrency Tasks and Cancellation

Use this reference for task structure, SwiftUI task lifetime, and cancellation behavior.

## Task selection
- `async let` for a fixed number of parallel child operations.
- task groups for dynamic child work.
- `Task {}` only when bridging from sync to async or intentionally spawning inherited-context work.
- `Task.detached` only when shedding actor context and priority is explicitly required.

## Cancellation
- cancellation is cooperative; check it in long-running work.
- bridge cancellation to legacy APIs when they expose their own cancel handles.
- cancel stored task handles before replacement and during teardown.
- prefer SwiftUI `.task` over `onAppear { Task { ... } }` for view-scoped async work.
