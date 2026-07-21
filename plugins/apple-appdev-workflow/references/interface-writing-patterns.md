# Interface Writing Patterns

Use behind `apple-appdev-workflow:apple-interface-writing` for product copy inside Apple apps.

## Core rules
- Lead with the user's need, not implementation detail.
- Keep wording short, specific, and localizable.
- Use direct action labels instead of generic confirmations.
- Match tone to the moment: warmer in onboarding, more direct in errors and destructive flows.

## Common surfaces
- Alerts and dialogs: explain what happened, why it matters, and what action follows.
- Errors: say what failed and how to recover; avoid codes and filler.
- Destructive actions: name the object and consequence clearly.
- Empty states: say what belongs here and how to make progress.
- Onboarding and settings: explain value and tradeoffs plainly.
- Buttons and inline instructions: keep them action-oriented and compact.

## Accessibility and localization
- Avoid idioms, sarcasm, and culturally narrow references.
- Keep labels understandable out of visual context.
- Prefer phrasing that survives text expansion.

## Guardrails
- This is product-interface writing, not marketing or brand copy.
- If an existing voice guide exists, use it; if not, infer carefully from current UI.
- Clarity wins over personality in high-friction moments.
