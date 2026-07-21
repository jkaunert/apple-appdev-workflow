---
name: apple-swiftui-performance-audit
description: SwiftUI runtime performance audit for Apple projects. Use when diagnosing slow rendering, janky scrolling, hangs, hitches, high CPU or memory usage, excessive view updates, layout thrash, SwiftUI invalidation-boundary problems, ForEach identity issues, Observation fan-out, environment invalidation, conditional modifier churn, or animation cost in SwiftUI code.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple SwiftUI Performance Audit

## Required context
- Load `../../references/swiftui-performance-audit.md`.
- Load `../../references/swiftui-performance-smells.md`.
- Load `../../references/swiftui-specialist-integration.md` when performance depends on SwiftUI structure, data flow, Observation granularity, environment values, `ForEach` identity, conditional modifiers, custom animation, or SDK 27 source compatibility.
- Load `../../references/swiftui-performance-instruments.md` when code review alone is insufficient.
- Load `../../references/apple-mcp-workflow.md`.

## Responsibilities
- Own SwiftUI runtime performance triage and remediation guidance.
- Fold official SwiftUI specialist performance-relevant guidance into station-owned audits instead of using unmanaged parallel skills.
- Start with a code-first audit when code is available.
- Escalate to user-run Instruments profiling when evidence from code review is insufficient.
- Keep the focus on SwiftUI runtime behavior, view updates, layout, identity, and rendering cost.

## Workflow
1. Determine whether the task is code review, symptom triage, or trace analysis.
2. If code is available, audit likely causes before asking for profiling data.
3. Check official SwiftUI specialist topics that affect runtime behavior: invalidation boundaries, narrow value inputs, Observation dependency breadth, environment comparison, stable data-driven identity, conditional modifier identity churn, and animation cost.
4. Identify the highest-impact SwiftUI performance smells and explain why they matter.
5. When code review is inconclusive, guide the user to capture the narrowest useful Instruments trace.
6. Summarize findings with evidence and targeted remediation steps.
7. Ask for before or after comparison data when performance work is iterative.

## Output contract
- Top likely root causes ordered by impact
- Evidence from code or traces
- Targeted fixes or refactors
- Profiling steps when more evidence is required
- Expected verification method after changes

## Guardrails
- Do not default-load the raw exported SwiftUI specialist corpus or route around this bundle's SwiftUI stations.
- Do not turn this into a generic all-platform performance skill.
- Do not recommend profiling first when obvious code-level SwiftUI issues are present.
- Do not claim performance improvement without a verification path.
