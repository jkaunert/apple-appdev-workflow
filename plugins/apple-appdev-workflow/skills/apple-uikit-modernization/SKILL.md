---
name: apple-uikit-modernization
description: Focused UIKit modernization station for existing iOS and iPadOS apps. Use when replacing legacy UIKit shared-state APIs or app-lifecycle assumptions with scene, trait, window, safe-area, or size-class aware alternatives, including UIScreen.main/mainScreen, interfaceOrientation, UIDevice orientation for layout, UIApplication/shared window lifecycle, scene lifecycle migration, topLayoutGuide/bottomLayoutGuide, hard-coded bar insets, layoutMargins-to-directionalLayoutMargins, and asymmetric safe-area fixes.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple UIKit Modernization

## Required context
- Load `../../references/uikit-modernization.md`.
- Load `../../references/apple-mcp-workflow.md`.
- Load `../../references/ui-decoupling-baseline.md` when modernization changes UIKit object ownership, helper APIs, or presentation flow.
- If the modernization touches user-facing UIKit screens or controls, activate `apple-appdev-workflow:uikit-accessibility-auditor` after the modernization scope is clear.
- If the modernization changes behavior, tests, project files, lifecycle entrypoints, or release risk, route through the parent Apple workflow and involve `apple-appdev-workflow:apple-testing-quality-gates` before closure.

## Entry rule
- Use this skill directly only for focused UIKit modernization asks in existing UIKit or mixed UIKit apps.
- Do not use this skill for greenfield UIKit scaffolding. Existing bootstrap policy still keeps UIKit/AppKit greenfield starters out of the default bundle.
- Do not use this skill as a generic UIKit UI design or accessibility station. Use `apple-appdev-workflow:uikit-accessibility-auditor` for accessibility and the product-surface brigade for broad UX coherence.
- For broad app modernization, release-readiness, branch review, or multi-skill implementation work, start with `apple-appdev-workflow:apple-app-orchestrator` and let the relevant brigade activate this station.

## Responsibilities
- Replace legacy UIKit shared-state and single-window assumptions with local scene, window, trait-collection, safe-area, or size-class aware APIs.
- Preserve the official UIKit modernization export's completeness discipline: every detected target file needs a concrete diff or an explicit skip/ask reason.
- Keep modernization tasks independent. Do not mix `UIScreen`, orientation, scene lifecycle, and safe-area edits in the same file unless the user requested a combined modernization or the reference says the patterns are atomic.
- Keep API and project mutation scoped, reviewable, and validation-gated.

## Workflow
1. Discover the effective project root and classify the request: audit, targeted implementation, broad modernization, or post-SDK migration.
2. Select the active modernization task from `uikit-modernization.md`: `UIScreen`, orientation, scene lifecycle, or safe area.
3. Detect candidate files with targeted searches before editing. Track every file that contains the active target API or pattern.
4. Process files in small batches. For every detected file, produce one of: applied diff, explicit skip reason, or explicit user question for risky choices.
5. Apply obvious local replacements directly when the reference marks them safe; ask before risky signature, lifecycle, Info.plist, `.pbxproj`, or observable behavior changes unless the user already authorized that exact mutation.
6. Preserve control flow, guards, fallbacks, comments with existing migration context, and unrelated formatting.
7. Keep TODOs rare and actionable. A TODO must state why modernization is needed, what the replacement should look like, and the lifecycle/threading concern that blocks immediate replacement.
8. Validate with the narrowest useful gate: source parse, SwiftSyntax changed-files check, build, tests, plist lint, project setting readback, or XcodeBuildMCP build/test as appropriate.

## Output contract
- Routing: `focused subskill`
- Modernization target and files inspected
- Changes applied, skipped files with reasons, and user decisions still needed
- Validation evidence and skipped gates
- Residual compatibility risks
- Follow-on skills activated

## Guardrails
- Do not walk global scene or window state as a replacement for local context. Avoid `UIApplication.shared`, `UIDevice.current`, `UIScreen.main`, and connected-scene scans unless preserving a deprecated forwarding wrapper requires a compatibility bridge.
- Do not replace dynamic values with literals or invented fallback constants.
- Do not silently produce an empty diff for a file containing the active target API.
- Do not collapse `if`/`else`, `switch`, `catch`, availability, nil, or selector guards while changing a target API.
- Do not remove old methods when a deprecate-and-forward pattern is needed; keep the deprecated wrapper and add the new overload.
- Do not use SwiftUI replacements inside UIKit classes. SwiftUI `GeometryReader` or environment values belong only in SwiftUI view code.
- Do not make marketplace-facing claims that this station fully migrates every legacy UIKit app automatically. It provides focused modernization guidance and scoped edits that still require local validation.
