---
name: apple-swiftui-view-refactor
description: SwiftUI view refactor workflow for Apple projects. Use when cleaning up large view files, stabilizing view trees, reducing unnecessary view-model usage, standardizing Observation and dependency handling, applying official SwiftUI specialist refactor guidance for structure, data flow, environment, ForEach identity, modifiers, soft deprecations, localization, or resolving SwiftUI SDK 27 source-compatibility refactors in SwiftUI views.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple SwiftUI View Refactor

## Required context
- Load `../../references/swiftui-view-refactor.md`.
- Load `../../references/swiftui-mv-patterns.md`.
- Load `../../references/ui-decoupling-baseline.md`.
- Load `../../references/swiftui-specialist-integration.md` when the refactor involves official SwiftUI specialist topics: structure, data flow, environment, `ForEach` identity, modifiers, localization, animation, soft deprecations, or SDK 27 source compatibility.
- Load `../../references/swiftui-sdk27-compatibility.md` when a refactor is driven by SwiftUI SDK 27, Xcode 27, post-SDK-update compile errors, or SDK 27 deprecations/source compatibility.
- Load `../../references/apple-mcp-workflow.md`.

## Responsibilities
- Own SwiftUI view-file cleanup, ordering, extraction, and stable-tree refactors.
- Fold official SwiftUI specialist refactor guidance into station-owned behavior instead of using unmanaged parallel skills.
- Keep views pure and lightweight while preserving explicit DI and service boundaries.
- Standardize Observation usage and remove unnecessary optional or ad hoc view-model patterns.
- Keep refactors behavior-preserving unless the task explicitly includes behavior change.

## Workflow
1. Identify whether the problem is file organization, unstable structure, oversized body logic, or unnecessary model indirection.
2. Classify any official SwiftUI specialist topic: view invalidation boundaries, narrow inputs, Observation granularity, environment invalidation, data-driven identity, conditional modifiers, localization, animation, soft deprecations, or SDK 27 compatibility.
3. Reorder the file into a consistent top-to-bottom structure.
4. Split oversized sections into focused subviews without moving business logic into the UI layer.
5. Stabilize the root view tree and localize conditions to sections or modifiers where possible.
6. If the refactor is SDK-compatibility driven, preserve behavior first and avoid opportunistic adoption of unrelated new SwiftUI APIs.
7. Prefer MV-style SwiftUI composition unless the existing architecture clearly requires a different pattern.
8. Activate `apple-appdev-workflow:apple-swiftui-performance-audit` when the refactor touches identity churn, invalidation breadth, or layout thrash.
9. Activate `apple-appdev-workflow:apple-swift-testing-foundations` when behavior changes require test updates.

## Output contract
- Refactor goals
- Structural changes made or recommended
- State and dependency-handling notes
- Behavior risks and validation needs
- Follow-on skills activated

## Guardrails
- Do not default-load the raw exported SwiftUI specialist corpus or route around this bundle's SwiftUI stations.
- Do not move domain logic into views while removing view-model indirection.
- Do not introduce new architectural layers just to reorganize a file.
- Do not swap one unstable root-level conditional tree for another.
- Do not let `apple-appdev-workflow:apple-product-surface-orchestrator` lose final-answer ownership when broad product-surface brigade routing is active.
- When `apple-appdev-workflow:apple-product-surface-orchestrator` is active, return evidence upward only; do not emit the final user-facing answer.
- Preserve public behavior and calling conventions unless the task explicitly asks for redesign.
- Do not present SDK 27 beta or export-derived SwiftUI details as stable without local SDK evidence or current Apple documentation.
