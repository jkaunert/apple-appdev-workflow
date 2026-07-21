# App Bootstrap Backend Policy

## Phase 1 Backend
- Use XcodeGen only as an implementation detail for greenfield scaffolding.
- Do not require XcodeGen for adopt mode.
- Do not expose XcodeGen as the conceptual workflow to users.
- Use the bundle's bootstrap scripts as the default greenfield entrypoint, not ad hoc MCP scaffold tools.
- Treat the bundle bootstrap scripts and templates as skill-owned assets resolved from the skill directory, not from the user's workspace.
- If the bundle bootstrap script is blocked by a read-only sandbox, shell temp-file denial, or similar session constraint, fail closed and report bootstrap as blocked.

## Phase 3 Tuist Backend
- Tuist may be used only as an explicit opt-in backend after the relevant Phase
  3 contract is satisfied.
- The Tuist backend contract lives in `references/app-bootstrap-tuist-backend.md`.
- Do not make Tuist the default backend until parity evidence exists.
- Do not silently switch to Tuist because it is installed, or because XcodeGen
  is missing or failed.
- Do not silently switch away from Tuist after a Tuist failure.
- Allow selected local Swift package layouts only when the bootstrap-generated
  graph stays local-only and no `tuist install` or external dependency
  resolution is required.
- Do report Mise availability as advisory provider evidence for project-scoped
  or one-off Tuist management. Missing Mise must not fail a Tuist run when
  `tuist` itself is available.
- Do not configure Tuist Cloud, registry, cache, previews, selective testing,
  external dependencies, CI, signing, or release automation during bootstrap.

## Excluded Backends
- No makefile toolkit in the default Apple bootstrap path.
- No task CLI installation in the default Apple bootstrap path.
- No hand-authored `.xcodeproj` generation.
- No default use of XcodeBuildMCP scaffold-project generators for bundle bootstrap.
- No fallback to XcodeBuildMCP scaffold-project generation after the bundle bootstrap script failed under sandbox or session constraints unless the user explicitly requested that generator.
- No cloning or bulk-renaming of nearby fixture apps as a substitute for the bundle bootstrap scripts.
- No editor- or agent-specific template artifacts such as `.cursor`, `.cursorrules`, `CLAUDE.md`, or similar files unless the user explicitly asks for them.

## Validation Policy
- After project creation, use `XcodeBuildMCP` as the default control plane for discovery, build, run, and test validation.
- If expected XcodeBuildMCP workflows are missing, treat that as a Codex MCP configuration defect and fix it before normalizing shell-heavy fallback.
- `XcodeBuildMCP` becomes the default after a project exists; it is not the default scaffold generator for this bundle.
