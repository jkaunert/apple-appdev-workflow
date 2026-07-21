# SwiftUI Modal Patterns

Use for sheets, overlays, toasts, and transient secondary UI.

## Preferred patterns
- Use item-driven sheets when presentation is tied to selected data.
- Let presented surfaces own save, cancel, and dismiss actions when possible.
- Use enum-driven sheet routing for multi-surface flows.
- Prefer overlays and banners for low-severity status, alerts only when interruption is justified.
- Use scroll-reveal patterns when secondary content emerges naturally from the primary surface.

## Guardrails
- Avoid stacking unrelated presentation mechanisms without clear priority.
- Avoid `if let`-driven sheet body branching when an item-driven API fits better.
- Keep transient UI dismissible, deterministic, and accessibility-aware.
