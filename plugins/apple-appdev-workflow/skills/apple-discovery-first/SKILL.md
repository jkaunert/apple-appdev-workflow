---
name: apple-discovery-first
description: Discovery-first workflow for Swift and SwiftUI codebases. Use before routing or implementation to discover existing patterns, project reality, release evidence, protocols, factories, and test helpers across iOS/macOS projects.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Discovery First

## Required context
- Load `../../references/apple-architecture-baselines.md`.
- Load `../../references/swift-testing-baseline.md`.
- Load `../../references/memory-derived-best-practices.md`.
- Load `../../references/apple-mcp-workflow.md`.

## Workflow
1. Discover the real local context first: effective working root, repo state, project shape, changed surfaces, existing validation artifacts, and relevant docs or notes.
2. Resolve the effective working root before any git, build, test, review, or release action:
   - if the current shell directory is already the relevant repo or package root, keep it
   - if the current shell directory is a parent folder, search downward for likely roots containing `.git`, `.xcodeproj`, `.xcworkspace`, or `Package.swift`
   - if exactly one child candidate clearly matches the user’s target, adopt that as the working root
   - if bootstrap just created a project in a child directory, treat that generated output path as the active working root for follow-on work
   - if the current shell directory is not a repo and the active workflow follows an earlier scaffold in the same chat, prefer the generated child output path over the ambient shell directory
   - if the ambient shell directory or a user-referenced target path is empty but the same Codex project contains a single clear child or sibling Apple repo matching the user’s target, adopt that existing repo instead of classifying the request as greenfield
   - before concluding that git state is unavailable, branch state is unknown, or branch-diff review cannot run, explicitly check whether a single clear child repo or package root exists
   - before asking scaffold-critical questions or proposing a new scaffold on a non-bootstrap request, explicitly check whether a single clear existing Apple repo or package root already exists nearby in the same Codex project
   - if multiple child candidates exist and none is clearly the intended target, stop and ask the user which root to use
3. Search for similar views, view models, services, and tests.
4. Identify existing DI, coordinator/navigation, and decoupling patterns.
5. Inspect shared test utilities and canonical Swift Testing usage.
6. Reuse established factories and helpers before creating new ones.
7. Use `apple-appdev-workflow:fetch-apple-docs` when current Apple framework, HIG, WWDC, forum, or Swift-DocC docs are needed.
8. Prefer `apple-appdev-workflow:fetch-apple-docs` over generic web search when the need is official, current Apple documentation rather than broader ecosystem context.
9. Use the active memory provider when prior architecture or implementation
   gotchas should be preserved across turns. In `public-portal`, prefer Codex
   native memories when the user enabled them; keep required facts in
   checked-in Markdown and do not require Memory MCP.
10. Document findings, the selected working root, and the selected minimal integration path.

## Guardrails
- Discovery is a first-phase reality check for orchestration when meaningful local context exists, not just a pre-implementation station.
- When discovery participates in an orchestrator-led workflow whose parent skill defines a required first trace block, do not emit discovery narration before that block. Let the parent route block be the first substantive progress update, then continue with discovery findings.
- Do not introduce new abstractions until existing options are evaluated.
- Mirror successful patterns from adjacent modules.
- Do not let shell `cwd` outrank a clearly discovered repo or package root.
- Do not run git, build, test, review, or release commands against a parent directory once the effective working root is known.
- Do not report `not a git repository`, missing branch state, or unavailable branch-diff review from a parent directory until child-root recovery has been attempted.
- Do not treat an empty ambient directory as sufficient evidence for greenfield work when a single clear nested Apple repo already exists nearby.
- Do not ask for bundle identifier, output path, deployment target, or other scaffold-critical inputs on a follow-on feature, review, release, or debug request until existing-root recovery has failed.
