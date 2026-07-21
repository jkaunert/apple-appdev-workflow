# Accessibility Playbook

Use this reference for common failure patterns and the safest default remediation.

## Common failures

### Icon-only controls announce generic output
- Add a meaningful label.
- Keep the label aligned with the user-facing action, not the symbol name.

### Text does not scale
- Replace fixed font sizes with scalable text styles.
- Scale custom spacing or icon sizing with the platform's text-scaling tools when needed.

### Layout breaks at large text sizes
- Prefer adaptive stacks, content wrapping, or component variants instead of text shrinking.
- Avoid `minimumScaleFactor` as the primary fix.

### Custom tap surfaces are not discoverable
- Prefer native `Button` or platform-native controls.
- If custom interaction is required, add the correct semantics, role, and label.

### State is only visible through color
- Add text, shape, iconography, or spoken state so grayscale and VoiceOver users can distinguish it.

### Dynamic updates are silent
- Manage focus or post announcements when async loads, validation errors, or screen transitions would otherwise be missed.

### Dense cells create too many VoiceOver stops
- Group related content when that improves comprehension.
- Do not group content if it hides important interactive affordances.

## Escalation rule
If the same accessibility problem appears in multiple screens, propose a shared component or design-system fix before screen-local duplication.
