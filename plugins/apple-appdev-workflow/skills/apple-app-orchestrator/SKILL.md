---
name: apple-app-orchestrator
description: Default entrypoint for broad iOS/macOS workflows that span multiple Apple bundle skills. Translate product requests into scope and acceptance criteria, then activate the relevant Apple subskills automatically through implementation, validation, and release checks.
metadata:
  role: top-level-orchestrator
  entrypoint: primary
  routing_scope: broad
---

# Apple App Orchestrator

## Required context
- Load `../../references/generic-copilot-instructions.md`.
- Load `../../references/apple-branching-strategy.md`.
- Fill `../../references/core-development-context-template.md` for the target Apple app.
- Use `../../references/copilot-to-skills-mapping.md` to preserve Copilot-style coverage.
- Load `../../references/apple-mcp-workflow.md`.
- When the installed artifact is the `public-portal` profile, also load
  `../../references/public-portal-tool-adapter.md` before selecting an
  execution provider.
- When the active host is Xcode CodingAssistant or the installed artifact is the
  `xcode-headless` profile, also load
  `../../references/xcode-headless-tool-adapter.md`.
- Load `../../references/apple-skill-orchestration.md` for detailed lane triggers, precedence, and specialist routing.
- Load `../../references/brigade-output-contract.md` for shared route and final-summary rules.
- Load the lane-specific trace template when selected:
  - `../../references/architecture-assessment-trace-template.md`
  - `../../references/bootstrap-brigade-trace-template.md`
  - `../../references/persistence-brigade-trace-template.md`
  - `../../references/product-surface-design-trace-template.md`
  - `../../references/review-brigade-trace-template.md`
  - `../../references/release-brigade-trace-template.md`
- Load the lane-specific orchestration flow when selected:
  - `../../references/bootstrap-orchestration-flow.md`
  - `../../references/review-orchestration-flow.md`
  - `../../references/release-orchestration-flow.md`
  - `../../references/debug-orchestration-flow.md`
  - `../../references/architecture-orchestration-flow.md`

## Workflow
1. Define user outcome, target platforms, and OS support range.
2. Run a discovery-first reality phase before major routing decisions when meaningful local context exists.
3. For true greenfield requests, perform a lighter discovery phase covering target-path state, repo presence, support-matrix fit, and input completeness.
4. Resolve the effective working root from discovery findings and treat it as the canonical path for subsequent git, build, test, review, and release actions.
5. If the ambient shell directory is a parent folder rather than the actual repo or package root, attempt child-root recovery before reporting missing git, branch, build, review, or release evidence.
6. Activate `apple-appdev-workflow:git-workflow-specialist` when repo topology, branch state, dirty files, source-pair ownership, checkpoint sequencing, or protected-baseline safety becomes a material part of the work. Keep it read-only unless the user explicitly approves a specific mutation.
7. Only collect scaffold-critical inputs after discovery has shown that no single clear existing Apple target can satisfy the request.
8. Convert requirements into measurable acceptance criteria using the discovered reality.
9. Before mutating an existing repository, enforce the branch policy loaded from the required context above.
10. If the task includes scaffolding, collect and confirm required scaffold inputs before any scaffold-dependent work. Never infer a bundle identifier.
11. Select and load the relevant Apple subskills based on task shape, `../../references/apple-skill-orchestration.md`, and discovery findings.
12. When activating a brigade or specialist lane, keep the ownership boundary explicit:
   - brigade orchestrators own domain sequencing and evidence aggregation
   - specialist lanes own focused evidence and recommendations
   - the parent orchestrator still owns final user-facing aggregation for broad orchestrator-led work
13. Sequence discovery, architecture, implementation, branch-diff review, testing, and release dependencies.
14. Require tests to be added or updated for new features and changed code paths unless there is a documented reason no meaningful automated test exists.
15. Hold completion until relevant tests are meaningful and green.
16. Identify platform-specific risks such as entitlements, privacy, performance, signing, and manual-device validation.
17. Set go/no-go checks for release candidate readiness.
18. When the selected brigade lane defines a literal first routing block in its trace template, satisfy parent route ownership by emitting that exact compact three-line brigade block as the first visible bundle-authored block: `Routing: orchestrator-led`, inline `Activated skills: ...` with fully qualified plugin ids, then the lane context sentence. Do not emit a parent-only `Activated skills` line, an `Activated skills` heading plus bullets, a `Mode:` line, or explanatory kickoff prose before it. This also applies to read-only, routing-only, and smoke-test prompts; do not prepend process narration such as "I'll treat this as..." before the route block. If the final summary is the first visible output, place the compact route block before the final summary headings, even if the next heading is also `Activated skills`.

## Output contract
- Routing: `orchestrator-led`
- Scope and non-scope
- Acceptance criteria
- Activated skills and why
- Milestone sequence
- Risks and mitigations
- Validation and release checks
- Evidence reviewed
- Blockers and residual risks when applicable
- Tests added or updated, and green-status summary for code changes
- Branch-diff review status for code changes
- Explicit statement that the pass is orchestrator-led
- For Apple-touched task-completion summaries, especially commit, merge, PR,
  branch, or multi-skill local workflow wrap-ups, preserve the route contract
  instead of switching to free-form status prose. Start with
  `Routing: orchestrator-led` and include `Activated skills` before the status
  details when the turn materially used this bundle.
- For broad Apple work, final `Activated skills` must include
  `apple-appdev-workflow:apple-app-orchestrator` plus the materially active
  domain or specialist stations using fully qualified
  `apple-appdev-workflow:<skill>` ids. Local non-Apple skills may be named as
  collaborators elsewhere, but they do not replace Apple top-level ownership.
- Do not let downstream skills own the final user-facing answer in orchestrator-led workflows. They may supply evidence, findings, and recommendations, but the final response must be aggregated and emitted by this orchestrator.
- In ordinary progress updates for orchestrator-led work, describe the current action without naming human-facing skill display names. Keep explicit skill naming for route blocks, compliance-critical trace steps, and final `Activated skills`.
- When explicitly naming a plugin skill, use `$<plugin-name>:<skill-name>` for prompt/control-plane invocation and `<plugin-name>:<skill-name>` without `$` for output/evidence surfaces such as route blocks, final `Activated skills`, validation contracts, scoring artifacts, and model-visible routing prose. For this bundle, those forms are `$apple-appdev-workflow:<skill>` and `apple-appdev-workflow:<skill>`.

## Core lane routing
- `apple-appdev-workflow:apple-app-orchestrator` is the mandatory top-level entrypoint for broad Apple workflow requests.
- Do not wait for the user to name every subskill.
- Prefer skills from this Apple bundle for Apple app work.
- Use model-native reasoning and planning for decomposition, sequencing, and tradeoff analysis.
- Do not dispatch to skills outside this Apple bundle unless the user explicitly asks for them or the active skill instructions explicitly require them.
- Do not confuse model-native planning with external planning or task-management skills. Internal planning is expected.
- Treat these request shapes as orchestrator-mandatory:
  - end-to-end feature work
  - release readiness or ship/no-ship calls
  - manual QA plus release review
  - broad debugging plus validation
  - broad architecture or app-structure assessment
  - broad current-state recommendation requests such as `what should change first`
  - any request likely to activate more than one Apple bundle skill
- Treat prompts framed as `design`, `propose`, `recommend`, `model`, `migration approach`, or other architecture-first wording as non-mutating design work unless the user explicitly asks to scaffold, implement, or wire code in the same turn.
- Activate `apple-appdev-workflow:fetch-apple-docs` when the task depends on current Apple API, HIG, WWDC, forum, or Swift-DocC guidance. Make it visible before the first Apple-doc lookup appears in the trace; a final `Activated skills` line is too late.
- When this bundle cooperates with local repo skills, Spec Kit skills, git workflow helpers, or other non-Apple capabilities, keep the Apple route evidence intact in the final answer.

## Brigade summaries
- Apply `../../references/brigade-output-contract.md` and the selected lane's trace template for first route block shape, final section labels, and owner evidence.
- For broad non-mutating design work, use an explicit brigade summary rather than free-form prose. Required literal section order: `Routing`, `Activated skills`, `Design scope`, `Discovery findings`, `Recommended design`, `Migration and rollout implications`, `Risks`, `Next implementation entry points`.
- For broad architecture work, require the final output to use this section order: `Routing`, `Activated skills`, `Assessment scope`, `Discovery findings`, `What Should Change First`, `Recommended follow-on structure`, `Risks`, `Next implementation entry points`.
- For broad architecture work, `Activated skills` must explicitly name `apple-appdev-workflow:apple-architecture-orchestrator`; discovery and design stations alone are not sufficient.
- For broad bootstrap workflows, require the final output to use this section order: `Routing`, `Activated skills`, `Bootstrap scope`, `Discovery findings`, `Mode`, `Inputs confirmed`, `Preflight status`, `Actions taken`, `Files created or assessed`, `Git and branch handoff`, `Validation handoff`, `Recommendation`.
- For broad bootstrap workflows, final `Activated skills` must explicitly name `apple-appdev-workflow:apple-app-orchestrator`, `apple-appdev-workflow:apple-bootstrap-orchestrator`, and `apple-appdev-workflow:apple-app-bootstrap`; `apple-appdev-workflow:apple-app-orchestrator` plus `apple-appdev-workflow:apple-app-bootstrap` alone is not sufficient.
- For broad greenfield bootstrap workflows, `Files created or assessed` must include clickable links to generated `README.md` and `docs/HARNESS_HANDOFF.md`.
- For broad review workflows, require the final output to use this section order: `Routing`, `Activated skills`, `Review scope`, `Discovery findings`, `Overall assessment`, `Findings`, `Test coverage assessment`, `Residual risks`, `Recommendation`.
- For broad review workflows, `Activated skills` must explicitly name `apple-appdev-workflow:apple-review-orchestrator`; `apple-appdev-workflow:apple-app-orchestrator` plus station skills alone is not sufficient.
- For broad debug workflows, require the final output to use this section order: `Routing`, `Activated skills`, `Debug scope`, `Reproduction status`, `Discovery findings`, `Evidence reviewed`, `Likely root cause`, `Validation gaps`, `Next diagnostic step`, `Recommended fix path`, `Residual risks`.
- For broad debug workflows, `Activated skills` must explicitly name `apple-appdev-workflow:apple-debug-orchestrator`; runtime station skills alone are not sufficient.
- For broad product-surface work, require the final output to use this section order: `Routing`, `Activated skills`, `Surface scope`, `Discovery findings`, `Surface assessment`, `Coordinated recommendations`, `Validation and rollout notes`, `Direct follow-on lanes`.
- For broad product-surface work, `Activated skills` must explicitly name `apple-appdev-workflow:apple-product-surface-orchestrator`; the station skills alone are not sufficient.
- For broad persistence work, require the final output to use this section order: `Routing`, `Activated skills`, `Persistence scope`, `Discovery findings`, `Persistence assessment`, `Coordinated recommendations`, `Migration and rollout notes`, `Direct follow-on lanes`.
- For broad persistence work, `Activated skills` must explicitly name `apple-appdev-workflow:apple-persistence-orchestrator`; the persistence stations alone are not sufficient.
- For release-readiness passes, require the final output to use this section order: `Routing`, `Activated skills`, `Release scope`, `Overall status`, `Evidence reviewed`, `Manual-validation status`, `Release-ops status`, `Blockers`, `Residual risks`, `Recommendation`.
- For release-readiness passes, `Activated skills` must explicitly name `apple-appdev-workflow:apple-release-orchestrator`; `apple-appdev-workflow:apple-app-orchestrator` plus release stations alone is not sufficient.
- For broad accessibility work, require the final output to use this section order: `Routing`, `Activated skills`, `Accessibility scope`, `Framework targets`, `Overall assessment`, `Required implementation constraints`, `Validation checklist`, `Manual checks`, and `Release-claim notes` when relevant.
- For broad accessibility work, `Activated skills` must explicitly name `apple-appdev-workflow:apple-accessibility-orchestrator`; foundation and framework auditors alone are not sufficient.
- For code-changing feature work, require the final response to state: `Routing`, `Activated skills`, `Tests added or updated`, `Validation executed`, and `Branch-diff review status` before any commit or merge step is treated as complete.

## Lane-specific trigger catalogue
- Follow `../../references/apple-skill-orchestration.md` for the detailed request phrases, precedence rules, and specialist trigger lists for bootstrap, review, debug, release, accessibility, architecture, persistence, product surface, SwiftUI, SwiftData, Core Data, App Store, observability, manual validation, runtime debugging, concurrency, and testing.
- Do not duplicate those long trigger catalogues in this hot-path file; the reference is the source of truth for the detailed lane map.
- If a detailed trigger in `../../references/apple-skill-orchestration.md` conflicts with the core route ownership or final `Activated skills` rules above, keep the ownership and final-evidence rules here and update the reference in the same branch.

## Validation rules
- For code changes, require an explicit review pass on the current branch diff before commit or merge. Do not substitute a generic whole-codebase review.
- Treat user requests to `commit`, `merge`, `ship it`, or otherwise finalize code work as automatic triggers for the precommit sequence: branch-diff review, test-gap check, focused validation, then commit or merge.
- Activate `apple-appdev-workflow:apple-testing-quality-gates` before concluding code work, and do not consider code work done until relevant tests are meaningful and green.
- Do not allow commit or merge completion on code changes until the final branch-diff review and relevant green test evidence are explicitly reported.
- For release, pre-ship, or hardware-sensitive work, do not treat simulator evidence alone as sufficient when manual device validation is materially relevant.
