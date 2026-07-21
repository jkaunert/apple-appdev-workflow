# Observability Foundations

Use this reference when Apple app work needs production-debugging readiness.

## Core rule
- Instrument only what helps answer a concrete operational or product question.

## Coverage priorities
- critical user journeys
- async boundaries and task failures
- network/service failure states
- persistence writes, migrations, and sync anomalies
- launch, onboarding, permissions, and purchase-sensitive flows

## Expected outputs
- structured logs for important state transitions and failures
- analytics for product questions, not generic curiosity
- crash-context breadcrumbs where post-failure reconstruction would otherwise be weak
- rollout monitoring for high-risk releases

## Anti-patterns
- print-debugging as the only production diagnostic surface
- duplicate events with inconsistent naming
- large arbitrary payloads
- logs that leak user content, secrets, or identifiers without a justified need
