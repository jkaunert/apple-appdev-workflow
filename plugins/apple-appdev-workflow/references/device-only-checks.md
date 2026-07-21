# Device-only Checks

These checks must not be treated as simulator-complete unless the project has explicit evidence that simulator behavior is equivalent.

## Common iOS checks
- camera capture and permissions
- microphone capture and permissions
- photo library import/export
- notifications and notification settings interactions
- biometrics and secure auth flows
- haptics
- backgrounding and foregrounding
- deep links and handoff from external apps
- file import/export with real filesystem providers
- keyboard, autofill, and clipboard behavior
- network transitions such as Wi-Fi to cellular

## Common macOS checks
- file open/save panels and security-scoped access
- drag and drop from Finder
- menu bar commands and shortcuts
- window restoration, multi-window behavior, and focus changes
- system permissions such as camera, microphone, desktop, documents, and downloads

## Device-only accessibility reminders
- VoiceOver on real hardware where rotor, gestures, or focus order matter
- Dynamic Type or display scaling where real-device rendering differs
- Switch Control, Voice Control, or Full Keyboard Access when claims depend on them

## Rule
- If one of these surfaces changed, manual validation should report device evidence or explicitly mark it as pending.
- Device checks should name the device or app session lifecycle: selected
  device/app, install or launch method, before/after evidence captured for each
  interaction, and whether the session was closed or left pending for a human.
