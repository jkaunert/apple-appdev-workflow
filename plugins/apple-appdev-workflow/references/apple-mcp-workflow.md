# Apple MCP Workflow

This reference describes how MCP-backed tools fit into the Apple Codex workflow.

## Purpose
- Use MCP capabilities to reduce context loss and improve Xcode-aware execution.
- Keep critical decisions mirrored in markdown artifacts; MCP memory is support, not source of truth.

## Core MCP roles

### Xcode-headless host override
- If the active host is Xcode CodingAssistant or the installed artifact is the
  `xcode-headless` profile, apply `xcode-headless-host-policy.md` and
  `xcode-headless-tool-adapter.md` before the default XcodeBuildMCP rules
  below.
- In that host profile, the same Apple workflow graph remains active, but
  native `xcode-tools` owns Xcode-aware file, build, test, documentation,
  issue, preview, and project operations. `xcode-proxy` is an optional bridge
  extension for capabilities native `xcode-tools` does not expose in the
  current session, and `codex-fork-headless` is the deterministic orchestration
  backend rather than the default Xcode tool owner.
- The absence of `XcodeBuildMCP` is expected in `xcode-headless`; do not treat
  it as an MCP configuration defect unless the session is not actually running
  the Xcode-headless profile or the user explicitly asked to compare
  XcodeBuildMCP.

### XcodeBuildMCP
- Primary role: Xcode-aware build, test, scheme, destination, and project execution support.
- This bundle expects the default XcodeBuildMCP workflow set to be enabled in Codex sessions, including coverage, UI automation, logging, device, macOS, project discovery, project scaffolding, session management, simulator, simulator management, Swift package, utilities, and the Xcode IDE bridge workflow when live Xcode refresh or Xcode-side tool bridging is needed.
- Treat `doctor` and `workflow-discovery` as conditional XcodeBuildMCP capabilities, not default bundle requirements. `doctor` requires `XCODEBUILDMCP_DEBUG=true`; `workflow-discovery` requires `XCODEBUILDMCP_EXPERIMENTAL_WORKFLOW_DISCOVERY=true`.
- Treat `xcode-ide` as host-gated even when declared in config. Native Xcode IDE bridge proxying requires a compatible macOS/Xcode host; macOS versions below `26` or Xcode versions below `26` should be classified as `xcode-ide-unavailable-host`, then fall back to ordinary XcodeBuildMCP project, simulator, package, logging, and UI automation workflows.
- For hosts affected by repeated `xcrun mcpbridge` reconnect churn, use the
  source-checkout `codex-cli/xcode-mcp-proxy-manager.sh` helper to keep a local
  LaunchAgent-managed `mcp-proxy` server in front of `xcrun mcpbridge`.
  Registering `http://127.0.0.1:9876/mcp` is a fork-local workaround, not a
  marketplace requirement.
- Xcode's CodingAssistant uses a separate Codex home. When validating this
  workaround from inside Xcode, register the same proxy with
  `xcode-codingassistant-register`; leave Xcode's built-in `xcode-tools` entry
  in place unless the Xcode integration itself needs a targeted rollback test.
- Swift package describe, build, and test workflows are first-class MCP support in this bundle, not fallback-only behavior.
- If a Codex session exposes only the simulator subset, treat that as an MCP configuration defect and fix the XcodeBuildMCP workflow configuration before normalizing broad shell fallbacks.
- Operational rules:
  - Start with `session_show_defaults`; if project, workspace, scheme, or simulator defaults are missing, discover them and set them once with `session_set_defaults`.
  - Before the first Xcode build, test, run, clean, or archive action in a Codex thread, set `derivedDataPath` once to a unique absolute path outside the repo. Use a per-thread or per-run path such as `/tmp/apple-appdev-deriveddata/<repo-slug>-<thread-or-run-id>` or `$CODEX_HOME/tmp/DerivedData/<repo-slug>-<thread-or-run-id>`.
  - Never write generated Xcode build products into repo-local `DerivedData/`. If repo-local `DerivedData/` already exists before the run, leave it untouched and use an external `derivedDataPath`; if the current run creates repo-local `DerivedData/`, treat that as a control-plane leak and remove only the directory that this run created.
  - After defaults are set, do not repeat `projectPath`, `workspacePath`, `scheme`, `simulatorName`, `simulatorId`, or `derivedDataPath` on ordinary `build_*`, `test_*`, or `build_run_*` calls unless you are intentionally changing the defaults. Repeating them can duplicate Xcode flags such as `-scheme`.
  - Run only one Xcode build, test, run, clean, or archive action at a time against the same DerivedData location. Do not overlap `build_*`, `test_*`, or `build_run_*` calls.
  - Parallel Codex threads must not share one DerivedData location. Simulator ownership and DerivedData ownership are one isolation boundary for runtime evidence.
  - Cleanup may remove only managed per-run DerivedData paths that Codex created. Do not delete a user's existing `~/Library/Developer/Xcode/DerivedData`, repo-local `DerivedData/`, or custom derived-data directory.
  - Before collecting runtime evidence from a simulator or launched app, run the Apple automation isolation preflight or pass `--require-apple-automation-isolation` to bundle harnesses that support it.
  - The isolation preflight is required for runtime-evidence smokes, accessibility/runtime screenshots, broad debugging reproduction, and release evidence that depends on launched app or simulator state. It is not required for text-only contract smokes.
  - Treat a strict isolation failure as invalid runtime evidence. Resolve booted simulator state, active `Simulator.app`, external `codex app-server` / `xcodebuildmcp` ownership, active `xcodebuild`, or active `simctl` before scoring the smoke.
  - If a tool call times out or reports `build.db` / `database is locked`, treat that as in-flight build contention or tool-wall-clock exhaustion, not immediate app evidence. Do not start a second Xcode action until the first has clearly ended, the build state has been cleaned, or you have switched to a fallback path.
  - For heavy simulator validation, prefer the smallest single action that answers the question, such as `test_sim` or `build_run_sim`, instead of stacking separate compile and test calls. If the MCP call ceiling is the blocker, say so explicitly and then fall back to raw `xcodebuild`.
  - Do not jump to raw `xcodebuild` for convenience checks such as `-showBuildSettings`, one-off destination inspection, or because the MCP defaults are already known. If shell fallback is necessary, state the specific MCP gap, timeout, lock, or tool-state defect first and keep the fallback command as narrow as possible.
  - For real-device evidence, use an explicit session lifecycle when the
    device workflow is available: start or select one device session, install
    and run only after the intended build or code change, capture screenshot,
    hierarchy, and logs before and after each meaningful interaction, retry a
    failed interaction once after refreshing state, and close the session when
    done. If device workflows are not available, record the gap as manual
    validation pending instead of treating simulator evidence as equivalent.
- Use when:
  - you need target or scheme aware build/test help
  - you want Xcode project integration instead of raw shell-only execution
  - release validation depends on Xcode-specific behavior
- Once a greenfield scaffold or project-adoption workflow has produced or located an Xcode project, switch to XcodeBuildMCP as the default execution path outside Xcode-headless. Inside Xcode-headless, keep the same workflow owner and use the native tool adapter in `xcode-headless-tool-adapter.md`.
- For package-native adoption, use the MCP `swift_package_*` workflows and `swift package describe` as the default execution path even when no `.xcodeproj` or `.xcworkspace` exists.
- Fallback: direct `xcodebuild` commands.

### Memory
- Primary role: persist concise project or workflow facts across long-running work.
- Use when:
  - important context may be lost through compression
  - architectural decisions or recurring gotchas should survive future turns
- Rule: mirror critical decisions in plain markdown notes as well.

## Workflow by phase
- Orchestration: memory for prior decisions and model-native reasoning for plan shape.
- Discovery: memory for known gotchas, `apple-appdev-workflow:fetch-apple-docs` for current Apple docs, XcodeBuildMCP for project-aware inspection outside Xcode-headless, and the Xcode-headless native tool adapter for project-aware inspection inside Xcode-headless.
- Architecture: memory for historical constraints and `apple-appdev-workflow:fetch-apple-docs` for framework decisions.
- Implementation: XcodeBuildMCP for build and test loops outside Xcode-headless, the Xcode-headless native tool adapter for Xcode-hosted build and test loops inside Xcode-headless, and `apple-appdev-workflow:fetch-apple-docs` for API checks.
- Validation: XcodeBuildMCP first outside Xcode-headless. Inside Xcode-headless, preserve the selected Apple owner, then use native `xcode-tools` first, `xcode-proxy` for missing bridge capabilities, and raw `xcodebuild` fallback only for real host-tool gaps after the gap has been called out explicitly. Convenience-only shell checks are not a valid reason to leave the active host tool lane.

## Setup files in this bundle
- `codex-cli/config.mcp.toml`
- `codex-cli/config.full.toml`
- `codex-cli/setup-codex-mcp.sh`
- `codex-cli/xcode-mcp-proxy-manager.sh`
