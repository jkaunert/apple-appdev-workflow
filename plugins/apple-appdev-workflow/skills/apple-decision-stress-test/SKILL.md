---
name: apple-decision-stress-test
description: Decision stress-testing for Apple app work. Use only when a user explicitly asks for an isolated critique, comparison, or challenge pass on an important decision.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Decision Stress Test

## Required context
- Load `../../references/decision-stress-test-foundations.md`.
- Load `../../references/reasoning-error-patterns.md`.
- Load `../../references/decision-review-template.md`.

## Responsibilities
- Own structured challenge-review for important technical and product decisions.
- Operate only as an isolated focused pass, not as a downstream ingredient inside a broad brigade.
- Steel-man a position before criticizing it.
- Surface hidden assumptions, strongest objections, best alternatives, and key failure modes.
- Keep the analysis practical, concise, and recommendation-oriented.

## Workflow
1. State the decision, claim, or plan precisely.
2. Steel-man the current position before critique.
3. List the core assumptions and what evidence they rely on.
4. Identify the strongest alternative and strongest criticism.
5. Check whether the reasoning overclaims, hides a false dichotomy, or depends on ad hoc rescue logic.
6. Separate reversible from irreversible parts of the decision.
7. State what evidence would materially weaken or change the recommendation.
8. End with a practical recommendation, not just critique.

## Output contract
- Decision or claim being tested
- Strongest case for it
- Core assumptions
- Strongest criticism and best alternative
- Failure modes and reversibility analysis
- What would change the recommendation
- Final recommendation

## Guardrails
- Do not accept broad orchestrator-led ownership by implication. If invoked from a broad architecture, release, rollout, or migration workflow, narrow the task to an isolated decision-review pass or hand it back to the owning lane.
- Do not use this as a default step for routine implementation work.
- Do not drift into abstract philosophy or long epistemology explanations.
- Do not criticize a weaker version of the position than a thoughtful proponent would hold.
- Do not stop at uncertainty; recommend the strongest practical next move.
