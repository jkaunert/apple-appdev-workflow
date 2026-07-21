---
name: apple-runtime-debugger-macos
description: Focused macOS runtime debugger for Apple projects. Use for narrow app-state inspection and evidence capture after routing; broad reproduce-and-diagnose requests must start with `apple-appdev-workflow:apple-app-orchestrator` and route through `apple-appdev-workflow:apple-debug-orchestrator`.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Runtime Debugger macOS

## Required context
- Load `../../references/apple-runtime-debugging-macos.md`.
- Load `../../references/apple-mcp-workflow.md`.

## Entry rule
- Use this skill directly only for focused macOS runtime work.
- When the request is broad debugging, reproduce-plus-diagnose, or likely-cause analysis, start with `apple-appdev-workflow:apple-app-orchestrator` and let it route through `apple-appdev-workflow:apple-debug-orchestrator`.
- When a broad accessibility workflow needs live macOS runtime evidence, accessibility tree inspection, launched-app state, or path-aware screenshot capture, this skill may be activated as an evidence-only station under `apple-appdev-workflow:apple-accessibility-orchestrator`.
- When this skill is activated inside a broad debug workflow, treat it as a runtime evidence station only. It does not own the final user-facing answer.

## Responsibilities
- Own pragmatic macOS runtime debugging for app targets.
- Use `XcodeBuildMCP` first for project discovery, scheme selection, build, launch, and stop flows.
- Use shell tools only for the parts XcodeBuildMCP does not currently cover cleanly for macOS, such as log streaming or screenshots.
- When the issue depends on hardware, permissions, external files, display state, or other real-device/manual conditions, separate MCP-collected runtime evidence from pending manual validation.
- When shell screenshots are needed, prefer the exact `.app` path returned by `build_run_macos` or `get_mac_app_path` and route capture through `scripts/capture_macos_app_screenshot.sh --app-path <AppPath> --window-only`.
- When used under `apple-appdev-workflow:apple-accessibility-orchestrator`, contribute only runtime accessibility evidence such as launched-app state, accessibility tree inspection, focus observations, exact app-path capture status, or explicit degraded-evidence notes.
- Keep runtime diagnosis separate from archive, signing, and release workflows.

## Workflow
1. Confirm the macOS target, scheme, and whether the task is launch failure, runtime behavior, logs, or UI-state diagnosis.
2. Use `XcodeBuildMCP` discovery and build settings tools to confirm the scheme and debug configuration.
3. Build and launch the macOS app with `XcodeBuildMCP` unless a real MCP gap blocks the path.
4. Capture runtime evidence with the narrowest justified mix of MCP output, logs, screenshots, or app-state observations.
   If you need a screenshot after launching a built app, capture the exact bundle you launched rather than activating by app name.
5. For manual or device-specific evidence, keep the app/session lifecycle explicit: identify the built app or device used, launch once per validation pass, collect before/after evidence for each interaction, and close or stop the app/session when the pass is complete.
6. Summarize the runtime behavior, likely cause, and next debugging step.

## Output contract
- Direct focused use only:
  - `Routing: focused subskill`
  - macOS target and scheme used
  - Launch or runtime steps taken
  - Relevant logs, screenshots, or observed state
  - Likely cause and next debugging step
- When this skill is used under `apple-appdev-workflow:apple-debug-orchestrator`, contribute runtime evidence to the parent debug brigade summary instead of emitting a standalone runtime-debugger summary.
- In orchestrator-led debug work, keep this skill's contribution inside the parent sections such as `Reproduction status`, `Evidence reviewed`, `Likely root cause`, and `Next diagnostic step`.
- When this skill is used under `apple-appdev-workflow:apple-accessibility-orchestrator`, contribute runtime evidence to the parent accessibility brigade summary instead of emitting a standalone runtime-debugger summary.
- In orchestrator-led accessibility work, keep this skill's contribution inside the parent sections such as `Accessibility scope`, `Overall assessment`, `Validation checklist`, and `Manual checks`.

## Guardrails
- Do not imply full iOS-simulator-style UI interaction for macOS if the current tool surface does not provide it.
- Do not turn runtime debugging into release engineering or archive validation.
- Prefer MCP-backed build and launch paths, then use narrow shell evidence capture only for true macOS tooling gaps.
- Do not treat MCP launch evidence as a substitute for manual permission, file-provider, multi-display, or hardware evidence when those surfaces are part of the claim.
- Do not use generic app-name activation such as `tell application "<Name>" to activate` when an exact built `.app` path is available; it can foreground a stale same-named bundle.
- When used under a broad debug workflow, do not let this skill become the visible routing layer or final answer shape.
- When used under a broad accessibility workflow, do not let this skill become the visible routing layer or final answer shape.
- Do not end orchestrator-led debug work with headings such as `Result`, `Likely Cause`, or `What To Change First`; those belong inside the parent debug brigade summary.
