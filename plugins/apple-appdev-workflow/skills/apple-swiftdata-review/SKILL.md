---
name: apple-swiftdata-review
description: Narrow SwiftData review and remediation skill for Apple projects. Use when reviewing or fixing existing SwiftData code for predicate safety, delete semantics, context misuse, save behavior, indexing, or CloudKit compatibility after the scope is already known. Do not use this as the first lane for broad recommendation-first prompts about migration approach, rollout risk, data-loss risk, or what should change first.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple SwiftData Review

## Required context
- Load `../../references/swiftdata-review-rules.md`.
- Load `../../references/swiftdata-querying-and-predicates.md` when queries or predicate crashes are involved.
- Load `../../references/swiftdata-indexing-and-availability.md` when indexing or newer features are in scope.
- Load `../../references/apple-mcp-workflow.md`.

## Responsibilities
- Own rules-driven SwiftData review and tactical remediation.
- Prioritize data loss, runtime crashes, sync divergence, context-isolation bugs, and migration risk over stylistic concerns.
- Provide findings-first review output for review requests.
- Escalate greenfield schema design back to `apple-appdev-workflow:apple-swiftdata-foundations`.
- When `apple-appdev-workflow:apple-persistence-orchestrator` is active, return findings upward and do not replace the brigade-owned final answer.

## Workflow
1. Identify whether the task is review, bugfix, predicate crash, save failure, migration bug, or sync-risk audit.
2. Check container and context assumptions before diagnosing downstream symptoms.
3. Apply the narrowest relevant rule set.
4. Report the highest-risk issues first, with concrete remediation guidance.
5. Activate `apple-appdev-workflow:apple-swiftdata-foundations` when the task expands into architecture or migration design.
6. Activate `apple-appdev-workflow:apple-core-data-expert` if the codepath is actually Core Data or a coexistence bridge.

## Output contract
- Findings by severity for review tasks
- Exact risky pattern and why it is unsafe
- Minimal safe fix or remediation path
- Validation needed after the fix
- Follow-on skill activation when applicable

## Guardrails
- Do not nitpick unrelated Swift style.
- Do not recommend indexes, uniqueness, or inheritance without checking deployment-target support.
- Do not assume autosave timing is sufficient when correctness depends on deterministic persistence.
- Do not ignore delete rules, inverse relationships, or migration implications in reviews.
- Do not let this station replace an already-active persistence brigade as the final persistence narrator.
- If the prompt is broad and recommendation-first, including wording such as `migration approach`, `rollout risk`, `data-loss risk`, or `what should change first`, do not self-start as the visible owner. Route that work through `apple-appdev-workflow:apple-persistence-orchestrator`.
