---
name: apple-swiftdata-foundations
description: SwiftData persistence foundations for Apple projects. Use for focused SwiftData schema, container, query, migration, history, CloudKit, or coexistence design work after the persistence scope is already clear. For broad recommendation-first persistence review, rollout risk, or what-should-change-first prompts, route through `apple-appdev-workflow:apple-persistence-orchestrator` first.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple SwiftData Foundations

## Required context
- Load `../../references/swiftdata-foundations.md`.
- Load only the specific SwiftData references needed for the task.
- Load `../../references/apple-mcp-workflow.md`.

## Responsibilities
- Own implementation and migration guidance for SwiftData persistence.
- Require deployment-target intake before recommending availability-sensitive APIs such as `#Unique`, `#Index`, history APIs, or inheritance patterns.
- For predictable SwiftData symbols, prefer local SDK interface inspection or direct `apple-appdev-workflow:fetch-apple-docs` lookup over generic Apple web search. Within `apple-appdev-workflow:fetch-apple-docs`, prefer MCP first, then Sosumi CLI, then direct Sosumi HTTP.
- When current Apple API, migration, or WWDC guidance is needed, route that lookup through `apple-appdev-workflow:fetch-apple-docs` before generic web search.
- Treat container wiring, context ownership, delete semantics, migration safety, and sync constraints as first-class concerns.
- Keep SwiftData guidance aligned with service-based architecture, concurrency boundaries, and testability.
- When `apple-appdev-workflow:apple-persistence-orchestrator` is active, return SwiftData evidence upward and do not replace the brigade-owned route block or final answer.

## Workflow
1. Determine whether the task is schema design, query design, lifecycle wiring, migration, history, sync, or coexistence with Core Data.
2. Decide whether the request is design-only or implementation. If the user asked to design or recommend an approach, default to a non-mutating design pass unless they explicitly ask to scaffold or wire code.
3. For broad persistence review routed through `apple-appdev-workflow:apple-persistence-orchestrator`, feed SwiftData guidance into the brigade-owned persistence sections rather than inventing a station-local final summary.
4. Confirm deployment target and current `ModelContainer` or `ModelContext` setup before recommending fixes.
5. If current Apple docs or WWDC guidance are needed, activate `apple-appdev-workflow:fetch-apple-docs` before the first Apple-doc lookup step appears in the trace.
6. When the SwiftData page path is known or predictable, fetch it directly through `apple-appdev-workflow:fetch-apple-docs` transport such as MCP, Sosumi CLI, or direct Sosumi HTTP. Prefer MCP first, then CLI, then HTTP. Do not begin with generic web search for common symbols like `VersionedSchema`, `SchemaMigrationPlan`, `ModelContainer`, or `@Attribute(.externalStorage)`.
7. For simple API-surface confirmation on local Apple SDKs, prefer local interface inspection before reaching for generic Apple web search.
8. Use generic web search only through `apple-appdev-workflow:fetch-apple-docs`, and only after emitting the correct literal line from `../../skills/fetch-apple-docs/SKILL.md` in the immediately preceding trace step:
   - use the path-discovery line when the Apple page path is genuinely unknown
   - use the fallback-to-search line when direct fetch was unavailable or insufficient
9. Choose the narrowest SwiftData reference set needed for the task.
10. Keep persistence logic out of pure views; route architectural boundaries back through service and repository layers.
11. Activate `apple-appdev-workflow:apple-swift-concurrency-foundations` when persistence work changes actor isolation or broader concurrency design materially.
12. Activate `apple-appdev-workflow:apple-swift-testing-foundations` when persistence scenarios need new or updated tests.
13. Activate `apple-appdev-workflow:apple-core-data-expert` when the task is a Core Data migration or coexistence problem rather than pure SwiftData work.

## Output contract
- Deployment-target assumptions and relevant API gates
- Recommended ownership and container wiring
- Schema and relationship guidance
- Migration and history guidance
- Data-loss or rollout risks
- Next implementation entry points or validation hooks
- When routed through `apple-appdev-workflow:apple-persistence-orchestrator`, feed this material into the brigade-owned persistence sections rather than inventing a standalone final heading such as `Recommended Shape` or `Design`.
- When routed through `apple-appdev-workflow:apple-persistence-orchestrator`, do not let this station's prose replace the brigade route block or final user-facing answer.

## Guardrails
- Do not recommend SwiftData APIs without checking deployment-target support.
- Do not debug empty fetches or failed inserts before confirming container wiring.
- Do not move persistence orchestration into views just because `@Query` exists.
- Do not treat schema changes as casual refactors; assess migration and deletion behavior explicitly.
- Do not turn a design-only SwiftData prompt into code changes unless the user explicitly asked for implementation or the parent workflow already committed to a mutating pass.
- Do not let this station replace an already-active persistence brigade as the final persistence narrator.
- Do not use raw `developer.apple.com` or `sosumi.ai` search, including `site:sosumi.ai ...`, as the first Apple-doc step when `apple-appdev-workflow:fetch-apple-docs` is available.
- Do not narrate that `apple-appdev-workflow:fetch-apple-docs` is being used directly and then start with generic `developer.apple.com` search anyway; direct fetch or explicit fallback only.
- Do not let a final `Activated skills` mention of `apple-appdev-workflow:fetch-apple-docs` paper over an earlier generic search or unlabeled Sosumi fetch.
- If Apple docs are consulted, do not let the first Apple-doc-related trace event be a generic search or unlabeled Sosumi transport; make `apple-appdev-workflow:fetch-apple-docs` visible first or emit the appropriate literal path-discovery or fallback-to-search line immediately before the first search event.
