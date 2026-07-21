# SwiftUI Design Principles

Use this reference behind `apple-appdev-workflow:apple-design-system-ux` when polishing SwiftUI visuals.

## Core baseline
- Favor restraint over decoration.
- Use a consistent spacing rhythm from a small token set.
- Use fewer type sizes with a clear hierarchy.
- Prefer semantic colors over hard-coded palettes.
- Keep component sizing proportional and repeated patterns visually consistent.
- Prefer native-looking materials, grouping, and separators over bespoke ornamentation.

## Spacing baseline
- Use a base 4 or 8 rhythm.
- Typical values: `4, 8, 12, 16, 20, 24, 32, 40, 48`.
- Outer padding: `16-20`.
- Major section spacing: `24-32`.
- Internal grouped spacing: `4-12`.
- Card and row padding: `12-16` vertical and `16` horizontal.

## Typography baseline
- Keep the type scale tight.
- Use hierarchy through weight and placement, not constant size changes.
- Keep font design choices consistent across the app and widgets when they coexist.
- Use tracking sparingly and mostly for compact uppercase labels.

## Color baseline
- Prefer semantic colors such as system backgrounds, `primary`, `secondary`, and separator styles.
- Use opacity only for a few clearly defined purposes.
- Avoid hard-coded visual stacks that fight dark mode, accessibility, or platform tone.

## Component baseline
- Keep repeated controls, cards, and indicators proportionally sized.
- Use matching stroke widths on paired shapes.
- Avoid oversized rows, decorative borders, or gradients that do not add information.
- Push repeated visual patterns toward shared components instead of one-off screens.

## Bundle alignment
- Pair this reference with `apple-appdev-workflow:apple-accessibility-foundations` for interactive UI.
- Pair this reference with `apple-appdev-workflow:apple-swiftui-performance-audit` when visual changes risk layout thrash or heavy redraws.
- Use `apple-appdev-workflow:apple-interface-writing` for user-facing text decisions rather than embedding copy advice here.
