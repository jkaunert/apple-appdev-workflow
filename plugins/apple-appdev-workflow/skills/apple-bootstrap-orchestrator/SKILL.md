---
name: apple-bootstrap-orchestrator
description: Bootstrap-domain expediter for broad iOS/macOS app creation, starter scaffolding, and project or package adoption workflows. Preferred visible router for broad bootstrap-domain requests; coordinates discovery-first intake, bootstrap preflight, scaffold or adopt execution, and structured handoff.
metadata:
  role: brigade-orchestrator
  entrypoint: delegated
  routing_scope: domain
---

# Apple Bootstrap Orchestrator

## Required context
- Load `../../references/bootstrap-orchestration-flow.md` for sequence, mode boundaries, and failure patterns.
- Load `../../references/bootstrap-evidence-aggregation.md` for final-summary section content.
- Load `../../references/bootstrap-brigade-trace-template.md` for first-route and final-summary templates.
- Load `../../references/brigade-output-contract.md` for shared brigade rules.
- Load `../../references/apple-skill-orchestration.md` and `../../references/apple-branching-strategy.md`.

## Entry rule
- Use this skill after `apple-appdev-workflow:apple-app-orchestrator` scopes a broad bootstrap workflow, or when the runtime selects this domain brigade first for broad bootstrap-domain work.
- Keep broad user-facing bootstrap routed through this skill; never collapse directly into `apple-appdev-workflow:apple-app-bootstrap`.
- When activated by `apple-appdev-workflow:apple-app-orchestrator`, own bootstrap-domain sequencing and return the brigade content upward for parent final aggregation.
- The first visible route block for broad bootstrap work must use the first-progress shape from `../../references/bootstrap-brigade-trace-template.md`. It must name `apple-appdev-workflow:apple-bootstrap-orchestrator` and `apple-appdev-workflow:apple-app-bootstrap`, must not name `apple-appdev-workflow:apple-app-orchestrator`, and must keep a bootstrap discovery, input-confirmation, or preflight sentence rather than replacing it with `Scope:`, `Mode:`, or custom kickoff prose. This applies even when the user asks for a read-only routing smoke, no-op route audit, or plan-only bootstrap pass.

## Scope
Use this skill for:
- new iOS or macOS SwiftUI app scaffolds
- existing Xcode project adoption
- existing Swift package adoption
- bootstrap feasibility assessment
- bootstrap plus branch, validation, or downstream handoff

For greenfield scaffolds, this skill owns scaffold, sanity validation, generated handoff docs, and git or branch handoff. It does not own same-turn architecture, accessibility, design-system, persistence, package-internals, or feature implementation unless the user explicitly asks to continue after bootstrap concludes.

## Workflow
1. Run discovery first: target path, enclosing repo, support fit, and input completeness for `new`; project/package shape, platform signals, tests, and migration risks for `adopt`.
2. Choose `new` or `adopt` from discovered reality and confirm scaffold-critical or adopt-critical inputs before mutation.
3. For `new`, require explicit output path, bundle identifier, and deployment-target provenance. If the user approves the bundle default deployment target, downstream execution must pass `--allow-default-deployment-target`.
4. If current Apple documentation is needed, activate `apple-appdev-workflow:fetch-apple-docs` before the first Apple-doc lookup. Fallback search is allowed only after that route is visible and the immediately preceding trace step states why fallback is needed.
5. Activate `apple-appdev-workflow:apple-app-bootstrap` as the primary bootstrap station.
6. Use the bundle bootstrap assets from the skill directory. If the bootstrap script cannot run because the session is read-only, temp-file-blocked, or otherwise constrained, report bootstrap as blocked instead of switching to XcodeBuildMCP scaffold generators or nearby fixture apps.
7. For `new`, stop after scaffold, preflight or sanity validation, allowed baseline alignment, generated handoff docs, and explicit repository-policy or branch handoff. Treat architecture, service, persistence, networking, design-system, accessibility, and product requirements in the prompt as future-phase handoff inputs unless the user explicitly asks for post-bootstrap continuation.
8. Allowed same-pass baseline alignment is non-behavioral: explicit deployment target, Swift version, strict concurrency or memory-safety settings, package platform compatibility, repository-policy metadata, generated handoff docs, and scaffold-owned local package linkage plus minimal placeholder target structure.
9. Disallow same-pass concrete product behavior, app-specific services, repositories, coordinators, screens, UI wiring, package internals, files under `Packages/*/Tests`, and behavior-focused tests during broad greenfield bootstrap.
10. After scaffold or adoption, re-anchor follow-on work to the generated or discovered project/package root and hand off to XcodeBuildMCP for Xcode projects or MCP `swift_package_*` workflows for package-native work.
11. Aggregate discovery, preflight, actions, files, branch state, validation handoff, and recommendation into one bootstrap brigade summary.

## Output contract
- Apply `../../references/brigade-output-contract.md`, `../../references/bootstrap-evidence-aggregation.md`, and `../../references/bootstrap-brigade-trace-template.md`.
- The final user-facing bootstrap summary must include these sections in this order: `Activated skills`, `Bootstrap scope`, `Discovery findings`, `Mode`, `Inputs confirmed`, `Preflight status`, `Actions taken`, `Files created or assessed`, `Git and branch handoff`, `Validation handoff`, `Recommendation`.
- Use those exact section labels.
- For broad greenfield bootstrap, final `Activated skills` must preserve top-level and bootstrap ownership: `apple-appdev-workflow:apple-app-orchestrator`, `apple-appdev-workflow:apple-bootstrap-orchestrator`, and `apple-appdev-workflow:apple-app-bootstrap`.
- If Apple docs were consulted, `Activated skills` must also name `apple-appdev-workflow:fetch-apple-docs`, and the trace must already have made that skill visible before the first Apple-doc lookup.
- For broad greenfield bootstrap, do not list downstream implementation stations in final `Activated skills` unless the user explicitly asked for same-turn continuation after bootstrap concluded.
- `Mode` must explicitly say `new` or `adopt`.
- `Actions taken` must stay bootstrap-scoped and must not describe product behavior or post-bootstrap implementation.
- `Files created or assessed` must include clickable links to generated `README.md` and `docs/HARNESS_HANDOFF.md` using real absolute scaffold output paths when a greenfield scaffold creates them.
- `Git and branch handoff` must state whether a repo was initialized or reused, name the applied repository policy, name the forge provider when known, and state the next topic-branch step before feature implementation.
- `Validation handoff` must name the downstream skills or MCP-backed workflows that own the next phase.

## Guardrails
- Do not let `apple-appdev-workflow:apple-app-bootstrap` become the first visible routing layer for broad user-facing bootstrap work.
- Do not let broad bootstrap outputs omit `apple-appdev-workflow:apple-app-orchestrator`, `apple-appdev-workflow:apple-bootstrap-orchestrator`, or `apple-appdev-workflow:apple-app-bootstrap` from final `Activated skills`.
- Do not replace the bootstrap first-route block with a parent-only, hybrid, `Scope:`, `Mode:`, or freeform scaffold kickoff block.
- Do not prepend process narration such as "I will treat this as read-only", "I am going to load...", or "Using the workflow..." before the first route block.
- Do not invent a bundle identifier, output directory, deployment target, package layout, forge provider, or repository policy.
- Do not regenerate existing projects in `adopt` mode or reject pure Swift packages solely because they lack an Xcode project.
- Do not use generic Apple-doc search before `apple-appdev-workflow:fetch-apple-docs` is visibly active.
- Do not switch scaffold backends after bundle bootstrap assets fail under sandbox or session constraints unless the user explicitly asks for that generator.
- Do not start feature work from a freshly scaffolded `main`; report the required topic-branch handoff instead.
