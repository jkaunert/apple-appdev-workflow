# Accessibility Foundations

Use this reference as the baseline policy for Apple UI work.

## Accessibility is first-draft work
- Build accessibility into the first implementation.
- Prefer native controls before custom interaction surfaces.
- Escalate shared-component or design-system fixes before proposing screen-local hacks.

## Intake before advising
Identify these before applying detailed fixes:
- UI framework in scope: SwiftUI, UIKit, AppKit, or mixed
- Platforms and deployment floor
- Localization constraints for labels, hints, and values
- Assistive technologies affected: VoiceOver, Voice Control, keyboard/focus, Dynamic Type, Reduce Motion, contrast, Switch Control, captions, audio descriptions
- Whether the request is implementation, audit, remediation, or release readiness

## First-draft rules
- Icon-only controls need a meaningful accessibility label.
- Visible text should usually remain the accessible label without override.
- Decorative imagery should be hidden from assistive technologies.
- State must not be communicated by color alone.
- Motion should respect Reduce Motion preferences.
- Text should use scalable styles, not fixed font sizes.
- Interactive targets should remain comfortably reachable.
- Dynamic content changes need focus management or announcements when users would otherwise miss them.
- Accessibility strings should follow project localization conventions.

## Routing
- SwiftUI view changes: load `apple-appdev-workflow:swiftui-accessibility-auditor`.
- UIKit screen or control changes: load `apple-appdev-workflow:uikit-accessibility-auditor`.
- AppKit screen or control changes: load `apple-appdev-workflow:appkit-accessibility-auditor`.
- Mixed stacks: keep this reference loaded and activate only the auditors that correspond to changed layers.

## Validation baseline
Before closing UI work, verify:
- VoiceOver or spoken feedback coverage for primary journeys
- Dynamic Type or readable scaling behavior
- Keyboard or focus traversal where relevant
- Contrast and non-color affordances
- Motion behavior when Reduce Motion is enabled
- Device-only checks that simulator or static analysis cannot prove

## Release baseline
For release or App Store readiness:
- Do not claim accessibility support without common-task coverage.
- Phrase nutrition-label output as a recommendation tied to reviewed scope.
- Treat a single blocked common task as disqualifying for that label.
