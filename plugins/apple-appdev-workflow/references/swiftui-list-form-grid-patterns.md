# SwiftUI List, Form, and Grid Patterns

Use for feed-style content, settings, structured data entry, and tiled layouts.

## Lists and sections
- Prefer `List` and `Section` for feed and settings structures.
- Keep rows lightweight and stable in identity.
- Use loading placeholders and empty states intentionally.

## Forms and controls
- Use `Form` for grouped inputs and settings.
- Keep labels and controls semantically paired.
- Chain field focus explicitly in input-heavy flows.

## Grids
- Use grids for media, icon pickers, and tiled discovery only when density materially helps.
- Keep item identity and image loading stable.

## Guardrails
- Avoid mixing unrelated layout systems when one fits naturally.
- Avoid oversized controls and custom rows that fight platform conventions.
- Keep searchable and placeholder behavior close to the data surface they affect.
