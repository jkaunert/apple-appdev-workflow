# SwiftUI View Refactor

Use behind `apple-appdev-workflow:apple-swiftui-view-refactor` for cleanup and restructuring work.

## Preferred order
- Environment
- immutable inputs
- state and stored properties
- non-view computed properties
- `init`
- `body`
- computed subviews and view helpers
- actions and helper functions

## Refactor priorities
- Split oversized `body` implementations into focused sections or subviews.
- Keep a stable root view tree where possible.
- Localize conditions inside sections, modifiers, toolbars, or overlays rather than swapping entire roots.
- Prefer small explicit inputs to extracted subviews.
- Keep helper logic grouped and marked clearly in large files.

## Guardrails
- Behavior preservation beats aesthetic reordering.
- Do not add view models just to shorten a file.
- Do not let extracted subviews become state dumpsters.
