---
name: apple-architecture-orchestrator
description: Architecture-domain expediter for broad Apple architecture assessment, structure review, and recommendation-first boundary work. Use this first for recommendation-first prompts about architecture, boundaries, dependency direction, or what should change first in app structure.
metadata:
  role: brigade-orchestrator
  entrypoint: delegated
  routing_scope: domain
---

# Apple Architecture Orchestrator

## Required context
- Load `../../references/architecture-orchestration-flow.md`.
- Load `../../references/architecture-evidence-aggregation.md`.
- Load `../../references/apple-skill-orchestration.md`.
- Load `../../references/architecture-assessment-trace-template.md`.
- Load `../../references/brigade-output-contract.md`.

## Entry rule
- Use this skill for broad architecture-domain requests.
- For recommendation-first prompts about architecture, boundaries, dependency direction, navigation or composition ownership, or what should change first in app structure, treat this brigade as the preferred domain owner instead of a downstream discovery or design station.
- Direct or implicit use is correct when the runtime selects the domain brigade first.
- Broad user-facing architecture work must remain brigade-routed through this skill rather than collapsing directly into `apple-appdev-workflow:apple-discovery-first` or `apple-appdev-workflow:apple-architecture-design`.
- When activated by `apple-appdev-workflow:apple-app-orchestrator`, this skill owns architecture-domain sequencing and the required architecture brigade shape, but it returns that structure to the parent orchestrator. It does not replace the parent route block or final-answer ownership.
- When this skill is active directly, it is the sole final narrator for broad architecture work at the architecture-domain layer.
- When this skill is active, do not mention `apple-appdev-workflow:apple-app-orchestrator` in the first visible architecture route block. Keep that block architecture-brigade-scoped.
- For broad recommendation-first architecture work, staged execution is intentional product behavior: use a bounded discovery and evidence pass first, then plate one brigade-owned recommendation synthesis without reopening discovery.

## First output rule
- For a broad, non-mutating architecture pass, emit the literal route block from `../../references/architecture-assessment-trace-template.md` before any bundle-authored progress update.
- When this lane is activated by `apple-appdev-workflow:apple-app-orchestrator`, parent route ownership is satisfied by surfacing that brigade block. Do not replace it with a parent-only, hybrid, or custom `Mode:` block.
- Apply the shared no-preamble and no-progress-bullets rules in `../../references/brigade-output-contract.md`.

## Scope
Use this skill when the request is about:
- assessing an app's architecture
- evaluating app structure, ownership seams, or dependency direction
- recommending what should change first in module, feature, or package boundaries
- deciding what should own navigation, composition, or state coordination
- recommending how persistence or concurrency boundaries should influence the overall structure
- broad architecture recommendation-first asks that span more than one family station

Keep this brigade out of:
- branch-diff review
- routine bootstrap scaffolding
- same-turn feature implementation
- narrow one-file refactors that already have a clear direct owner

## Workflow
1. Start with a discovery-first architecture scan of the effective working root, project shape, package shape, and the structural question actually being asked.
2. Confirm whether the lane is assessment-first or whether the user explicitly wants implementation in the same turn.
3. Activate `apple-appdev-workflow:apple-discovery-first` to map the real repo, project, package, and ownership shape before recommending structural changes.
4. Activate `apple-appdev-workflow:apple-architecture-design` to evaluate boundaries, dependency direction, DI seams, navigation ownership, concurrency model, and state ownership.
5. For broad assessment-first work, preserve a short brigade-owned discovery memo once the boundary evidence is stable, then use that memo as the sole input to the final architecture synthesis.
6. Activate `apple-appdev-workflow:apple-swiftdata-foundations` or `apple-appdev-workflow:apple-core-data-expert` only when storage ownership, migration shape, or coexistence materially changes the architecture answer.
7. Activate `apple-appdev-workflow:apple-swift-concurrency-foundations`, `apple-appdev-workflow:apple-swift-concurrency-review`, or `apple-appdev-workflow:apple-swift-testing-foundations` only when concurrency or test seams materially change the architecture answer.
8. Activate `apple-appdev-workflow:fetch-apple-docs` only when the architecture recommendation depends on current Apple API, HIG, or platform guidance rather than local code reality alone.
9. Do not activate `apple-appdev-workflow:apple-decision-stress-test` inside the architecture brigade. If the user still wants challenge-review after the architecture recommendation is clear, recommend a separate isolated stress-test pass.
10. Require every downstream station to return evidence upward only; do not allow station-local findings dumps, architecture notes, or freeform wrap-ups to become the final architecture answer.
11. Aggregate the result into one brigade-owned architecture recommendation.
12. In staged architecture mode, do not reopen discovery once the evidence memo is stable. The second stage is recommendation synthesis only: highest-leverage change, follow-on structure, risks, and entry points.
13. If this skill was activated by `apple-appdev-workflow:apple-app-orchestrator`, return the architecture brigade content upward for parent emission rather than treating this skill as the top-level final narrator.

## Output contract
- Apply the shared brigade rules in `../../references/brigade-output-contract.md`.
- The final user-facing architecture summary must include these sections in this order:
  1. `Activated skills`
  2. `Assessment scope`
  3. `Discovery findings`
  4. `What Should Change First`
  5. `Recommended follow-on structure`
  6. `Risks`
  7. `Next implementation entry points`
- Use those exact section labels.
- In authoritative broad architecture summaries, `Activated skills` must preserve `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-architecture-orchestrator`.
- `Activated skills` must also name `apple-appdev-workflow:apple-discovery-first` and `apple-appdev-workflow:apple-architecture-design`.
- Include optional persistence, concurrency, testing, doc, or decision-stress stations only when they materially shaped the answer.
- `What Should Change First` must give one highest-leverage structural change, not a generic modularity slogan.
- `Recommended follow-on structure` must stay architectural and handoff-oriented rather than drifting into implementation detail.
- `Next implementation entry points` should name the first two or three places where the follow-on implementation lane should begin.
- If Apple documentation was consulted during the architecture pass, `Activated skills` must also name `apple-appdev-workflow:fetch-apple-docs`, and that skill must be visible before the first Apple-doc lookup step appears in the trace.

## Guardrails
- Do not let `apple-appdev-workflow:apple-discovery-first` become the first visible routing layer for broad architecture work.
- Do not let `apple-appdev-workflow:apple-architecture-design` replace the brigade as the visible owner or final narrator for broad architecture work.
- Do not treat a branch-diff findings pass as architecture assessment just because boundaries or layering are mentioned.
- Do not turn a broad greenfield bootstrap request into same-turn architecture work unless the user explicitly asked to continue after bootstrap concluded.
- Do not activate `apple-appdev-workflow:apple-decision-stress-test` from this lane at all; keep architecture ownership intact and move any explicit challenge-review into a separate isolated pass.
- Do not let standalone `P1` or `P2` cards, ADR prose, or discovery notes escape ahead of the brigade summary.
