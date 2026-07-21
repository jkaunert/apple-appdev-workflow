# Accessibility QA Checklist

Use this checklist before concluding UI work or preparing release notes.

## Required verification
- VoiceOver or spoken feedback reaches every primary interactive element.
- Primary flows are usable without relying on color alone.
- Large text or readable scaling does not clip or hide essential content.
- Keyboard or focus traversal remains predictable where supported.
- Hit targets remain comfortably operable.
- Reduced Motion does not leave the UI without necessary feedback.
- Dynamic content changes are announced or focused appropriately.

## Device-only validation
Call out any checks that require real hardware or manual OS setting changes:
- VoiceOver gesture flow
- Voice Control command matching
- Switch Control or Full Keyboard Access traversal
- Captions or audio descriptions for media
- Dark mode and contrast under actual device settings

## Release recommendation gate
If the task affects a primary user journey, state whether accessibility regression risk is:
- Low: no blocked flows found in reviewed scope
- Medium: manual device validation still pending
- High: a primary flow is blocked or unverified
