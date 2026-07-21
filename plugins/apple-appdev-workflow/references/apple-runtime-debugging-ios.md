# Apple Runtime Debugging iOS

Use this reference for iOS simulator runtime diagnosis.

## Preferred flow
- Confirm a booted simulator before attempting runtime interaction.
- Before treating simulator observations as evidence, run `python3 scripts/check_apple_automation_isolation.py --strict` or use a harness with `--require-apple-automation-isolation`.
- Set XcodeBuildMCP session defaults with the project or workspace, scheme, simulator, and debug configuration.
- After defaults are set, use defaults-backed build and launch calls without repeating project/workspace/scheme/simulator arguments unless the target identity is changing.
- Build and run or relaunch the app using Xcode-aware tools.
- Keep Xcode build, test, and run actions serialized. If a call times out or reports `build.db` / `database is locked`, resolve the contention or use explicit shell fallback instead of treating that timeout alone as app evidence.
- Capture screenshots, UI descriptions, and simulator logs after reproducing the issue.

## Guardrails
- Refresh UI inspection after layout or navigation changes.
- Prefer labels or identifiers over coordinates for interaction when the tool surface supports them.
- Separate runtime reproduction from release or archive work.
- Do not score simulator screenshots, UI hierarchy, logs, or reproduction status when the strict isolation preflight reports booted simulator drift or external Apple automation ownership.
- In broad debug workflows, treat runtime-station observations as evidence for the parent debug brigade summary rather than a standalone final answer.
