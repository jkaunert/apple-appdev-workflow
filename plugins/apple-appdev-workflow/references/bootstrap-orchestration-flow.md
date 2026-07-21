# Bootstrap Orchestration Flow

Use this reference to keep broad bootstrap workflows sequenced consistently.

## Goal

Separate:
- top-level intake via `apple-appdev-workflow:apple-app-orchestrator`
- bootstrap-domain coordination via `apple-appdev-workflow:apple-bootstrap-orchestrator`
- station execution via `apple-appdev-workflow:apple-app-bootstrap`
- downstream project-aware handoff into architecture, testing, and MCP-backed validation

## Required sequence

1. Start broad bootstrap or adoption work at `apple-appdev-workflow:apple-app-orchestrator`.
2. Emit the first-progress route shape from `bootstrap-brigade-trace-template.md` before discovery narration or scaffold narration. Keep that block bootstrap-brigade-scoped: name `apple-appdev-workflow:apple-bootstrap-orchestrator` and `apple-appdev-workflow:apple-app-bootstrap`, omit `apple-appdev-workflow:apple-app-orchestrator`, and keep a bootstrap discovery, input-confirmation, or preflight sentence as the third line.
3. Run a discovery-first bootstrap scan before choosing `new` or `adopt` behavior.
4. Hand broad bootstrap work to `apple-appdev-workflow:apple-bootstrap-orchestrator`.
5. Let `apple-appdev-workflow:apple-bootstrap-orchestrator` activate `apple-appdev-workflow:apple-app-bootstrap` as the primary station.
6. Confirm scaffold-critical inputs before generation and support/risk status before adopt conclusions.
7. In `new` mode, do not emit any `bootstrap.sh` command, including dry run, until deployment-target provenance is explicit in the current turn: an explicit user target or explicit user approval of the bundle default.
8. For standalone scaffolds, apply the selected repository policy and make the next
   topic-branch step explicit before handing off feature work. The default
   repository policy initializes `main` only; `dev` plus `codex/dev` creation is
   legacy opt-in behavior. A no-git repository policy is not supported for
   standalone scaffolds.
9. Once an Xcode project exists, prefer `XcodeBuildMCP` for follow-on build, run, and test work. For package-native adoption, prefer MCP `swift_package_*` workflows for follow-on describe, build, and test work.
10. For greenfield scaffolds, stop after scaffold, sanity validation, and explicit git or branch handoff. Do not continue into feature implementation unless the user asks in a subsequent turn or explicitly asks to continue after bootstrap completes.
11. During broad greenfield bootstrap, downstream stations such as architecture, design-system, accessibility, and feature implementation are handoff targets only. Do not activate them to do same-turn work.
12. During broad greenfield bootstrap, once scaffold generation completes, allow only non-behavioral baseline alignment required to honor explicit scaffold constraints. Examples: deployment target, Swift version, strict concurrency, strict memory safety, package compatibility, branch handoff metadata, handoff docs that record future-phase constraints, and scaffold-owned local package linkage plus minimal placeholder target structure.
13. During broad greenfield bootstrap, do not turn architecture preferences or pattern lists into same-turn code generation. Concrete product behavior, app-specific source files, services, repositories, coordinators, UI components, package internals, app-to-package UI wiring, files under `Packages/*/Tests`, or behavior-focused tests belong to Phase 2.
14. Embedded implementation preferences inside the scaffold prompt do not count as the continuation signal. Same-turn continuation requires an explicit instruction to continue after bootstrap or to scaffold and then implement in the same turn.
15. If current Apple documentation is needed during bootstrap, make `apple-appdev-workflow:fetch-apple-docs` visible before the first Apple-doc lookup appears in the trace. A final-summary mention is not sufficient after the lookup already happened. If fallback search is required, the fallback reason must appear in the immediately preceding trace step before the first search event.
16. Resolve bootstrap `scripts/` and `templates/` from the skill directory rather than the user's workspace before judging whether the bootstrap assets exist.
17. If the bootstrap script cannot run because the Codex session is read-only, cannot create shell temp files, or otherwise blocks normal script execution, report bootstrap as blocked instead of switching generators.
18. If those skill-owned bootstrap assets are unavailable, report bootstrap as blocked instead of cloning, copying, or renaming a nearby fixture app.
19. End with one bootstrap summary rather than station-local narration.
20. After a scaffold creates a nested repo or project, re-anchor follow-on work to that generated output path instead of leaving execution at the parent shell directory.

## Discovery-first expectations

In `new` mode, discovery should inspect:
- target-path state
- enclosing repo state
- support-matrix fit
- input completeness and contradictions

In `adopt` mode, discovery should inspect:
- Xcode project, workspace, or Swift package shape
- platform and framework signals
- test and package presence
- likely migration and handoff surfaces

## Required bootstrap station

Broad bootstrap workflows should always consider:
- `apple-appdev-workflow:apple-app-bootstrap`

Optional downstream handoff skills depend on the request:
- `apple-appdev-workflow:apple-architecture-design`
- `apple-appdev-workflow:apple-design-system-ux`
- `apple-appdev-workflow:apple-feature-implementation`
- `apple-appdev-workflow:apple-swift-testing-foundations`
- `apple-appdev-workflow:apple-testing-quality-gates`
- `apple-appdev-workflow:apple-accessibility-foundations`

## Failure patterns to avoid

- broad bootstrap requests collapsing directly into `apple-appdev-workflow:apple-app-bootstrap`
- broad bootstrap outputs naming only `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-app-bootstrap` while omitting `apple-appdev-workflow:apple-bootstrap-orchestrator`
- first route blocks naming `apple-appdev-workflow:apple-app-orchestrator` plus `apple-appdev-workflow:apple-bootstrap-orchestrator` while omitting `apple-appdev-workflow:apple-app-bootstrap`
- replacing the first-route bootstrap discovery, input-confirmation, or preflight sentence with `Scope:`, `Mode:`, or any other custom heading
- discovery being skipped or treated as adopt-only
- generation starting before bundle identifier or output path is explicit
- emitting `bootstrap.sh` dry runs with a synthesized deployment target before the user approved a target or the bundle default
- adopt mode pretending the project is supported without concrete findings
- treating a pure Swift package as unsupported solely because no `.xcodeproj` or `.xcworkspace` exists
- defaulting to MCP scaffold-project tools instead of the bundle bootstrap scripts
- falling back to MCP scaffold-project tools after the bundle bootstrap script failed under a read-only or temp-file-blocked session
- treating absence of workspace-local scripts as proof that the bundle bootstrap assets are missing
- cloning, copying, `rsync`-ing, or bulk-renaming a nearby fixture app instead of using the bundle bootstrap scripts
- generating editor-specific files, unexpected workspace wrappers, or unrequested package layouts
- treating standalone repository-policy handoff as optional instead of required before feature work
- treating no-git scaffolding as a valid standalone repository policy
- letting the first Apple-doc-related trace event be a generic search or unlabeled Sosumi transport and only naming `apple-appdev-workflow:fetch-apple-docs` later in the summary
- letting a fallback Apple-doc search appear before the explicit fallback reason and only explaining the fallback afterward
- letting scaffold passes drift into implementation because the prompt also mentioned architecture, service, persistence, design-system, or feature requirements
- treating those future-phase requirements as same-turn implementation instructions instead of handoff inputs
- activating architecture, design-system, accessibility, or feature stations during initial scaffold instead of leaving them in the handoff
- treating explicit scaffold-level baseline settings as forbidden when they should be honored during bootstrap
- treating a request for a linked local package as permission to implement tokens, atoms, molecules, organisms, app wiring, or package tests during bootstrap
- creating or editing files under `Packages/*/Tests` during bootstrap rather than leaving package test sources scaffold-owned
- patching scaffold output after generation to add concrete product behavior or app-specific architecture before Phase 2
- allowing feature work to begin on freshly scaffolded `main` rather than requiring the first topic branch from the intended integration branch
- final answers ending as script logs instead of a bootstrap summary
