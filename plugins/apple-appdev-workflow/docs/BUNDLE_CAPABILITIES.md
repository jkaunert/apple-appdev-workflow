# Bundle Capabilities

This document describes the current implemented scope of the `apple-appdev-workflow` bundle.

It is intentionally conservative. It separates what is implemented now from what is narrow by design, what still requires human evidence, what is planned next, and what is excluded by design.

## Capability Maturity Labels

Use these labels when evaluating whether a bundle capability is release-facing,
fork-extended, conditional, or still only a future workstream.

- `Implemented and validated`: available in the bundle and covered by current
  source, layout, or runtime evidence.
- `Implemented, guidance-first`: available as structured workflow guidance,
  review, handoff, or decision support, but still dependent on human judgment
  or external service execution.
- `Conditional`: available only when host, MCP, OS, Xcode, project, account, or
  toolchain prerequisites are present.
- `Planned or demand-gated`: intentionally not a current release claim; promote
  only with fresh evidence or an approved bounded task.
- `Deferred`: recognized as valuable but not next in the capability queue.
- `Excluded by design`: not intended to become part of the default bundle model.

## Capability Maturity Map

| Capability area | Current maturity | Release-facing claim |
| --- | --- | --- |
| Core orchestrator routing | Implemented and validated | Broad Apple work starts at `apple-app-orchestrator` and routes into domain owners. |
| Hook-native stock-Codex owner routing | Implemented and validated | A Marketplace-installed `UserPromptSubmit` hook deterministically injects the top-level owner without `routerSelection`; stock Desktop passed 12/12 and live Xcode CodingAssistant passed 9/9. Public release remains a separate release gate. |
| Bootstrap for SwiftUI iOS/macOS apps | Implemented and validated | Greenfield SwiftUI app scaffolding, baseline alignment, validation, and handoff are supported. |
| Existing Xcode project and Swift package adoption | Implemented and validated | Non-destructive assessment, support/risk reporting, and handoff are supported. |
| Optional local SPM package layout during bootstrap | Implemented and validated | Minimal package structure and ownership handoff are supported when explicitly requested. |
| Branch review, testing, debugging, and release-readiness orchestration | Implemented and validated | Orchestrator-led workflows provide structured evidence, findings, and validation handoff. |
| SwiftUI specialist guidance | Implemented and validated | Official SwiftUI specialist topics are folded into existing SwiftUI UI-patterns, view-refactor, design-system, and performance stations with on-demand references and validation gates. Exact SDK 27 API claims remain conditional on local SDK or Apple-doc evidence. |
| UIKit modernization station | Implemented, guidance-first | Existing UIKit and mixed UIKit apps can be audited or scoped for `UIScreen`/`mainScreen`, orientation-for-layout, scene lifecycle, and safe-area/layout-margin modernization with completeness and mutation gates. Project, build, and runtime proof still depend on local tools and app context. |
| XcodeBuildMCP-backed execution | Conditional | Expected default execution path when the full MCP surface and host prerequisites are available. |
| Xcode-headless native-tool execution | Conditional | Xcode CodingAssistant uses native `xcode-tools` first, optional `xcode-proxy` for missing bridge capabilities, and no plugin-declared XcodeBuildMCP. |
| Release operations, ASO, release notes, observability, and manual validation | Implemented, guidance-first | The bundle provides structured plans, checks, and recommendations, not hands-off external automation. |
| Xcode security-hardening audit | Implemented, guidance-first | The bundle can audit Xcode build-setting, diagnostic, and entitlement hardening posture, then propose mutation-gated changes that still require explicit user approval and project validation. |
| C bounds safety hardening | Implemented, guidance-first | C `-fbounds-safety` audit, adoption planning, build-setting review, compiler-diagnostic triage, and runtime trap debugging are folded into `apple-xcode-security-hardening`; source/build mutations remain explicit-approval and local-validation gated. |
| UIKit/AppKit greenfield starters and broader generator backends | Planned or demand-gated | Not part of current marketplace release scope. |
| Native app-server harness, Langfuse adapter, and other infrastructure add-ons | Deferred | Separate backlog families, not Apple workflow capability expansion. |
| Vendor-specific CI/CD, App Store Connect automation, and heavyweight helper stacks | Excluded by design | Not default bundle dependencies or default execution paths. |

## Artifact Profiles

The bundle source is validated through four distinct artifact surfaces:

- `marketplace`: official-compatible payload with the default-discovered hook,
  neutral routing policy, public docs only, and no retired carry metadata.
- `fork-extended`: product-shaped payload for the fork host that uses the same
  carry-free plugin manifest and adds only the declarative routing-history doc
  beyond marketplace docs.
- `xcode-headless`: host-adapted product payload with the same hook and routing
  policy, no plugin-managed MCP servers, and no retired carry metadata.
- `fork-local`: full maintenance-control-plane source shape used for local
  harness work, provenance, remaining runtime carry records, and compatibility
  checks; its plugin manifest is also carry-free.

Do not treat `fork-local` size, docs, or scripts as marketplace or
fork-extended product payload.

## Implemented

### Core orchestration
- `apple-app-orchestrator` is the default entrypoint for nearly all Apple app work in this bundle.
- The product profiles ship a default-discovered `UserPromptSubmit` hook plus a
  neutral routing policy and compact top-level owner kernel. Stock CLI evidence
  proves pre-sampling developer-context injection for natural Apple requests,
  literal plugin-chip text, and explicit focused-skill suppression without
  `routerSelection` in the Marketplace manifest.
- `apple-bootstrap-orchestrator` is the bootstrap-domain expediter for broad app-creation and project or package adoption workflows.
- `apple-review-orchestrator` is the review-domain expediter for broad branch-diff and precommit review workflows.
- `apple-debug-orchestrator` is the debug-domain expediter for broad runtime diagnosis workflows.
- `apple-release-orchestrator` is the release-domain expediter for broad release-readiness workflows.
- `apple-discovery-first` is the bundle-wide reality-discovery phase for orchestration, not just pre-implementation lookup.
- The bundle expects Apple work to stay inside the Apple bundle skill set unless the user explicitly asks for an outside skill or an active skill explicitly requires one.

### Architecture, implementation, and review
- Architecture design for boundaries, DI, navigation, and concurrency-sensitive structure.
- Production feature implementation workflow for iOS/macOS code changes.
- Findings-first branch-diff and precommit review orchestration.
- Read-only git workflow specialist support through `git-workflow-specialist`
  for repo, branch, worktree, dirty-state, source-pair, and checkpoint
  sequencing ambiguity.
- Decision stress-testing for high-impact or ambiguous tradeoffs.
- Final hardening and release-readiness review.
- Audit-first Xcode security-hardening guidance for build settings,
  diagnostics, static analyzer posture, entitlements, and SDK-gated security
  features. Applying recommended changes remains mutation-gated and
  validation-dependent.
- C bounds safety guidance folded into the Xcode security-hardening station for
  C headers and C translation units, including `-fbounds-safety`,
  `ENABLE_C_BOUNDS_SAFETY`, `ptrcheck.h`, annotation strategy, and bounds trap
  debugging.

### UI, UX, and accessibility
- Design-system and UX workflow.
- SwiftUI shell/component pattern guidance.
- SwiftUI view refactor workflow.
- Official SwiftUI specialist depth folded into existing SwiftUI stations for
  structure, data flow, Observation, environment/focus values, `ForEach` and
  related data-driven containers, localization, modifiers, animation,
  soft-deprecation posture, and SDK 27 source compatibility.
- UIKit modernization for existing apps through a focused station covering
  scene, screen, orientation-for-layout, safe-area, and directional-margin
  migration with no-silent-skip file coverage rules.
- Interface writing for in-product copy.
- Liquid Glass specialist guidance.
- Accessibility foundations plus framework-specific accessibility auditors for SwiftUI, UIKit, and AppKit.

### Persistence
- SwiftData foundations.
- SwiftData review and tactical remediation.
- Core Data expert workflow for existing stacks and migration/coexistence work.

### Testing, debugging, and performance
- Swift Testing foundations, including XCTest-to-Swift-Testing modernization
  guidance folded from the official Xcode 27 `test-modernizer` export.
- Testing quality gates with mandatory review of the current branch diff for code changes.
- Broad debugging orchestration for runtime diagnosis and likely-cause reporting.
- iOS runtime debugging.
- macOS runtime debugging.
- SwiftUI performance audit.
- Manual validation workflow for device-sensitive or release-doctor style checks.

### Release and storefront workflows
- Build and release operations, including CI gate expectations, release-candidate policy, TestFlight handoff guidance, and staged rollout/rollback preparation.
- App Store ASO workflow for listing metadata and screenshot strategy.
- App Store release-notes workflow for user-facing “What’s New” text.

### Observability and diagnostics
- Structured logging guidance.
- Analytics event quality guidance.
- Crash-context and breadcrumb guidance.
- Rollout-monitoring guidance.

### Apple-platform documentation support
- `fetch-apple-docs` for official Apple documentation, HIG pages, WWDC transcripts, and related Apple references.

### MCP-backed execution model
- `XcodeBuildMCP` is the expected default Xcode-aware execution path once a project exists outside Xcode-headless.
- In Xcode CodingAssistant or the `xcode-headless` profile, native
  `xcode-tools` owns Xcode-aware file, build, test, documentation, issue,
  preview, and project operations, but the Apple workflow graph and route
  contracts remain the same as fork-local. `xcode-proxy` is an optional bridge
  extension for missing native capabilities, and `codex-fork-headless` is the
  deterministic orchestration backend rather than the default owner of native
  Xcode work.
- The bundle now expects the default `XcodeBuildMCP` workflow set, including coverage, debugging, device, logging, macOS, project discovery, project scaffolding, session management, simulator, simulator management, Swift package, UI automation, utilities, and the Xcode IDE bridge workflow when live Xcode refresh is required.
- XcodeBuildMCP diagnostic and workflow-discovery capabilities are known package capabilities, but they are conditional: `doctor` requires `XCODEBUILDMCP_DEBUG=true`, and `workflow-discovery` requires `XCODEBUILDMCP_EXPERIMENTAL_WORKFLOW_DISCOVERY=true`. They are not enabled by default for marketplace installs.
- The `xcode-ide` workflow is host-gated. On hosts below macOS `26` or Xcode `26`, classify native Xcode IDE proxy failures as `xcode-ide-unavailable-host` and fall back to ordinary XcodeBuildMCP project, simulator, Swift package, logging, and UI automation workflows.
- Fork-local source checkouts include an opt-in persistent `mcp-proxy` manager
  for `xcrun mcpbridge` at `http://127.0.0.1:9876/mcp`. This is a host
  workaround for native Xcode bridge instability, not a default marketplace
  install requirement.
- The same proxy can be registered into Xcode's separate CodingAssistant Codex
  home for manual Xcode-surface validation while leaving Xcode's built-in
  `xcode-tools` MCP entry intact.
- Marketplace installs should use the plugin-declared MCP server configuration in `.mcp.json`. Fork-local source checkouts also keep helper scripts for manual MCP setup and drift checks.
- Plugin-managed source, rendered marketplace artifacts, and installed cache
  roots resolve shared skill resources from plugin-root `docs/`, `references/`,
  and `skills/`. They must not include legacy `skills/docs`,
  `skills/references`, or `skills/skills` mirror shims; those are limited to
  the deprecated compatibility installer fallback when that path is tested
  directly.

## Intentionally Narrow Scope

### Bootstrap
`apple-bootstrap-orchestrator` and `apple-app-bootstrap` are implemented, but the greenfield matrix remains intentionally narrow.

Supported now:
- greenfield iOS SwiftUI apps
- greenfield macOS SwiftUI apps
- non-destructive adoption of existing Xcode projects with stronger project-shape reporting
- non-destructive adoption of existing Swift packages with package-native MCP validation and handoff
- optional minimal local SPM package layout with clearer ownership guidance
- generated scaffold documentation and final summaries must link to real
  output files when those files exist; route templates and references must not
  use fake absolute Markdown placeholder links as release-facing examples

Notes:
- Pure Swift packages are first-class adoption targets in this bundle.
- Host apps or workspaces are conditional follow-on structures for app-specific runtime, UI automation, signing, or release workflows, not a prerequisite for package adoption.

Not yet broad starter coverage:
- greenfield UIKit starters
- greenfield AppKit starters
- large starter-matrix generation
- multiple generator backends as first-class defaults

### Release operations
Release operations are implemented as workflow guidance and decision support, not vendor-specific automation.

Supported now:
- CI gate layout guidance
- release-candidate traceability expectations
- TestFlight handoff expectations
- staged rollout and rollback planning

Not implemented as first-class automation:
- vendor-specific CI/CD pipelines
- App Store Connect automation stacks
- dependency-heavy release scripting layers

### Xcode security hardening
Xcode security-hardening support is implemented as audit-first guidance.

Supported now:
- project, target, configuration, build-setting, and entitlement posture review
- C `-fbounds-safety` posture, adoption-mode planning, build-setting review,
  compiler diagnostic triage, and runtime trap debugging for C headers and C
  translation units
- proposed deltas with scope, impact, rationale, and validation requirements
- explicit user confirmation before mutating project files, xcconfig files,
  entitlements, or source files
- post-change validation guidance for effective settings, entitlement plists,
  build, analyze, test, or release-preflight checks

Not implemented as first-class automation:
- unattended project-wide security mutation
- automatic C/C++/Objective-C migration
- release-hardening claims for C bounds safety without local compile, build, or
  trap evidence
- guaranteed coverage of every Xcode beta setting without local SDK, project,
  or official-doc evidence
- automatic remediation of all security warnings or analyzer findings
- release claims that bypass manual review of risky settings, signing,
  entitlements, or third-party binary compatibility

### UIKit modernization
UIKit modernization is implemented as a focused guidance-first station for
existing UIKit and mixed UIKit apps.

Supported now:
- targeted `UIScreen`/`mainScreen` modernization using local trait, window, or
  scene context
- orientation-for-layout modernization using size classes or local bounds
- scene lifecycle migration planning and scoped implementation when ownership
  and project-file risk are clear
- safe-area and directional-margin modernization where the visual intent is
  understood
- explicit coverage accounting for every file that contains the selected target
  pattern

Not implemented as first-class automation:
- automatic whole-app UIKit migration
- greenfield UIKit starters
- project-wide scene lifecycle mutation without user approval
- guaranteed visual correctness without simulator, device, or manual QA

### App Store support
Supported now:
- storefront metadata, screenshot strategy, positioning, and release notes

Not implemented as first-class automation:
- full App Store Connect operational automation
- metadata validation toolchain dependencies
- upload/review API integrations as a bundle requirement

### Runtime automation expectations
The bundle expects a full `XcodeBuildMCP` surface in session, but the bundle itself does not guarantee Codex client behavior. If the session exposes a reduced MCP surface, that is treated as configuration drift to fix, not a different intended operating mode.

## Manual or Human Required

The bundle does not claim to fully automate these areas.

### Ship readiness evidence
- Final ship/no-ship judgment still depends on human review of the evidence.
- A passing simulator run is not equivalent to device validation when hardware, permissions, performance, motion, accessibility, camera, microphone, sensors, notifications, or real-world environment matter.
- Pending manual checks must be recorded explicitly when release confidence depends on them.

### Manual QA and device coverage
- Real device validation remains necessary for device-only behavior.
- Manual accessibility checks remain necessary for some VoiceOver, Dynamic Type, motion, and interaction-path verification.
- Release-doctor style signoff is a structured workflow, not a fully automated pass/fail oracle.

### Operational interpretation
- Observability guidance can define what to log and what to monitor, but a human still interprets the resulting evidence during rollout.
- Rollback decisions remain operational judgments informed by the release workflow, not automatically taken by the bundle.

### Bootstrap input confirmation
- Scaffold-critical fields must still be explicitly confirmed by the user, especially bundle identifier and target output location.
- The bundle is designed to avoid silently inventing deployment-sensitive identifiers.

## Planned Or Ongoing Work

These items are either planned future work or ongoing maintenance practices.
Treat only the maturity map above as the current release-facing claim.

### Conditional Bootstrap Expansion
Maturity: `planned or demand-gated`.

Planned focus:
- evaluate broader UIKit/AppKit scope only if justified by actual usage
- keep UIKit modernization separate from greenfield UIKit starter decisions
- refine adopt reporting further if real projects expose gaps beyond the current Phase 2 workflow
- consider richer package presets only if the current opt-in package guidance proves insufficient

### Capability Maturity Maintenance
Maturity: ongoing source-of-truth maintenance.

Maintenance focus:
- keep this capabilities document updated as scope changes
- continue narrowing gaps between implemented workflow guidance and live operational behavior
- continue using topic-branch integration so new workflow layers remain reviewable and reversible

Selected next maintenance slice:
- capability maturity alignment across this document, the workflow quickstart,
  and the internal skill-role inventory
- no new skill, scaffold generator, runtime carry, or Electron package behavior
- optional checker work only if the alignment pass finds repeated drift that is
  cheap to enforce

## Excluded By Design

These are intentionally not part of the default bundle model.

### External helper stacks as defaults
- external task-management helper skills
- alternate shell-first build helper stacks as the default Apple workflow
- parallel non-Apple orchestration layers for normal Apple app work

### Dependency-heavy operational add-ons
- hard dependency on vendor-specific CI systems
- hard dependency on App Store Connect automation tooling
- heavy metadata-validation tool stacks as a bundle requirement
- broad external tooling requirements when the bundle can stay dependency-light

### Broad generic workflow layers that dilute orchestration
- generic planning/task skills as a default substitute for model-native planning
- free-form skill hopping instead of orchestrator-led Apple workflow selection
- normalizing raw shell workflows when `XcodeBuildMCP` should be the primary control plane

## Current Release Confidence Model

The bundle is strongest today when used as:
- an orchestrated Apple development workflow
- a SwiftUI-first app bootstrap and implementation pipeline
- a test-backed and review-backed branch workflow
- a release-readiness workflow that combines automated evidence, manual validation, hardening review, and release operations guidance

It is not yet a complete hands-off product factory. It still expects:
- explicit user confirmation for scaffold-critical decisions
- focused code review on the branch diff
- meaningful tests for changed code paths
- manual validation where device evidence matters
- human judgment at release time

## Related Documents
- `docs/MCP_SETUP.md`
- `docs/WORKFLOW_QUICKSTART.md`
- `docs/PRIVACY_POLICY.md`
- `docs/TERMS_OF_SERVICE.md`
