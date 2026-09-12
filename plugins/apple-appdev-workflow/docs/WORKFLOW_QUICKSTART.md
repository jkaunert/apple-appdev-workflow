# Workflow Quickstart

Use this guide when you want a reliable prompt shape for the Apple bundle's
core workflows. The Marketplace profile rendered from current source ships a
`UserPromptSubmit` hook that deterministically selects the top-level Apple owner
for natural Apple prompts and the textual forms behind plugin chips before
model sampling. Stock Desktop passed 12/12 and live Xcode CodingAssistant
passed 9/9 without `routerSelection`; the bounded source candidate removes the
obsolete projection. Public release remains a separate exact-artifact claim.
Explicit `$apple-appdev-workflow:<skill>` invocation remains the clearest
operator control and the required fallback when hooks are disabled or untrusted.

The `0.2.2-beta.1` train additionally qualifies authored macOS and Swift Package
prompts (`prompt-signal:macos` and `prompt-signal:swift package`) while keeping
the neutral Xcode workspace fallback. The Marketplace profile owns the locked
XcodeBuildMCP runtime; the separate Xcode companion remains hook-only.

For broad app work, start with `$apple-appdev-workflow:apple-app-orchestrator`; it should route to the right specialists. For focused tasks, use the named skill shown in the examples below.

## Hook Trust

Normal plugin installation places the routing hook with the bundle; there is
no separate harness installer. Codex still requires hook review/trust, and a
changed hook definition may require renewed trust. If plugin hooks are declined,
disabled, or restricted by enterprise policy, use an explicit fully qualified
skill invocation and do not claim deterministic natural-prompt routing. See
the official [Codex hooks documentation](https://learn.chatgpt.com/docs/hooks).

Materialized production installs are displayed as **Apple Developer Tools**.
Their stable machine identity is `apple-developer-tools`, so copied textual
plugin chips use `plugin://apple-appdev-workflow@apple-developer-tools`. This
source checkout advertises **Apple Developer Tools (Repo Dev)** under
`apple-developer-tools-repo-dev` so repo discovery cannot shadow the production
install. The older `LocalAppleWorkflow` namespace remains an independent
compatibility marketplace for experimental Electron hosts.

## Capability Maturity Expectations

This quickstart uses the same maturity posture as the bundle capability docs:

- `Implemented and validated` workflows are safe to use as current bundle
  behavior when their normal prerequisites are present.
- `Implemented, guidance-first` workflows produce structured guidance,
  evidence requirements, handoffs, and recommendations, but still require human
  execution or judgment for release-sensitive decisions.
- `Conditional` workflows depend on host, MCP, Xcode, OS, account, or project
  prerequisites. If a conditional surface is missing, treat it as environment
  or configuration drift before treating the workflow as unsupported.
- `Planned or demand-gated` capabilities should not be inferred from examples.
  They need fresh evidence or an approved bounded task before becoming
  release-facing behavior.
- `Deferred` capabilities are recognized as useful but are not next in the
  current capability queue.
- `Excluded by design` capabilities are intentionally outside the default
  bundle model.

If a workflow is not listed here or in the bundle capabilities document, ask for
a bounded plan before depending on it.

## Lazy Discovery Rule

This bundle uses mandatory discovery, not mandatory loading.

Start broad Apple work with the top-level owner, then let the selected station
load only the specialists, references, and tool runbooks needed for the
discovered task shape. Do not treat a large reference list as a requirement to
load every document before acting, and do not infer that a tool is unavailable
until the relevant station has run its documented discovery or fallback check.

This rule is especially important in reduced profiles such as Xcode headless:
the profile may expose a smaller runtime surface, but agents should still
discover the available Xcode, documentation, and specialist surfaces before
declaring a workflow unsupported.

## New App Creation

Use when you want a new starter app.

Example prompts:
- `Use $apple-appdev-workflow:apple-app-orchestrator to create a new iOS SwiftUI app named FieldBinder with bundle ID com.example.FieldBinder in ~/Developer/FieldBinder.`
- `Use $apple-appdev-workflow:apple-app-orchestrator to create a new macOS SwiftUI app named ArborNote with bundle ID com.example.ArborNote in ~/Developer/ArborNote and add AppCore + AppServices packages.`

Expected behavior:
- `apple-app-orchestrator` routes into `apple-bootstrap-orchestrator`.
- `apple-bootstrap-orchestrator` starts with discovery-first and then activates `apple-app-bootstrap`.
- This is an `implemented and validated` path for greenfield SwiftUI iOS and
  macOS starters. UIKit, AppKit, and broader generator backends are not current
  release-facing defaults.
- Required scaffold inputs are confirmed before generation.
- Post-scaffold validation stays on `XcodeBuildMCP`.
- The bootstrap pass ends after scaffold plus handoff. If the prompt also mentions architecture or future features, those are carried forward as handoff inputs rather than implemented in the same pass.
- Downstream stations such as architecture, design-system, accessibility, or feature implementation should appear only as the named next-phase handoff, not as same-turn active work during initial scaffold.
- After scaffold generation completes, the same pass may still do non-behavioral baseline alignment needed to honor explicit scaffold-level constraints such as deployment target, Swift version, strict concurrency, strict memory safety, package compatibility, or handoff documentation.
- If the prompt explicitly requests a local package, the same pass may create and link that package plus align its manifest and minimal placeholder targets, but it must not implement package internals or wire app feature files to package UI.
- After scaffold generation completes, the same pass must not implement product behavior, create app-specific services or components, implement package internals, or add behavior-focused tests. If that work starts, the session has already moved into Phase 2.
- If the scaffold created a new repo, feature work must wait for the explicit branch-policy handoff. The default scaffold initializes `main` only; the legacy `main` -> `dev` -> `codex/dev` -> `codex/<topic>` path applies only when explicitly selected.

Important inputs:
- app name
- bundle identifier
- platform
- output directory
- optional package layout

## Existing Project Or Package Adoption

Use when you want the bundle to assess and adopt an existing Xcode project or Swift package.

Example prompts:
- `Use $apple-appdev-workflow:apple-app-orchestrator to adopt this existing Xcode project into the Apple workflow and tell me what is supported, what is risky, and what should change first.`
- `Use $apple-appdev-workflow:apple-app-orchestrator to adopt this existing Swift package into the Apple workflow and tell me what is supported, what is risky, and what should change first.`
- `Use $apple-appdev-workflow:apple-app-orchestrator to assess this legacy UIKit iOS app for adoption into the Apple bundle and give me the next-step handoff plan.`

Expected behavior:
- `apple-app-orchestrator` routes into `apple-bootstrap-orchestrator`.
- `apple-bootstrap-orchestrator` activates `apple-app-bootstrap` in adopt mode after discovery.
- Xcode project and Swift package adoption are `implemented and validated`
  assessment paths, not a guarantee that every discovered project shape can be
  automatically fixed in the same turn.
- The result should report project or package shape, framework signals, support level, risks, and next steps.
- Package-native adoption should treat MCP `swift_package_*` tooling as a normal validation path, not a fallback or unsupported lane.
- A host app or workspace should only be recommended when the requested next phase needs app-specific runtime, UI automation, or release behavior.

Important inputs:
- project or package path
- target platform if the repo is mixed
- whether you want assessment only or follow-on changes

## Feature Implementation

Use for broad product or engineering work, not just isolated edits.

Example prompts:
- `Use $apple-appdev-workflow:apple-app-orchestrator to add a settings flow for export preferences and implement it end to end.`
- `Use $apple-appdev-workflow:apple-app-orchestrator to add offline save-and-retry behavior for job submission and update the affected tests.`

Expected behavior:
- `apple-app-orchestrator` defines scope and acceptance criteria.
- It should activate discovery, architecture, implementation, accessibility, testing, and review as needed.
- Work should stay on a topic branch from the repo's intended integration branch. The legacy `main` -> `dev` -> `codex/dev` -> `codex/<topic>` ancestry applies only to repos that explicitly use that branch model.
- If the app was scaffolded into a nested child directory, follow-on feature work should re-anchor to that generated repo or package root rather than the parent shell directory.
- If the previous turn was bootstrap, feature work should start only after bootstrap has fully concluded and the repo is on a topic branch.
- Final responses for broad feature work should visibly include the activated skills, the tests added or updated, the validation executed, and an explicit branch-diff review status.
- `Branch-diff review status` should be `completed`, `pending before commit`, or `unavailable`, not a vague self-review summary.

## UIKit Modernization

Use when an existing UIKit or mixed UIKit app needs scene, screen, orientation,
or safe-area API modernization.

Example prompts:
- `Use $apple-appdev-workflow:apple-uikit-modernization to audit this UIKit app for UIScreen.main, orientation, scene lifecycle, and safe-area modernization risks.`
- `Use $apple-appdev-workflow:apple-app-orchestrator to modernize this legacy UIKit app for multi-window readiness and route code changes through the right Apple stations.`

Expected behavior:
- Direct prompts invoke `apple-uikit-modernization`; broad app modernization
  should still start at `apple-app-orchestrator`.
- The station is `implemented, guidance-first` for existing UIKit and mixed
  UIKit apps. It is not a greenfield UIKit starter and does not claim automatic
  whole-app migration.
- The station selects a target such as `UIScreen`/`mainScreen`,
  orientation-for-layout, scene lifecycle, or safe-area/layout-margin
  modernization before editing.
- Every file containing the selected target pattern should end with a scoped
  diff, explicit skip reason, or explicit user decision. Silent empty diffs are
  failures.
- Project, lifecycle, Info.plist, `.pbxproj`, and behavior-changing edits stay
  mutation-gated and must report the narrowest available validation evidence.

## Code Review And Tests Before Commit

Use when you want the bundle to enforce branch-diff review and meaningful green tests.

Example prompts:
- `Use $apple-appdev-workflow:apple-review-orchestrator to review the current branch diff for bugs, risks, regressions, and missing tests before commit.`
- `Use $apple-appdev-workflow:apple-review-orchestrator to check whether this branch has adequate coverage and tell me what still needs to be tested before merge.`

Expected behavior:
- Direct review prompts should invoke `apple-review-orchestrator`; broad prompts that start at `apple-app-orchestrator` should route into it.
- `apple-review-orchestrator` starts with discovery-first and coordinates `apple-testing-quality-gates` plus `apple-review-hardening`.
- Final activated-skill evidence should still preserve `apple-app-orchestrator` plus `apple-review-orchestrator` for broad review work.
- If the current branch has an upstream, review should default to that tracking-branch diff.
- `main...HEAD` should be reserved for integration or release-scope review, not normal precommit review.
- Review should focus on the current branch diff, not the whole codebase.
- The result should call out missing or weak tests explicitly.
- Code work is not complete until relevant tests are meaningful and green.

## Swift Testing Modernization

Use when an existing unit or integration test suite should move to, or be
cleaned up within, Swift Testing.

Example prompts:
- `Use $apple-appdev-workflow:apple-swift-testing-foundations to modernize this XCTest unit test file into Swift Testing while preserving behavior.`
- `Use $apple-appdev-workflow:apple-swift-testing-foundations to review this Swift Testing migration for lost XCTest behavior, concurrency issues, and weak assertions.`

Expected behavior:
- Direct prompts invoke `apple-swift-testing-foundations`; broad feature,
  review, or release work should still route through the relevant orchestrator.
- The station is `implemented and validated` as guidance for unit and
  integration tests, not for UI automation, performance tests, Objective-C-only
  tests, or tooling-bound legacy surfaces.
- Migration guidance must preserve imports, fixture lifetime, halting
  assertions, async expectation behavior, skips, known issues, attachments,
  and serialization/main-actor assumptions when those are relevant.
- Validation remains with `apple-testing-quality-gates` after the migration
  shape is chosen.

## Architecture, Product Surface, And Accessibility Work

Use when the next step is structural direction, UI/product-surface coherence, or
accessibility ownership rather than immediate code edits.

Example prompts:
- `Use $apple-appdev-workflow:apple-architecture-orchestrator to assess this app structure and tell me what boundary should change first.`
- `Use $apple-appdev-workflow:apple-product-surface-orchestrator to review this SwiftUI surface for navigation, copy, empty-state, and design-system coherence.`
- `Use $apple-appdev-workflow:apple-accessibility-orchestrator to audit this app for accessibility release-readiness and route the framework-specific findings.`

Expected behavior:
- Architecture, product-surface, and accessibility broad asks route through
  their brigade owners before activating family or specialist stations.
- These are implemented routing surfaces, but the work may be `implemented and
  validated`, `implemented, guidance-first`, or `conditional` depending on
  whether the session has concrete source, simulator, device, or manual
  evidence.
- Direct specialist stations remain available for narrow requests, but they
  should not be treated as broad owner proof.

## Release Readiness And Manual Validation

Use when you need a ship decision or manual QA plan.

Example prompts:
- `Use $apple-appdev-workflow:apple-release-orchestrator to run a release-readiness review for this branch and tell me if we are actually ready to ship.`
- `Use $apple-appdev-workflow:apple-manual-validation to create a manual validation plan for this iPhone feature, including device-only checks and blockers.`

Expected behavior:
- Direct release-readiness prompts should invoke `apple-release-orchestrator`; broad prompts that start at `apple-app-orchestrator` should route into it.
- `apple-release-orchestrator` activates `apple-manual-validation` and the relevant release stations.
- Release, manual-validation, build-release-ops, ASO, and release-notes flows
  are `implemented, guidance-first` unless the session has concrete external
  evidence such as device results, CI artifacts, signed archives, or App Store
  Connect output.
- Direct manual-validation prompts should stay focused on the manual validation plan unless the user asks for a full release go/no-go.
- Simulator-only evidence should not be presented as full ship confidence when device checks matter.

## Xcode Security Hardening Audit

Use when you need an audit of Xcode build settings, diagnostics, static analyzer
posture, entitlements, or SDK-gated security settings before applying changes.

Example prompts:
- `Use $apple-appdev-workflow:apple-xcode-security-hardening to audit this Xcode project for security build-setting and entitlement hardening gaps, report proposed changes, and ask before mutating project files.`
- `Use $apple-appdev-workflow:apple-xcode-security-hardening to review this app target's hardened runtime, sandbox, compiler-warning, and static-analyzer security posture before release.`
- `Use $apple-appdev-workflow:apple-xcode-security-hardening to audit this target for C bounds safety adoption, including -fbounds-safety settings, ptrcheck.h usage, public header annotations, and validation gaps.`

Expected behavior:
- The station is `implemented, guidance-first`.
- It discovers project, target, configuration, and effective setting sources
  before making recommendations.
- It reports proposed setting or entitlement deltas with scope, impact,
  rationale, and validation requirements.
- It asks for explicit confirmation before changing `.xcodeproj`, `.pbxproj`,
  `.xcconfig`, `.entitlements`, package, or source files.
- C Bounds Safety requests stay inside this station. The workflow is
  `implemented, guidance-first` for C headers and C translation units, with
  Objective-C/C++ treated as boundary risk unless local compiler evidence says
  otherwise.
- For C bounds safety adoption, it reports full versus header-only adoption
  choices, proposed annotation/build-setting deltas, ABI risk, validation
  commands, and skipped gates before implementation.
- It validates approved changes with the narrowest available build-setting,
  plist, build, analyze, test, or release-preflight evidence and reports skipped
  gates explicitly.

## Observability Review

Use when critical journeys need production diagnostics.

Example prompts:
- `Use $apple-appdev-workflow:apple-observability-diagnostics to review this flow for observability gaps before release.`
- `Use $apple-appdev-workflow:apple-observability-diagnostics to identify the logs, analytics events, crash breadcrumbs, and rollout signals we need for this feature.`

Expected behavior:
- The bundle should route into `apple-observability-diagnostics`.
- Output should cover structured logs, analytics quality, crash context, and rollout monitoring.

## App Store Metadata And Release Notes

Use when storefront content changes.

Example prompts:
- `Use $apple-appdev-workflow:apple-app-store-aso to draft App Store metadata for this app and suggest screenshot messaging.`
- `Use $apple-appdev-workflow:apple-app-store-release-notes to generate App Store release notes from the user-visible changes on this branch.`

Expected behavior:
- Metadata, ASO, and screenshot work route into `apple-app-store-aso`.
- `What's New` text routes into `apple-app-store-release-notes`.
- Storefront claims should stay aligned with shipped behavior.

## Persistence Workflows

Use when persistence design or review is in scope.

Example prompts:
- `Use $apple-appdev-workflow:apple-persistence-orchestrator to design the SwiftData model and migration approach for saved reference captures.`
- `Use $apple-appdev-workflow:apple-core-data-expert to review this Core Data stack for threading, migration, and CloudKit risk.`

Expected behavior:
- SwiftData work routes into `apple-swiftdata-foundations` or `apple-swiftdata-review`.
- Core Data work routes into `apple-core-data-expert`.

## Runtime Debugging

Use when you need the app reproduced, inspected, or validated at runtime.

Example prompts:
- `Use $apple-appdev-workflow:apple-debug-orchestrator to reproduce this iOS simulator bug and tell me what is actually on screen.`
- `Use $apple-appdev-workflow:apple-debug-orchestrator to debug this macOS launch issue and capture the relevant logs and screenshots.`

Expected behavior:
- Broad debugging work routes through `apple-debug-orchestrator`.
- `apple-debug-orchestrator` chooses the correct runtime station after discovery-first scoping.
- iOS runtime work uses `apple-runtime-debugger-ios`.
- macOS runtime work uses `apple-runtime-debugger-macos`.
- `XcodeBuildMCP` is the default control plane when its workflows are exposed;
  this is a `conditional` execution surface because it depends on the MCP
  server, host toolchain, project shape, and OS/Xcode feature gates.
- In a `public-portal` install, use Xcode native tools inside Xcode and the
  pinned `xcodebuildmcp@2.3.2` CLI on shell-capable Desktop, CLI, or connected
  IDE hosts. The missing MCP server is expected in that profile.
- The final answer should include explicit reproduction status, likely root cause, and next diagnostic step.

## Git Workflow Triage

Use when repo, branch, worktree, dirty-state, or source-pair reality is blocking
safe progress.

Example prompts:
- `Use $apple-appdev-workflow:git-workflow-specialist to inspect this repo/worktree state, classify dirty changes, and recommend the next safe git workflow steps without mutating refs.`
- `Use $apple-appdev-workflow:git-workflow-specialist to tell me whether this branch/worktree is safe to use for validation evidence before I run smokes.`

Expected behavior:
- The specialist remains read-only unless the user explicitly approves a
  concrete mutation.
- It returns repo/worktree facts and recommended sequencing; it does not replace
  review, release, bootstrap, debug, or implementation ownership.
- Destructive operations such as reset, clean, force-push, branch deletion,
  worktree removal, or stash-drop still require explicit approval.

## Decision Stress-Test

Use when a major decision needs critique, comparison, or challenge.

Example prompts:
- `Use $apple-appdev-workflow:apple-decision-stress-test to stress test this migration plan before we commit to it.`
- `Use $apple-appdev-workflow:apple-decision-stress-test to compare direct ModelContext usage versus a repository layer and tell me what we are missing.`

Expected behavior:
- This should activate `apple-decision-stress-test` only as a separate isolated decision-review pass, not as a downstream ingredient inside a broader lane.
- The output should end in a recommendation, not just open-ended critique.

## Prompting Tips

- For marketplace and public-portal installs, start with the explicit
  `$apple-appdev-workflow:<skill>` invocation and then state the user outcome.
- Include platform, framework, and release context when they matter.
- For scaffolding, always provide or confirm the bundle identifier explicitly.
- For reviews, say whether you want branch-diff review, release readiness, or architecture critique.
- For debugging, say whether the target is iOS simulator or macOS runtime.
