# App Bootstrap Workflow

## New Mode
1. Collect app name, bundle identifier, platform, output path, and deployment target.
2. If any required field is missing, ask for it in one concise block before proceeding.
3. Do not infer the current directory as the output path unless the user explicitly approves that destination.
4. If the user asks for a suggestion, suggest the resolved bundle default deployment target only; do not invent a separate "modern floor."
5. Never invent the bundle identifier.
6. Keep Phase 1 support narrow: SwiftUI only for greenfield generation.
7. Resolve `scripts/` and `templates/` relative to the bootstrap skill directory, not the user's workspace.
8. Run the bootstrap skill's resolved `scripts/doctor.sh --mode new`.
9. Treat directories containing only `.DS_Store`, `.localized`, or `.gitkeep` as effectively empty; do not force regeneration just for those files.
10. Prefer `--dry-run` before mutating unfamiliar output paths.
11. Do not run `scripts/bootstrap.sh`, even in dry-run mode, until deployment-target provenance is explicit in the current turn: either the user named a target or explicitly approved the bundle default.
12. Run the bootstrap skill's resolved `scripts/bootstrap.sh` with the selected
    layout mode and backend only after that provenance is explicit.
13. If the user approved using the bundle default deployment target, pass `--allow-default-deployment-target` explicitly. Do not rely on omitting `--deployment-target` and letting the script choose silently.
14. Use `xcodegen` as the default backend. Use `tuist` only when explicitly
    selected, for SwiftUI single-target scaffolds or selected local package
    layouts.
15. Use the default `init-main-only` repository policy unless the user or target
    repo context explicitly calls for `harness-topic-ready` or
    `legacy-codex-dev`. Do not support a no-git repository policy for standalone
    scaffolds.
16. If the resolved bootstrap assets are unavailable, stop and report that bootstrap is blocked; do not clone or bulk-rename a nearby fixture as a substitute.
17. Once the project exists, switch to `XcodeBuildMCP` for project-aware discovery and validation outside Xcode-headless instead of continuing with raw `xcodebuild` by default. Inside Xcode CodingAssistant or the `xcode-headless` profile, use native `xcode-tools` first under `xcode-headless-host-policy.md`.
18. Hand off to architecture, design, implementation, testing, and release skills.

## Adopt Mode
1. Confirm the existing project path and that it contains an Xcode project or workspace.
2. Do not regenerate sources.
3. Produce a concrete adopt report covering support status, project shape, test/package signals, and immediate next steps.
4. Report existing git state when available, applied repository policy, forge provider, and the first topic-branch step before implementation.
5. Hand off into discovery, architecture, and validation.

## Validation Handoff
After scaffold or adopt:
- `apple-appdev-workflow:apple-architecture-design`
- `apple-appdev-workflow:apple-design-system-ux`
- `apple-appdev-workflow:apple-feature-implementation`
- `apple-appdev-workflow:apple-swift-testing-foundations`
- `apple-appdev-workflow:apple-testing-quality-gates`

Tooling rule:
- outside Xcode-headless, use `XcodeBuildMCP` first after scaffold or adopt
- inside Xcode-headless, use native `xcode-tools` first and `xcode-proxy` only for missing bridge capabilities
- use raw `xcodebuild` only as fallback for real MCP or host-tool gaps after stating the specific gap
