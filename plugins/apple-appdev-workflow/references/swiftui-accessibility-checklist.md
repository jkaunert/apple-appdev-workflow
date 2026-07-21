# SwiftUI Accessibility Checklist

Use after SwiftUI accessibility changes.

## Verify
- Icon-only controls have meaningful labels.
- Visible-text controls are not redundantly relabeled.
- Headers, grouping, and reading order make sense with VoiceOver.
- Dynamic Type scales through the largest supported sizes without clipping essential content.
- Focus order remains predictable on macOS and keyboard-enabled iPad flows.
- Touch targets remain comfortably sized on iOS.
- Motion-heavy transitions respect Reduce Motion.
- State and status are understandable without color.
