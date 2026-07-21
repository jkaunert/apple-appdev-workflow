# Output Patterns

Choose the narrowest artifact that still preserves the reconstruction.

## Full reconstruction memo

Use when the user needs to understand how a complex system evolved.

Recommended sections:

1. Scope
2. Evidence base
3. Current source of truth
4. Historical phases
5. What was tried
6. What stayed
7. What was rejected or demoted
8. Current drifts or open questions
9. Implications
10. Next moves

## Drift reconciliation note

Use when the main job is comparing current code against older intent.

Recommended sections:

1. Surface under review
2. Current state
3. Historical state
4. Strongest evidence for intended state
5. Reconciliation
6. Remaining uncertainty

## Adoption impact note

Use when the user is deciding whether a new runtime or branch should replace an
older baseline.

Recommended sections:

1. Candidate baseline
2. What it already subsumes
3. What local carry is still required
4. What would regress if adopted now
5. Validation gates before cutover

## Lineage map

Use when the key missing piece is which sibling repos or branches matter.

Recommended sections:

1. Bundle lineage
2. Runtime lineage
3. Host or deployment lineage
4. Current source-of-truth pair
5. Which surfaces are historical only

## Practical rules

1. Name the actual repo and branch whenever a conclusion depends on lineage.
2. Name the actual runtime and host surface whenever a conclusion depends on
   behavior.
3. Separate "present truth" from "historical intent" explicitly.
4. End with a decision rule or next-step recommendation, not only history.
