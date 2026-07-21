---
name: apple-observability-diagnostics
description: Focused observability and diagnostics subskill for iOS/macOS apps. Use for structured logging, analytics event quality, crash context, rollout monitoring, and production-debugging readiness, usually after `apple-appdev-workflow:apple-app-orchestrator` scopes the broader workflow.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Observability Diagnostics

## Required context
- Load `../../references/observability-foundations.md`.
- Load `../../references/apple-logging-policy.md`.
- Load `../../references/analytics-event-quality.md` when analytics or product instrumentation is in scope.
- Load `../../references/crash-context-and-breadcrumbs.md` when crash diagnosis, async failure, or state-reconstruction gaps are in scope.
- Load `../../references/rollout-monitoring.md` when staged rollout, launch monitoring, or post-release diagnostics are in scope.

## Entry rule
- Use this skill directly only for focused observability, diagnostics, logging, telemetry, analytics, or rollout-monitoring asks.
- When the request is a broad feature, release, or multi-skill workflow, start with `apple-appdev-workflow:apple-app-orchestrator` and let it activate this skill.

## Responsibilities
- Own structured logging policy for Apple app features.
- Own analytics event quality, naming discipline, and payload hygiene.
- Own crash-context and breadcrumb guidance for production debugging readiness.
- Own rollout monitoring expectations for high-risk launches and staged releases.
- Keep observability guidance privacy-conscious and implementation-focused.

## Workflow
1. Define the operational questions the team needs to answer after shipping.
2. Identify the critical user journeys, async boundaries, and failure states that need observability.
3. Specify what should be logged, what should be counted, and what should never be emitted.
4. Add or refine analytics events only where they support concrete product or reliability decisions.
5. Add crash breadcrumbs or context capture where state reconstruction would otherwise be weak.
6. For release-sensitive work, define launch and rollout monitoring expectations before ship.
7. Summarize the minimum useful observability surface, residual blind spots, and next steps.

## Output contract
- Routing: `focused subskill`
- Critical flows requiring observability
- Recommended structured logs and fields
- Analytics events to add, change, or avoid
- Crash-context or breadcrumb recommendations
- Rollout monitoring expectations
- Privacy and data-minimization notes
- Residual observability gaps

## Guardrails
- Do not turn this into vendor-specific SDK installation unless the user explicitly asks.
- Do not recommend analytics events without a concrete product or operational question.
- Keep logs and telemetry free of secrets, raw PII, and unnecessary payloads.
- Prefer consistent event names and small, well-defined payloads over ad hoc metrics sprawl.
- Treat missing observability on critical flows as a release-risk input, not a cosmetic follow-up.
