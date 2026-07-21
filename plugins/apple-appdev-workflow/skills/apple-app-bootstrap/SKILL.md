---
name: apple-app-bootstrap
description: Focused bootstrap station for scaffold generation and adoption analysis inside Apple bootstrap workflows. Use directly only for narrow bootstrap-only execution or when the bootstrap brigade has already scoped the work.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple App Bootstrap

## Required context
- Load `../../references/app-bootstrap-supported-matrix.md`.
- Load `../../references/app-bootstrap-workflow.md`.
- Load `../../references/app-bootstrap-backend-policy.md`.
- Load `../../references/xcode-headless-host-policy.md` when running inside
  Xcode CodingAssistant or the installed profile is `xcode-headless`.
- Load `../../references/app-bootstrap-tuist-backend.md` when Tuist backend,
  Tuist pilot, or Phase 3 bootstrap work is requested.
- Load `../../references/app-bootstrap-adopt-mode.md`.
- Load `../../references/app-bootstrap-adopt-checklist.md` for existing-project or package onboarding.
- Load `../../references/app-bootstrap-spm-layout.md` when package layout is requested.
- Load `../../references/app-bootstrap-package-layouts.md` when package layout is requested.
- Load `../../references/app-bootstrap-generated-docs.md` for scaffold-output expectations.
- Load `../../references/core-development-context-template.md` for the target app.
- Treat `scripts/` and `templates/` under this skill directory as the authoritative bootstrap assets. Resolve those paths relative to the skill directory, not relative to the user's workspace.

## Scope
Use this skill when the user wants to:
- create a new iOS app
- create a new macOS app
- scaffold a SwiftUI Apple app
- adopt an existing Xcode project or Swift package into the Apple bundle workflow
- start a new Apple app with optional local Swift packages

## Entry rule
- Broad scaffold or project-adoption requests must start with `apple-appdev-workflow:apple-app-orchestrator`, which should then hand off to `apple-appdev-workflow:apple-bootstrap-orchestrator`.
- Use this skill directly only when the user explicitly asks for a focused bootstrap-only pass or when the orchestrator has already scoped the workflow.
- Do not treat this skill as the first visible router for broad greenfield scaffold or adopt requests.

## Phase 1 and Phase 2 support
Greenfield support:
- iOS + SwiftUI
- macOS + SwiftUI

Adopt support:
- existing iOS/macOS Xcode projects
- existing Swift packages
- UIKit/AppKit projects for adopt guidance only
- stronger adopt reporting for project or package shape, test presence, package usage, and follow-up workflow handoff

Out of scope in Phase 1:
- greenfield UIKit starter
- greenfield AppKit starter
- makefile installation
- task CLI installation

## Workflow
1. Determine whether the task is `new` or `adopt`.
2. If the workflow will scaffold a project, collect and confirm required scaffold inputs before any scaffold-dependent analysis or file changes:
   - app name
   - bundle identifier
   - platform
   - UI framework
   - output directory
   - optional deployment target and package layout
3. Never invent a bundle identifier. If it is missing, ask for it explicitly and wait.
4. Confirm platform, UI framework, output directory, and deployment target. If the output directory is omitted, stop and ask for it or ask explicit permission to use the current directory before scaffolding. If the deployment target is omitted, stop and ask for it or ask explicit permission to use the bundle default before scaffolding.
5. If the user asks for a recommendation rather than specifying a deployment target, recommend the resolved bundle default only. Do not invent an alternate "reasonable modern floor."
6. Resolve the bootstrap asset root from this skill directory before execution. Do not infer `scripts/doctor.sh`, `scripts/bootstrap.sh`, or templates from the user's workspace.
7. For `new` mode, run the skill-relative `scripts/doctor.sh --mode new` before scaffolding.
8. For `new` mode, use the skill-relative `scripts/bootstrap.sh --mode new ...` with a dry run first when the destination is uncertain.
9. In `new` mode, do not emit any `scripts/bootstrap.sh` command, including dry run, until deployment-target provenance is explicit in the current turn: either the user named a target or explicitly approved the bundle default.
10. If the user explicitly approved the bundle default deployment target, express that approval at execution time with `--allow-default-deployment-target`. Do not rely on omitting `--deployment-target` and letting the script fall back silently.
11. For `adopt` mode, use the skill-relative `scripts/bootstrap.sh --mode adopt ...` to analyze the existing project or package shape and produce a concrete adoption report with git state, repository policy, forge provider, and the next topic-branch step before implementation.
12. If the skill-relative bootstrap script cannot run because the Codex session is read-only, cannot create shell temp files, or otherwise blocks normal script execution, stop and report bootstrap as blocked by sandbox or session constraints.
13. When that happens, do not substitute `XcodeBuildMCP` scaffold-project generators or any other alternate scaffold backend unless the user explicitly asked for that generator.
14. After scaffold or adopt, hand off to:
   - `apple-appdev-workflow:apple-architecture-design`
   - `apple-appdev-workflow:apple-design-system-ux`
   - `apple-appdev-workflow:apple-feature-implementation`
   - `apple-appdev-workflow:apple-swift-testing-foundations`
   - `apple-appdev-workflow:apple-testing-quality-gates`
14. For greenfield scaffolding, that handoff is advisory only. Record the downstream owners, but do not activate them to perform work in the same bootstrap pass unless the user explicitly asks to continue after bootstrap is complete.
15. For greenfield scaffolding, stop after scaffold, preflight or sanity validation, and handoff. Do not continue into architecture, design-system, accessibility, or feature implementation in the same bootstrap pass unless the user explicitly asks to continue after bootstrap is complete.
16. After the skill-relative `scripts/bootstrap.sh --mode new ...` completes in a broad greenfield bootstrap pass, limit same-pass edits to bootstrap-safe baseline alignment only. Allowed examples: deployment target, Swift version, strict-concurrency or strict-memory-safety settings, package platform compatibility, scaffold-owned local package linkage, minimal placeholder target structure, and generated handoff docs that capture the user's future-phase constraints. Disallowed examples: replacing starter services, rewriting starter UI, wiring app feature screens to consume package UI, creating repositories or coordinators, implementing package tokens or component hierarchies beyond a minimal placeholder, creating or editing package test files under `Packages/*/Tests`, creating product components, or adding behavior-focused tests.
17. Treat prompt phrases such as `prefer`, `consider`, `when considering architecture`, `repository pattern`, `service layer`, `container/presenter`, `navigation coordination service`, or `networking layer` as handoff guidance during bootstrap unless the user explicitly asks to continue after bootstrap is complete.
18. Those prompt phrases do not count as an explicit continuation signal. The continuation signal must explicitly say to continue after bootstrap or to scaffold and then implement in the same turn.
19. When bootstrap-safe baseline alignment depends on current Apple documentation or HIG guidance, use `apple-appdev-workflow:fetch-apple-docs` first rather than generic web search. Make that activation visible before the first Apple-doc lookup appears in the trace. That skill may resolve the page through MCP, direct Sosumi HTTP, or a CLI fetcher, but it must remain visibly routed through `apple-appdev-workflow:fetch-apple-docs`. If HTTP or CLI transport is used, make that attribution clear before the transport step appears. Use generic web search only as an explicit fallback after `apple-appdev-workflow:fetch-apple-docs` has already started and only when the Apple-doc skill is unavailable, the direct Sosumi path is unknown, or a direct fetch returned 404 or sparse output. When that happens, make the fallback reason explicit in the immediately preceding trace step before the first search step.
20. Once an Xcode project exists, switch to `XcodeBuildMCP` as the default control plane for discovery, build, run, and test validation outside Xcode-headless. Inside Xcode CodingAssistant or the `xcode-headless` profile, switch to native `xcode-tools` first under `../../references/xcode-headless-host-policy.md`, using `xcode-proxy` only for missing bridge capabilities. For package-native adoption outside Xcode-headless, prefer the MCP `swift_package_*` workflows and `swift package describe` as the default control plane. Use raw `xcodebuild` only as fallback for real MCP or host-tool gaps after stating the specific gap.
21. For greenfield scaffolding, use the bundle bootstrap scripts as the default execution path. Do not replace them with MCP scaffold-project generators unless the user explicitly asks for that path.
22. If the installed bootstrap scripts are genuinely unavailable or unreadable, stop and report the bootstrap asset problem. Do not clone nearby fixtures, copy prior smoke outputs, hand-author `.xcodeproj` renames, or fabricate a scaffold by duplicating an existing app.
23. During broad greenfield bootstrap, leave topic-branch creation as handoff unless the user explicitly asks to continue beyond bootstrap in the same turn.

## Backend policy
- Greenfield Phase 1 scaffolding may use XcodeGen as an implementation backend.
- Adopt mode must not require XcodeGen.
- Do not introduce external task-management helpers or alternate shell-first build helper stacks into the default bootstrap flow.
- Do not use XcodeBuildMCP scaffold-project tools as the default greenfield generator for this bundle.
- Do not treat a read-only sandbox, shell temp-file denial, or similar execution constraint as permission to switch scaffold backends.
- Do not fall back to `XcodeBuildMCP` scaffold-project generation after the bundle bootstrap script failed under sandbox or session constraints unless the user explicitly asked for that generator.
- Prefer Apple bundle skills plus model-native planning for scaffolding coordination.
- Do not dispatch to external scaffolding helpers unless the user explicitly asks for them or the active skill instructions explicitly require them.
- Treat the generation backend as an implementation detail, not the user-facing workflow.

## Output contract
- Routing: `focused subskill`
- Mode: `new` or `adopt`
- Supported or unsupported combination result
- Inputs captured
- Actions taken or previewed
- Files created or untouched
- Git and branch handoff
- Handoff sequence into the Apple bundle workflow
- Validation next steps

## Safety rules
- Prefer dry run before mutating unfamiliar paths.
- But never run a bootstrap dry run with an inferred or synthesized deployment target before user approval is explicit.
- Never overwrite a non-empty directory silently.
- Never regenerate an existing project during adopt mode.
- Never treat a pure Swift package as unsupported solely because no `.xcodeproj` or `.xcworkspace` exists.
- Never auto-commit a pre-existing dirty repository.
- Never proceed with scaffolding on an inferred bundle identifier.
- Never proceed with a default deployment target unless the user explicitly approved that default in the current turn.
- Never synthesize the bundle default into `--deployment-target` just to unblock a dry run or preview.
- Never encode default-deployment-target approval implicitly by omitting `--deployment-target`; when the user approved the bundle default, the execution path must pass `--allow-default-deployment-target`.
- Never infer the current directory as the scaffold destination unless the user explicitly approved that destination in the current turn.
- Never suggest a deployment target floor other than the resolved bundle default unless the user asked for a different tradeoff analysis.
- Never introduce editor- or agent-specific files such as `.cursor`, `.cursorrules`, `CLAUDE.md`, or similar artifacts unless the user explicitly requested them.
- Never create a workspace, package layout, or nested project folder unless the user requested that layout or the active bundle template explicitly requires it.
- Never treat absence of workspace-local bootstrap scripts as evidence that the bundle bootstrap scripts are unavailable. Resolve scripts relative to this skill first.
- Never copy, clone, `rsync`, or rename a nearby scaffold fixture as a substitute for running the bundle bootstrap scripts.
- Never fabricate a fresh scaffold by bulk-renaming an existing Xcode project when the bootstrap assets are missing; report the missing bootstrap asset as a blocker instead.
- Never treat a read-only sandbox or shell temp-file denial as a harmless bootstrap hiccup; report the blocked state instead of swapping generators.
- Never fall back to `XcodeBuildMCP` scaffold-project generation after the bundle bootstrap script failed under sandbox or session constraints unless the user explicitly asked for that generator.
- Never treat architecture, package, persistence, service-layer, design-system, or feature requirements mentioned during app creation as permission to implement those layers before bootstrap handoff is complete.
- Never activate downstream architecture, design-system, accessibility, or feature stations to perform same-turn work during broad greenfield bootstrap.
- Never interpret architecture preferences or pattern lists as proof that the user wants same-turn feature implementation during bootstrap.
- Never treat embedded architecture preferences, implementation constraints, or pattern lists as the explicit continuation signal needed to move from bootstrap into implementation in the same turn.
- Never interpret a request for a linked local package or design-system package as permission to implement that package beyond scaffold-owned linkage, manifest alignment, and minimal placeholder targets.
- Never create or edit files under `Packages/*/Tests` during broad greenfield bootstrap. Package tests may run for validation, but package test sources must remain scaffold-owned.
- Never use generic web search for Apple API, HIG, WWDC, or Apple build-setting guidance during bootstrap while `apple-appdev-workflow:fetch-apple-docs` is available.
- Never satisfy the Apple-doc lookup requirement during bootstrap with raw web searches against `developer.apple.com` or `sosumi.ai` unless the run clearly presents them as fallback after `apple-appdev-workflow:fetch-apple-docs` proved unavailable or insufficient.
- Never bypass `apple-appdev-workflow:fetch-apple-docs` during bootstrap with ad hoc `curl https://sosumi.ai/...`, `npx @nshipster/sosumi fetch ...`, or similar shell commands. Those are transport choices inside the skill, not acceptable manual substitutes for invoking it, unless the run clearly attributes them to the skill.
- Never count HTTP or CLI Sosumi transport as compliant during bootstrap unless the run clearly attributes that transport to `apple-appdev-workflow:fetch-apple-docs`.
- Never perform top-level generic web search for Apple docs during bootstrap before `apple-appdev-workflow:fetch-apple-docs` is visibly active.
- Never use fallback Apple-doc search during bootstrap unless the narration makes the fallback reason explicit in the immediately preceding trace step before the first search event.
- Never let the first Apple-doc-related trace event be a generic search or unlabeled Sosumi transport. That is a routing failure even if `apple-appdev-workflow:fetch-apple-docs` is named later in the summary.
- Never let a fallback Apple-doc search appear before that explicit fallback reason. A later explanation does not cure the ordering failure.
- Never create concrete product behavior, app-specific services, repositories, coordinators, screens, components, package internals, app-to-package UI wiring, or behavior-focused tests after the skill-relative `scripts/bootstrap.sh --mode new` completes during a broad greenfield bootstrap pass.
- Never block bootstrap-safe alignment work that is required to honor explicit scaffold-level constraints such as deployment target, Swift version, strict concurrency, strict memory safety, package compatibility, or handoff documentation.
- Never start feature implementation on `main`, `dev`, `codex/dev`, or any other integration/default branch immediately after scaffold; require topic-branch setup according to the reported repository policy first.
- Never create or switch to `codex/<topic>` during broad greenfield bootstrap unless the user explicitly asked to continue beyond bootstrap in the same turn.
- Never append `Branch-diff review status` or similar review-only completion markers to a bootstrap summary unless a real review workflow ran.
