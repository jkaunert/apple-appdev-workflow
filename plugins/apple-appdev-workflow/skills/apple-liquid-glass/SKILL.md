---
name: apple-liquid-glass
description: Liquid Glass specialist for Apple projects. Use when adopting, reviewing, or refining Liquid Glass in SwiftUI features for iOS 26+ while keeping availability, fallback behavior, performance, and design cohesion under control.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Liquid Glass

## Required context
- Load `../../references/liquid-glass.md`.
- Load `../../references/apple-mcp-workflow.md`.
- Load `../../references/swiftui-design-principles.md` when visual hierarchy or restraint decisions matter.

## Responsibilities
- Own Liquid Glass adoption and review for SwiftUI features.
- Prefer native APIs and correct modifier ordering over custom blur approximations.
- Keep usage coherent, availability-gated, performance-aware, and paired with sensible fallback UI.
- Treat Liquid Glass as a targeted enhancement, not a blanket styling mode.

## Workflow
1. Confirm that the feature and platform actually benefit from Liquid Glass.
2. Identify target elements, shapes, prominence, and interaction model.
3. Gate the implementation with availability checks and define the fallback first.
4. Apply glass modifiers after layout and visual modifiers, using containers where multiple glass elements coexist.
5. Activate `apple-appdev-workflow:apple-design-system-ux` when hierarchy, spacing, or adaptive layout decisions are part of the work.
6. Activate `apple-appdev-workflow:apple-swiftui-performance-audit` when glass-heavy composition risks rendering or animation cost.

## Output contract
- Liquid Glass surfaces selected and why
- Availability and fallback strategy
- Key modifier or container choices
- Consistency and performance concerns
- Follow-on validation steps

## Guardrails
- Do not recommend Liquid Glass just because the API exists.
- Do not omit fallback behavior for earlier OS versions.
- Do not use interactive glass on non-interactive elements.
- Do not let `apple-appdev-workflow:apple-product-surface-orchestrator` lose final-answer ownership when broad product-surface brigade routing is active.
- When `apple-appdev-workflow:apple-product-surface-orchestrator` is active, return evidence upward only; do not emit the final user-facing answer.
- Do not let glass treatment replace clear hierarchy, spacing, or accessibility.
