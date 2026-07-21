# Manual Validation Evidence

## Evidence format
Always report manual validation in concrete terms:

- target build or commit
- device and OS used
- journeys validated
- result for each checked journey
- pending checks
- blockers
- accepted risks

## Status model
- `validated`
- `pending manual check`
- `blocked`
- `follow-up after ship`

## Rules
- Do not say "ready to ship" without listing the evidence behind that call.
- Do not collapse pending manual checks into generic confidence language.
- If validation was simulator-only, say so plainly.
- If a risk was accepted rather than resolved, state it explicitly.
