# Persistence Design Trace Template

Use this reference only for orchestrator-led, non-mutating persistence design passes such as SwiftData schema, migration, or storage-boundary recommendations.

## First progress update

Use this exact shape for the first structured routing block the bundle emits for the lane. Emit it before any bundle-authored setup prose, discovery narration, or lines such as `I'm treating this as...`. If a host/runtime build prepends one generic kickoff sentence first, treat that as host-layer noise and emit this block immediately after it:

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-persistence-orchestrator`, `apple-appdev-workflow:apple-discovery-first`, `apple-appdev-workflow:apple-swiftdata-foundations`
Inspecting the current app structure and persistence seams first, then shaping a design-only model and migration plan that fits the existing codebase.
```

If current Apple docs are needed immediately, include `apple-appdev-workflow:fetch-apple-docs` in the same line:

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-persistence-orchestrator`, `apple-appdev-workflow:apple-discovery-first`, `apple-appdev-workflow:apple-swiftdata-foundations`, `apple-appdev-workflow:fetch-apple-docs`
Inspecting the current app structure and persistence seams first, then confirming the relevant SwiftData API surface before locking the design.
```

Do not replace those labels with paraphrases. Do not use first-person skill narration such as `I'm using Apple Discovery First...`. If another skill would normally lead with a generic discovery sentence, suppress that sentence and emit this block first. A host-inserted generic kickoff sentence is tolerated only when this block still appears immediately after it.

## Apple-doc fallback trace

If a direct `apple-appdev-workflow:fetch-apple-docs` lookup fails or returns an unhelpful page, use an explicit fallback line immediately before the first search step:

```text
`apple-appdev-workflow:fetch-apple-docs` direct fetch for the target SwiftData page was unavailable or insufficient. Falling back to Apple-doc search to locate the exact page before continuing.
```

Use that trace only when a fallback really happened.

## Final summary template

Use these exact headings and keep them in this order:

```markdown
Routing: orchestrator-led

Activated skills
- `apple-appdev-workflow:apple-app-orchestrator`: ...
- `apple-appdev-workflow:apple-persistence-orchestrator`: ...
- `apple-appdev-workflow:apple-discovery-first`: ...
- `apple-appdev-workflow:apple-swiftdata-foundations`: ...
- `apple-appdev-workflow:fetch-apple-docs`: ...   # include only if used

Design scope
- ...

Discovery findings
- ...

Recommended design
- ...

Migration and rollout implications
- ...

Risks
- ...

Next implementation entry points
1. ...
2. ...
```

## Notes

- Keep this lane design-only unless the user explicitly asks to scaffold or implement code.
- Feed SwiftData-specific advice into `Recommended design` and `Migration and rollout implications`; do not invent a specialist-owned final heading such as `Recommended Shape`.
- If no Apple docs were consulted, omit `apple-appdev-workflow:fetch-apple-docs` from `Activated skills`.
- Keep the first route block persistence-brigade-scoped, but preserve parent `apple-appdev-workflow:apple-app-orchestrator` ownership in the final `Activated skills` section.
