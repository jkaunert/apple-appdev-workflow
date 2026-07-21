# App Bootstrap SPM Layout

## Phase 1 Scope
SPM support is optional and intentionally narrow.

## Supported Layout Modes
- `single-target`
- `app-plus-packages`

## Optional Local Packages
- `AppCore`
- `AppServices`
- `AppDesignSystem`
- `AppTestSupport`

## Guardrails
- Do not make packages the default.
- Do not create all packages automatically.
- Use packages only when the user asks for some initial modular separation.
- Keep the starter app viable without packages.

## Phase 2 Expectations
- explain package ownership boundaries in generated docs
- keep package creation explicitly opt-in
- prefer a small number of packages over premature package sprawl
