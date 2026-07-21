---
name: apple-swiftui-ui-patterns
description: SwiftUI UI composition and app-shell patterns for Apple projects. Use when building or restructuring SwiftUI screens, app shells, tab and navigation flows, sheets, forms, search, overlays, focus, component-driven UI, official SwiftUI specialist best-practice work involving structure, data flow, environment, ForEach, localization, modifiers, soft deprecations, or SwiftUI SDK 27 source-compatibility updates that affect UI composition.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple SwiftUI UI Patterns

## Required context
- Load `../../references/swiftui-ui-patterns-index.md`.
- Load only the specific pattern references needed for the current task.
- Load `../../references/swiftui-specialist-integration.md` when the task asks for official SwiftUI best practices, broad SwiftUI review, or SwiftUI structure, data flow, environment, `ForEach`, localization, modifiers, animation, soft-deprecation, or SDK 27 compatibility guidance.
- Load `../../references/swiftui-sdk27-compatibility.md` when the task mentions SwiftUI SDK 27, Xcode 27, post-SDK-update SwiftUI compile errors, or SDK 27 deprecations/source compatibility.
- Load `../../references/apple-architecture-baselines.md` when shell wiring affects DI or navigation boundaries.
- Load `../../references/apple-mcp-workflow.md`.

## Responsibilities
- Own modern SwiftUI composition and component-selection patterns.
- Guide root shell wiring for tabs, navigation stacks, sheets, settings, search, overlays, media, and focus.
- Fold official SwiftUI specialist topics into the right station instead of routing to unmanaged parallel skills.
- Prefer SwiftUI-native state and environment injection while respecting the bundle's service-based architecture and navigation boundaries.
- Keep UI pattern advice aligned with accessibility, testing, and performance guardrails.

## Workflow
1. Classify the UI shape: app shell, screen composition, list or form, search, modal flow, split view, media, or input-heavy flow.
2. Check whether the task matches a SwiftUI specialist topic such as structure, data flow, environment, `ForEach`, localization, modifiers, animation, soft deprecations, or SDK 27 source compatibility.
3. Identify state ownership and environment dependencies before choosing components.
4. Choose the narrowest pattern reference that matches the task.
5. For SDK 27 source-compatibility work, classify whether the change is a compile fix, deprecation cleanup, new API adoption, or availability-gated fallback before editing code.
6. Keep feature logic in services or models; keep SwiftUI views focused on layout and local orchestration.
7. Activate `apple-appdev-workflow:apple-design-system-ux` when visual hierarchy, tokens, localization layout, or adaptive layout decisions matter.
8. Activate `apple-appdev-workflow:apple-accessibility-foundations` when interactive UI or user-facing content changes.
9. Activate `apple-appdev-workflow:apple-swiftui-performance-audit` when the chosen pattern risks update storms, layout thrash, identity churn, or expensive rendering.

## Output contract
- Chosen SwiftUI pattern and why it fits
- State ownership and dependency-injection notes
- Routing or presentation model when relevant
- Key pitfalls to avoid
- Follow-on skills activated

## Guardrails
- Do not default-load the raw exported SwiftUI specialist corpus or route around this bundle's SwiftUI stations.
- Do not collapse service boundaries into views just because SwiftUI supports local state.
- Do not introduce view models by default when a simpler MV-style view plus service boundary is sufficient.
- Do not duplicate navigation or sheet routing logic across screens when a shared shell or router already exists.
- Do not let `apple-appdev-workflow:apple-product-surface-orchestrator` lose final-answer ownership when broad product-surface brigade routing is active.
- When `apple-appdev-workflow:apple-product-surface-orchestrator` is active, return evidence upward only; do not emit the final user-facing answer.
- Keep advice platform-aware for iPhone, iPad, and macOS when the task spans multiple Apple targets.
- Do not present SDK 27 beta or export-derived SwiftUI details as stable without local SDK evidence or current Apple documentation.
