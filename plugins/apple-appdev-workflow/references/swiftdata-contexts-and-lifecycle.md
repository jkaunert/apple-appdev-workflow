# SwiftData Contexts and Lifecycle

Use for container setup, contexts, saves, deletes, and lifecycle hooks.

## Container-first rule
- Attach a real `ModelContainer` at app, scene, or explicit composition root level before debugging store behavior.
- If container wiring is wrong, downstream query and save symptoms are misleading.

## Context rules
- `mainContext` or environment model context is for UI-driven work.
- Custom contexts are for controlled background or utility work.
- Use explicit saves when operation boundaries must be deterministic.

## Operational guardrails
- Save before relying on a model's stable persistent identifier.
- Clear selection or references before deleting selected models.
- Review unbounded delete operations carefully.
- Scope lifecycle notifications to the relevant context.
