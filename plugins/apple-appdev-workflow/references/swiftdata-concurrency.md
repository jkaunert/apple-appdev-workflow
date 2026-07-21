# SwiftData Concurrency

Use for SwiftData-specific context and actor-boundary rules.

## Baseline
- Keep model instances and contexts within their intended isolation domains.
- Re-fetch by identifier when data must cross actor or context boundaries.
- Use model actors or clearly owned background contexts for non-UI persistence work.

## Guardrails
- Do not pass model instances freely across actors.
- Do not paper over isolation issues with unsafe annotations.
- Escalate broader concurrency-model design to `apple-appdev-workflow:apple-swift-concurrency-foundations`.
