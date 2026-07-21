---
name: apple-feature-implementation
description: Production feature implementation workflow for iOS/macOS apps with Swift 6 concurrency compliance, explicit dependencies, robust state handling, and maintainable architecture alignment.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Feature Implementation

## Required context
- Load `../../references/apple-architecture-baselines.md`.
- Load `../../references/ui-decoupling-baseline.md`.
- Load `../../references/swift-testing-baseline.md`.
- Load `../../references/apple-mcp-workflow.md`.

## Workflow
1. Confirm discovery findings, acceptance criteria, and the effective working root.
2. Use the discovered working root for all edits, builds, tests, and branch-diff review checks rather than the ambient shell directory.
3. Confirm the current git branch is a topic branch before mutating an existing repository. If the repo is on `main`, `dev`, or `codex/dev`, stop and restore the required `main` -> `dev` -> `codex/dev` -> `codex/<topic>` ancestry first. If the existing dirty state can be carried safely onto the topic branch, create or switch to that branch before the first mutating event. If safe switching is unclear or blocked, stop and report blocked rather than coding on the protected branch.
4. Confirm that the requested implementation can still satisfy the declared product constraints and specialist-skill assumptions before coding.
5. If delivery appears to require a material requirement pivot, stop and escalate before implementing the substitute. Treat changes such as `SwiftData -> file-backed store`, `UIKit/AppKit-hosted -> pure SwiftUI`, `local-first -> remote-first`, or other declared-platform or persistence substitutions as requirement changes, not routine implementation detail.
6. If the user explicitly approves the pivot, keep the replacement isolated behind the same app-facing contract and carry the approval forward in the final summary. If approval is not obtained, either keep the original requirement or explicitly report the requirement as unmet rather than silently substituting.
7. Implement smallest vertical slice with protocol-based DI.
8. Keep pure views side-effect free; orchestration belongs in viewmodel/presenter/services.
9. Enforce MainActor/UI isolation and Sendable-safe boundaries.
10. Activate `apple-appdev-workflow:apple-swiftui-ui-patterns` when the task is mainly about SwiftUI shell, screen, sheet, list, form, search, focus, or overlay composition.
11. Activate `apple-appdev-workflow:apple-swiftui-view-refactor` when the task is mainly about restructuring an existing SwiftUI view file without changing the feature boundary.
12. Activate `apple-appdev-workflow:apple-interface-writing` when user-facing copy changes materially.
13. Activate `apple-appdev-workflow:apple-liquid-glass` when Liquid Glass is explicitly in scope.
14. Activate `apple-appdev-workflow:apple-swiftdata-foundations` when the task changes SwiftData models, contexts, queries, migrations, history, or sync behavior.
15. Activate `apple-appdev-workflow:apple-swiftdata-review` when the task is mainly about fixing or reviewing existing SwiftData code.
16. Activate `apple-appdev-workflow:apple-core-data-expert` when the task changes Core Data stacks, contexts, fetch requests, migrations, history, or SwiftData/Core Data coexistence.
17. Activate `apple-appdev-workflow:apple-swift-concurrency-foundations` when detailed concurrency guidance is needed for tasks, actors, Sendable, cancellation, or bridging.
18. Activate `apple-appdev-workflow:apple-runtime-debugger-ios` or `apple-appdev-workflow:apple-runtime-debugger-macos` when runtime reproduction or on-screen validation is needed during implementation.
19. Activate `apple-appdev-workflow:apple-swiftui-performance-audit` when SwiftUI runtime performance symptoms are in scope.
20. Activate `apple-appdev-workflow:apple-observability-diagnostics` when the change touches critical journeys, diagnostics, analytics, crash reconstruction, or rollout-sensitive monitoring.
21. Use `XcodeBuildMCP` as the default build and test loop once a project exists; fall back to direct `xcodebuild` only for real MCP gaps or temporary MCP setup defects.
22. Add or update Swift Testing coverage for every new feature, behavior change, core logic path, and error path unless there is a documented reason the coverage must stay manual or UI-level.
23. Activate `apple-appdev-workflow:apple-swift-testing-foundations` by default for new feature work or changed behavior when tests need to be written or updated.

## Guardrails
- Keep side effects isolated.
- Avoid hidden shared state.
- Preserve testability via protocols and injection.
- Do not treat feature work as complete if tests were not written or updated for the changed behavior.
- Do not silently replace a declared product requirement, scenario constraint, or explicitly requested framework/persistence choice just because the first approach failed at runtime.
- Do not present a substituted implementation as if it fully satisfied the original requirement unless the user approved the pivot or the final summary explicitly marks the requirement unmet.
- Do not report branch-diff review as unavailable until the discovered working root has been checked for git state.
- Do not report `git` absence, branch absence, or branch-diff review unavailability from a parent directory if discovery already identified a nested generated repo.
- Do not report `Branch-diff review status: completed` when unrelated dirty or preexisting untracked state made the diff scope ambiguous and the pass had to rely on source-surface inspection instead of a real diff baseline.
- Do not treat an implementation-only test pass as the final feature response; broad feature work must still surface the concluding quality-gates pass.
- Do not let informal wording such as `self-review` stand in for an explicit branch-diff review status.
- Do not start coding in a newly scaffolded repository until bootstrap has concluded and the first topic branch exists.
- Do not let the first mutating event in an existing repo happen on `main`, `dev`, or `codex/dev`. A later switch to `codex/<topic>` does not cure the violation.
- Do not treat a broad feature response as complete if the final summary omits `Activated skills`.
- When feature work is routed through `apple-appdev-workflow:apple-app-orchestrator`
  or combined with local repo skills, keep the final Apple evidence qualified
  and parent-owned. Final task-completion summaries for commits, pushes, PRs,
  merges, or task-ledger updates must still include `Routing` and
  `Activated skills` with `apple-appdev-workflow:apple-app-orchestrator` plus
  any Apple stations that materially shaped the work.
- Do not use bare Apple skill ids such as `apple-feature-implementation` in
  final `Activated skills`; output/evidence surfaces require
  `apple-appdev-workflow:apple-feature-implementation`.
- If the user asked to fix review blockers, release blockers, or move a branch toward ship-candidate status, do not let the feature summary stand in for the final release conclusion. That conclusion belongs to the release brigade summary.
- Do not conclude `ship-candidate ready`, `ready to ship`, `no remaining blockers`, or equivalent closure from implementation evidence alone when earlier unresolved blockers still exist in the same session.
