# Bootstrap Brigade Trace Template

Use this reference only for orchestrator-led, broad bootstrap or adoption workflows such as:
- creating a new iOS or macOS SwiftUI app scaffold
- assessing or adopting an existing Apple project or Swift package
- bootstrap plus branch and validation handoff

## First progress update

Use this exact shape for the first structured routing block the bundle emits for the lane. Emit it before any bundle-authored setup prose, discovery narration, or scaffold narration.
This requirement still applies to read-only routing smokes, no-op route audits,
and plan-only bootstrap passes. Do not prepend process narration such as "I'll
treat this as read-only" or "I'm going to load..." before the route block.

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-bootstrap-orchestrator`, `apple-appdev-workflow:apple-app-bootstrap`
Inspecting the target path, support fit, and required bootstrap inputs first, then choosing `new` or `adopt` before any generation or assessment steps.
```

If Apple docs are genuinely needed during bootstrap, include `apple-appdev-workflow:fetch-apple-docs` in the same `Activated skills:` line.

Keep this first block bootstrap-brigade-scoped. Do not include `apple-appdev-workflow:apple-app-orchestrator` in the first block even though the parent orchestrator owns the final aggregation.

Do not replace those labels with paraphrases. Keep the third line as a bootstrap discovery, input-confirmation, or preflight sentence; exact wording may vary, but it must not become `Scope:`, `Mode:`, or another custom heading. Do not let broad bootstrap work collapse directly into `apple-appdev-workflow:apple-app-bootstrap` as the first visible owner.

## Final summary template

Use these exact headings and keep them in this order:

```markdown
Routing: orchestrator-led

Activated skills
- `apple-appdev-workflow:apple-app-orchestrator`: ...
- `apple-appdev-workflow:apple-bootstrap-orchestrator`: ...
- `apple-appdev-workflow:apple-app-bootstrap`: ...
- `apple-appdev-workflow:fetch-apple-docs`: ...   # include only if used

Bootstrap scope
- ...

Discovery findings
- ...

Mode
- ...

Inputs confirmed
- ...

Preflight status
- ...

Actions taken
- ...

Files created or assessed
- ...

Git and branch handoff
- ...

Validation handoff
- ...

Recommendation
- ...
```

## Notes

- Keep this lane bootstrap-scoped unless the user explicitly asks to continue beyond bootstrap in the same turn.
- Do not let downstream architecture, design-system, accessibility, or feature-implementation stations become same-turn visible owners during broad greenfield bootstrap.
- Preserve `apple-appdev-workflow:apple-app-orchestrator` in the final `Activated skills` section as top-level owner evidence; only the first route block stays bootstrap-brigade-scoped.
- The full bootstrap brigade summary must be the first visible final output.
- For greenfield scaffolds, do not bury generated docs behind generic prose such as "created README and docs"; the final `Files created or assessed` section must include clickable links for `README.md` and `docs/HARNESS_HANDOFF.md`.
