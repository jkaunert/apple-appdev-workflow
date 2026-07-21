# Architecture Evidence Aggregation

Broad architecture outputs should aggregate discovery, design, and optional specialist evidence into one coherent recommendation.

## Required Sections

Broad architecture workflows should end with:

1. `Activated skills`
2. `Assessment scope`
3. `Discovery findings`
4. `What Should Change First`
5. `Recommended follow-on structure`
6. `Risks`
7. `Next implementation entry points`

## Activated Skills Rules

- name `apple-appdev-workflow:apple-app-orchestrator`
- name `apple-appdev-workflow:apple-architecture-orchestrator`
- name `apple-appdev-workflow:apple-discovery-first`
- name `apple-appdev-workflow:apple-architecture-design`
- include persistence, concurrency, testing, or decision-stress stations only when they materially shaped the answer
- do not let the final answer read like several station-local mini reports

## What Should Change First

- give one highest-leverage structural change
- make the ownership or dependency shift explicit
- avoid generic advice like `improve modularity`

## Recommended Follow-On Structure

- describe the next stable target shape
- keep it architectural, not implementation-heavy
- identify which family stations or follow-on lanes should own the next phase

## Risks

- call out migration risk, ownership confusion, concurrency risk, persistence risk, or rollout risk when relevant

## Next Implementation Entry Points

- name the first two or three places where follow-on implementation should begin
- keep this actionable enough to hand off into the next lane
