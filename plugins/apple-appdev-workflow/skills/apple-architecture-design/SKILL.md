---
name: apple-architecture-design
description: Architecture design for iOS/macOS apps using Swift 6 and SwiftUI. Use for module boundaries, protocol contracts, actor isolation, navigation flow, and dependency injection decisions.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Architecture

## Required context
- Load `../../references/apple-architecture-baselines.md`.
- Load `../../references/ui-decoupling-baseline.md`.
- Load `../../references/pattern-selection-criteria.md`.
- Load `../../references/apple-mcp-workflow.md`.
- Load `../../references/architecture-assessment-trace-template.md` when the task is a non-mutating architecture or app-structure assessment routed through the orchestrator.

## Workflow
1. Define module boundaries and ownership.
2. Specify protocol contracts and dependency directions.
3. Define concurrency model (MainActor, actors, Sendable boundaries).
4. Activate `apple-appdev-workflow:apple-swiftdata-foundations` when persistence architecture, SwiftData store ownership, model boundaries, migrations, history, or sync strategy materially affect design.
5. Activate `apple-appdev-workflow:apple-core-data-expert` when an existing Core Data stack or SwiftData/Core Data coexistence strategy materially affects architecture.
6. Do not activate `apple-appdev-workflow:apple-decision-stress-test` inside this skill. If a boundary or migration choice still needs pressure-testing after the design read, recommend a separate isolated stress-test pass.
7. Activate `apple-appdev-workflow:apple-swift-concurrency-foundations` when detailed concurrency migration, settings intake, or isolation remediation guidance is needed.
8. Select DI and navigation coordinator patterns using criteria.
9. Persist high-value architectural constraints in `memory` when they are likely to be needed across turns.
10. Plan incremental migration and rollback-safe rollout.
11. When operating under an orchestrator-led architecture assessment, follow `../../references/architecture-assessment-trace-template.md` for the first progress update and the final section headings expected by the parent workflow. Do not emit `I'm reviewing...` or other setup prose ahead of the route block.
12. When operating under an orchestrator-led workflow, feed architectural findings into the parent summary rather than taking over the first route block or the final user-facing answer.

## Quality bar
- Concurrency boundaries are explicit.
- Protocol-based DI is preserved.
- Navigation mutations are coordinator-owned.
- Pure views stay decoupled from services and persistence.

## Guardrails
- Do not use this skill for same-turn work during broad greenfield bootstrap unless the user explicitly asked to continue after bootstrap or to scaffold and then implement in the same turn.
- Embedded architecture preferences inside a scaffold prompt do not count as that continuation signal.
- Do not let a standalone architecture findings dump replace the parent orchestrator summary when the workflow is orchestrator-led.
- Do not emit standalone `P1`/`P2` finding cards as the final answer for orchestrator-led architecture assessment work; collapse the result into the parent brigade summary.
