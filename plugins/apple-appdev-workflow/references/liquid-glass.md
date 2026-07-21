# Liquid Glass

Use behind `apple-appdev-workflow:apple-liquid-glass` for iOS 26+ SwiftUI work.

## Baseline
- Prefer native Liquid Glass APIs over custom blur approximations.
- Gate all usage with availability checks and define fallbacks for earlier systems.
- Apply glass modifiers after layout and visual modifiers.
- Use `GlassEffectContainer` when multiple glass surfaces coexist.
- Keep shapes and prominence consistent across related elements.

## Recommended usage
- Use glass for surfaces, chips, controls, or cards that benefit from layered material depth.
- Use interactive glass only on interactive elements.
- Use `glassEffectID` with a namespace only when morphing transitions genuinely improve continuity.
- Pair glass adoption with design-principles review so hierarchy remains clear.

## Guardrails
- Do not treat Liquid Glass as a global styling mode.
- Do not skip fallback behavior.
- Do not introduce costly animation or stacking effects without a clear UX win.
- Re-check performance when many glass surfaces animate together.
