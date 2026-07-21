# SwiftUI MV Patterns

Use when deciding whether a SwiftUI view needs a view model.

## Baseline
- Default to MV-style SwiftUI composition.
- Views express state and lightweight orchestration.
- Services and models own business logic and external effects.
- Environment injection is preferred for shared dependencies.

## When a view model may still be justified
- Existing architecture already standardizes on one for that slice.
- Complex lifecycle orchestration cannot stay readable in the view.
- The model is clearly stateful and UI-specific, not a disguised service.

## Guardrails
- Avoid optional view models when a non-optional `@State` model initialized in `init` is viable.
- Avoid bootstrap patterns that hide ownership.
- Prefer splitting a large view before introducing a new mediator layer.
