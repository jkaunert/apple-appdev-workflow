---
name: apple-swift-concurrency-review
description: Swift Concurrency diagnostics and remediation review for Apple projects. Use when reviewing files or features for concurrency correctness, fixing strict-concurrency compiler errors, investigating data-race risks, or cleaning up task, cancellation, continuation, and reentrancy bugs.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Swift Concurrency Review

## Required context
- Load `../../references/swift-concurrency-diagnostics.md`.
- Load `../../references/swift-concurrency-foundations.md` for baseline policy.
- Load `../../references/swift-concurrency-actors-and-sendable.md` when actor or Sendable boundaries are involved.
- Load `../../references/swift-concurrency-tasks-and-cancellation.md` when task structure, cancellation, or unstructured work is involved.
- Load `../../references/swift-concurrency-interop-and-streams.md` when continuations, streams, or legacy interop are involved.
- Load `../../references/swift-concurrency-swift-6-2.md` when Swift 6.2 or approachable-concurrency behavior might change the remediation.
- Load `../../references/swift-concurrency-testing.md` when the review should include concurrency-sensitive tests.

## Responsibilities
- Own findings-first concurrency review and remediation guidance.
- Prioritize genuine correctness and data-race risks over style-only comments.
- Map strict-concurrency diagnostics to the smallest safe fixes.
- Review hotspot patterns such as `Task.detached`, `Task {}` in loops, unchecked continuations, async streams, actor reentrancy, global mutable state, and cancellation leaks.

## Workflow
1. Capture the exact compiler diagnostics or concurrency hotspot being reviewed.
2. Confirm the current isolation boundary and relevant project settings.
3. Identify the highest-risk concurrency failures first: data races, actor reentrancy, cancellation loss, continuation misuse, unstructured task leaks, and shared mutable globals.
4. Recommend the smallest fix that preserves behavior and improves correctness.
5. Call out testing or validation gaps for concurrency-sensitive code.

## Output contract
- Findings ordered by severity
- File and line references when reviewing concrete code
- Brief rule name and why it matters
- Patch-ready fix guidance
- Residual concurrency risk or follow-up notes

## Guardrails
- Do not nitpick harmless style choices.
- Do not recommend suppressions or unsafe annotations without an explicit safety invariant.
- Do not prefer review-only wording when the user asked for direct fixes; use the same rules but apply the changes directly.
