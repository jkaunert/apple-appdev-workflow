# Apple Runtime Debugging macOS

Use this reference for pragmatic macOS runtime diagnosis.

## Preferred flow
- Confirm the target scheme and debug configuration first.
- Before treating launched-app observations or screenshots as evidence, run `python3 scripts/check_apple_automation_isolation.py --strict` or use a harness with `--require-apple-automation-isolation`.
- Use `XcodeBuildMCP` first for project discovery, build, launch, and stop.
- Launch or relaunch the app, then capture logs and screenshots around the reproduced behavior.
- When the built app path is known, prefer path-aware shell capture so the screenshot is taken from the exact bundle you launched rather than any same-named installed app.
- Use shell tools only for the parts XcodeBuildMCP does not currently cover cleanly for macOS runtime inspection.

## Fallback shell patterns
- `xcodebuild -scheme <Scheme> -destination 'platform=macOS' build`
- `open <AppPath>` for launching a built app when appropriate
- `log stream --predicate 'process == "<ProcessName>"'`
- `bash scripts/capture_macos_app_screenshot.sh --app-path <AppPath> --label <Label> --window-only` for deterministic window capture of a built app
- `screencapture -x <file>` for screenshots when needed

## Guardrails
- Treat this as runtime debugging, not archive or signing validation.
- Do not score launched-app screenshots, logs, or reproduction status when the strict isolation preflight reports external Apple automation ownership or active global capture/build state.
- Be explicit when a limitation comes from the current macOS MCP tool surface rather than the app itself.
- Avoid `tell application "<AppName>" to activate` when an exact app path is available; same-named stale bundles can be frontmost instead of the debug build.
- In broad debug workflows, treat runtime-station observations as evidence for the parent debug brigade summary rather than a standalone final answer.
