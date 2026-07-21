# SwiftData Foundations

Use behind `apple-appdev-workflow:apple-swiftdata-foundations` for deployment-aware SwiftData guidance.

## Baseline
- Confirm deployment target before recommending newer SwiftData APIs.
- Confirm `ModelContainer` wiring before debugging inserts, fetches, or autosave behavior.
- Treat prompts framed as schema design or migration-approach requests as non-mutating design work unless the user explicitly asks to scaffold or implement code.
- When current Apple API or migration behavior needs verification, route the lookup through `apple-appdev-workflow:fetch-apple-docs` before generic web search and keep that route visible before the first lookup step.
- When the SwiftData page path is known or predictable, fetch it directly through `apple-appdev-workflow:fetch-apple-docs` transport such as MCP, Sosumi CLI, or direct Sosumi HTTP rather than searching first. Prefer MCP first, then CLI, then HTTP.
- For predictable symbols and availability checks, prefer local SDK interface inspection before generic Apple web search.
- Treat model code as schema source of truth.
- Prefer explicit saves when correctness matters; do not rely on autosave timing for critical boundaries.
- Use stable persistent identifiers only after initial save.

## Default expectations
- Persisted models are `@Model` types.
- Queries and relationships should be deterministic and explicit.
- Delete rules and migration impact are domain concerns, not optional polish.
- Persistence boundaries should stay behind services or repositories rather than leaking into pure UI.

## Output expectations
- Feed deployment-target assumptions, ownership boundaries, schema guidance, migration implications, and rollout risks into the parent workflow summary.
- In orchestrator-led design passes, keep those contributions under the parent brigade headings rather than emitting a specialist-owned final heading like `Recommended Shape`.
- For broad persistence review owned by `apple-appdev-workflow:apple-persistence-orchestrator`, feed SwiftData evidence into the brigade-owned persistence sections instead of using the historical station-owned persistence trace directly.
- If current Apple docs were consulted, keep that lookup visibly routed through `apple-appdev-workflow:fetch-apple-docs` before the first Apple-doc lookup step appears in the trace.
