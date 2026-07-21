---
name: apple-design-system-ux
description: Design-system and UX workflow for iOS/macOS applications. Use for tokenized styling, adaptive layouts, shared-component decisions, interaction states, platform-consistent behavior, SwiftUI localization/layout polish, modifier or animation decisions that affect UX, and SwiftUI SDK 27 adaptive toolbar or design-system changes.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Design System UX

## Required context
- Load `../../references/swiftui-design-principles.md`.
- Load `../../references/swiftui-specialist-integration.md` when SwiftUI localization, modifier identity, animation, toolbar/adaptive layout, soft-deprecation, or SDK 27 source-compatibility guidance materially affects the design-system decision.
- Load `../../references/swiftui-sdk27-compatibility.md` when adaptive layout, toolbar, document, or other SwiftUI SDK 27 changes materially affect the design-system decision.
- Load `../../references/apple-mcp-workflow.md`.

## Workflow
1. Apply the spacing, typography, semantic color, and sizing baselines from `swiftui-design-principles.md`.
2. Check whether official SwiftUI specialist guidance changes the UX choice: localized strings and RTL layout, conditional modifiers, animation data, toolbar behavior, soft deprecations, or SDK 27 compatibility.
3. Reuse shared components before creating one-off styles.
4. Validate adaptive behavior on iPhone, iPad, macOS, and widgets as applicable.
5. Activate `apple-appdev-workflow:apple-swiftui-ui-patterns` when the task depends on app-shell, navigation, sheet, list, form, search, or other component-pattern decisions.
6. Activate `apple-appdev-workflow:apple-swiftui-view-refactor` when the request is primarily about cleaning up or restructuring existing SwiftUI view files.
7. Activate `apple-appdev-workflow:apple-interface-writing` when user-facing copy, button labels, errors, empty states, or settings text change materially.
8. Activate `apple-appdev-workflow:apple-liquid-glass` when Liquid Glass adoption or review is explicitly in scope.
9. Activate `apple-appdev-workflow:apple-accessibility-foundations` when accessibility behavior, audits, or release claims are in scope.
10. Activate `apple-appdev-workflow:apple-swiftui-performance-audit` when SwiftUI runtime performance, update fan-out, identity churn, or layout thrash is in scope.
11. Validate interaction states and transitions.

## Guardrails
- Do not default-load the raw exported SwiftUI specialist corpus or route around this bundle's SwiftUI stations.
- Avoid hard-coded visual values when tokens exist.
- Keep interaction patterns platform-appropriate.
- Do not let `apple-appdev-workflow:apple-product-surface-orchestrator` lose final-answer ownership when broad product-surface brigade routing is active.
- When `apple-appdev-workflow:apple-product-surface-orchestrator` is active, return evidence upward only; do not emit the final user-facing answer.
- Push repeated accessibility remediations toward shared components or the design system instead of screen-local duplication.
- Keep visual polish subordinate to clarity, hierarchy, and performance.
- Do not use this skill for same-turn work during broad greenfield bootstrap unless the user explicitly asked to continue after bootstrap or to scaffold and then implement in the same turn.
- Embedded design-system or component preferences inside a scaffold prompt do not count as that continuation signal.
