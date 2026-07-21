# SwiftUI Input and Focus Patterns

Use for text-heavy, keyboard-driven, or composition-heavy interfaces.

## Preferred patterns
- Model focus explicitly with `@FocusState`.
- Use input toolbars for composer or chat-like flows that need persistent actions.
- Keep validation feedback close to the field when possible.
- Drive keyboard-next and submit behavior intentionally rather than relying on defaults.

## Guardrails
- Avoid hidden focus jumps.
- Avoid burying primary actions behind keyboard dismissal.
- Keep focus order and assistive-technology reading order aligned.
