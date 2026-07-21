# SwiftUI Overlay, Search, and Media Patterns

Use for rich interaction layers and content-browsing surfaces.

## Search
- Prefer native `searchable` integration with explicit loading and empty states.
- Scope search results to the visible context when practical.

## Overlay and feedback
- Use overlays, banners, and toasts for transient feedback that should not block the task.
- Keep visual priority below the primary content unless urgency demands interruption.

## Media and motion
- Use async media loading patterns that avoid decoding heavy assets in `body`.
- Use matched transitions only when they clarify continuity.
- Tie haptics to meaningful user actions, not decoration.

## Guardrails
- Avoid piling motion, haptics, and overlays into the same interaction without a clear reason.
- Keep search state, media state, and transient feedback explicit rather than globally implicit.
