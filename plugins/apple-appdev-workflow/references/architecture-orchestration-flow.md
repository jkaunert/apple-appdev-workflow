# Architecture Orchestration Flow

Use this reference to keep broad architecture work sequenced consistently.

## Goal

Separate:

- top-level intake via `apple-appdev-workflow:apple-app-orchestrator`
- architecture-domain coordination via `apple-appdev-workflow:apple-architecture-orchestrator`
- discovery via `apple-appdev-workflow:apple-discovery-first`
- design and boundary judgment via `apple-appdev-workflow:apple-architecture-design`
- optional specialist evidence when persistence, concurrency, or testing seams materially affect the recommendation

## Required Sequence

1. Start broad architecture work at `apple-appdev-workflow:apple-app-orchestrator` unless the runtime directly selects the architecture brigade.
2. Hand broad architecture work to `apple-appdev-workflow:apple-architecture-orchestrator`.
3. Run `apple-appdev-workflow:apple-discovery-first` to map the real repo, project, package, and ownership shape before recommending structural changes.
4. Run `apple-appdev-workflow:apple-architecture-design` to evaluate boundaries, dependency direction, DI seams, navigation ownership, concurrency model, and state ownership.
5. Preserve a short brigade-owned discovery memo once the boundary evidence is stable, then use that memo as the only input to final architecture synthesis.
6. Activate `apple-appdev-workflow:apple-swiftdata-foundations` or `apple-appdev-workflow:apple-core-data-expert` only when storage ownership or coexistence materially changes the architecture answer.
7. Activate `apple-appdev-workflow:apple-swift-concurrency-foundations` or `apple-appdev-workflow:apple-swift-concurrency-review` only when concurrency boundaries materially change the answer.
8. Activate `apple-appdev-workflow:apple-decision-stress-test` only when the architecture decision is high-consequence, hard to reverse, or materially contested.
9. Plate one final architecture recommendation through the brigade owner.

## Failure Patterns To Avoid

- broad architecture prompts collapsing directly into `apple-appdev-workflow:apple-discovery-first`
- broad architecture prompts collapsing directly into `apple-appdev-workflow:apple-architecture-design`
- discovery findings surfacing as the final answer
- treating this lane like branch-diff review
- treating this lane like same-turn implementation
- activating decision stress testing for ordinary uncertainty
- reopening discovery after the staged evidence memo is already stable

## Notes

- This lane is assessment-first by default.
- Broad recommendation-first architecture work is intentionally allowed to stage discovery and synthesis as separate brigade-owned phases when that preserves recommendation quality.
- If the user later wants implementation, that is a follow-on mutating pass.
- During broad greenfield bootstrap, architecture is a handoff target unless the user explicitly asks to continue after bootstrap.
