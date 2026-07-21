---
name: apple-runtime-debugger-ios
description: Focused iOS simulator runtime debugger for Apple projects. Use for narrow simulator inspection and evidence capture after routing; broad reproduce-and-diagnose requests must start with `apple-appdev-workflow:apple-app-orchestrator` and route through `apple-appdev-workflow:apple-debug-orchestrator`.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Runtime Debugger iOS

## Required context
- Load `../../references/apple-runtime-debugging-ios.md`.
- Load `../../references/apple-mcp-workflow.md`.

## Entry rule
- Use this skill directly only for focused iOS simulator runtime work.
- When the request is broad debugging, reproduce-plus-diagnose, or likely-cause analysis, start with `apple-appdev-workflow:apple-app-orchestrator` and let it route through `apple-appdev-workflow:apple-debug-orchestrator`.
- When this skill is activated inside a broad debug workflow, treat it as a runtime evidence station only. It does not own the final user-facing answer.
- If the parent prompt explicitly says the supplied evidence is the entire debugging record and forbids repo/build/simulator work, switch to evidence-only mode: summarize what the supplied runtime evidence proves, call out what remains unverified, and return evidence upward without trying to launch the simulator.

## Responsibilities
- Own iOS simulator runtime debugging and UI-state inspection.
- Prefer `XcodeBuildMCP` for simulator discovery, session defaults, build or run, screenshots, logs, and UI inspection.
- When a request needs real-device behavior, classify the device-only evidence separately and hand it to `apple-appdev-workflow:apple-manual-validation` unless an enabled XcodeBuildMCP device workflow can collect the evidence directly.
- Treat a simulator-only XcodeBuildMCP tool surface as a session-configuration problem, not the intended steady-state for this bundle.
- Keep runtime diagnosis separate from release build or signing workflows.

## Workflow
1. Confirm the intended iOS scheme and whether a simulator is already booted.
   - Evidence-only fast path: if the prompt forbids simulator execution and says the supplied evidence is complete, skip simulator discovery and treat scheme/runtime identity as unknown unless the prompt already provides it.
2. If expected XcodeBuildMCP workflows such as UI automation are missing, call that out as an MCP configuration defect before normalizing shell-heavy fallback behavior.
3. Use `XcodeBuildMCP` to discover the booted simulator and set session defaults.
4. Before the first simulator action that may compile code or touch Xcode build products, set `derivedDataPath` in session defaults to a unique absolute path outside the repo.
   - Use a per-thread or per-run path such as `/tmp/apple-appdev-deriveddata/<repo-slug>-<thread-or-run-id>` or `$CODEX_HOME/tmp/DerivedData/<repo-slug>-<thread-or-run-id>`.
   - Do not use repo-local `DerivedData/`. If one existed before the run, leave it untouched; if the current run created it, remove only that generated directory and rerun with explicit external DerivedData before trusting the runtime evidence.
5. After session defaults are set, use defaults-backed `build_*`, `launch_*`, or `build_run_*` calls without restating project/workspace/scheme/simulator identity unless intentionally changing them.
6. Build and run or relaunch the app as needed, but keep Xcode actions serialized rather than stacking build and test calls concurrently.
7. If a real-device workflow is enabled and intentionally selected, use the device session lifecycle in `../../references/apple-mcp-workflow.md`: open one session, install or launch after code changes, capture UI/log evidence around each interaction, and close the session when done.
8. If a simulator or device build or launch call times out or reports `build.db` / `database is locked`, treat it as XcodeBuildMCP contention or wall-clock exhaustion; do not immediately classify that as app runtime failure.
9. Clear the contention or fall back to raw `xcodebuild` only after that MCP/tool-state explanation is explicit.
10. Inspect UI state, capture screenshots, and collect logs or console output.
11. Reproduce the runtime issue and summarize the evidence.
12. Re-run UI description or logs after layout or state changes.

## Output contract
- Direct focused use only:
  - `Routing: focused subskill`
  - Simulator and scheme used
  - Steps taken to reproduce the issue
  - Relevant on-screen state, screenshots, or log excerpts
  - Likely runtime cause and next debugging step
- When this skill is used under `apple-appdev-workflow:apple-debug-orchestrator`, contribute evidence for the parent debug brigade summary instead of emitting a standalone runtime-debugger summary.
- In orchestrator-led debug work, keep this skill's contribution inside the parent sections such as `Reproduction status`, `Evidence reviewed`, `Likely root cause`, and `Next diagnostic step`.

## Guardrails
- Do not boot simulators automatically unless the user asks.
- In evidence-only mode, do not boot simulators, inspect the repo, or try to gather new runtime artifacts.
- Do not treat this as a release or archive workflow.
- Prefer stable identifiers and refreshed UI inspection over coordinate-based interaction when possible.
- If the active session is missing expected XcodeBuildMCP workflows, state that as an MCP setup defect and recommend fixing the session configuration.
- Do not imply real-device evidence from simulator-only runs. If device workflows are unavailable, route the gap through manual validation instead of inventing a device session.
- Use shell fallback only for real XcodeBuildMCP gaps or while temporarily unblocking a known session-configuration defect.
- Do not repeat project/workspace/scheme/simulator arguments after `session_set_defaults` unless you are intentionally changing those defaults.
- Do not stack `build_sim`, `test_sim`, or `build_run_sim` calls concurrently or immediately after an unresolved timeout against the same DerivedData location.
- Do not share one DerivedData location across parallel Codex threads. Simulator ownership and DerivedData ownership are one evidence-isolation boundary.
- Do not delete a user's existing local DerivedData while cleaning up runtime evidence. Only clean per-run DerivedData paths created by the current Codex run.
- When used under a broad debug workflow, do not let this skill become the visible routing layer or final answer shape.
- Do not end orchestrator-led debug work with headings such as `Result`, `Likely Cause`, or `What To Change First`; those belong inside the parent debug brigade summary.
