# SwiftUI Navigation Patterns

Use for routing and multi-surface navigation decisions.

## Preferred patterns
- `NavigationStack` for push-style history and explicit path state.
- `NavigationSplitView` for iPad and macOS multi-column flows.
- Title menus and command menus only when they clarify scope, not as overflow dumping grounds.
- Deep-link parsing should translate into typed routes, not ad hoc view mutation.

## Guardrails
- Keep navigation ownership above leaf views.
- Avoid burying route mutation inside unrelated controls.
- Prefer typed routes and sheet destinations over stringly-typed navigation.
