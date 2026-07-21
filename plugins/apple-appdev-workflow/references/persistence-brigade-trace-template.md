# Persistence Brigade Trace Template

Use this reference for the persistence brigade.

This template defines the first visible route block and the final section order for broad, non-mutating persistence review and recommendation passes under `apple-appdev-workflow:apple-persistence-orchestrator`.

## First progress update

Use this exact shape for the first structured routing block the bundle emits for this lane. Emit it before any bundle-authored setup prose, discovery narration, or lines such as `I'm treating this as...`. If a host/runtime build prepends one generic kickoff sentence first, treat that as host-layer noise and emit this block immediately after it:

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-persistence-orchestrator`, `apple-appdev-workflow:apple-swiftdata-foundations`
Inspecting the current persistence seams first, then producing a design-only persistence review that prioritizes migration and rollout risk.
```

If current Apple docs are needed immediately, include `apple-appdev-workflow:fetch-apple-docs` in the same line:

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-persistence-orchestrator`, `apple-appdev-workflow:apple-swiftdata-foundations`, `apple-appdev-workflow:fetch-apple-docs`
Inspecting the current persistence seams first, then confirming the relevant Apple persistence APIs before locking the recommendation.
```

Do not replace those labels with paraphrases. Do not use first-person skill narration. If another station would normally lead with a generic discovery sentence, suppress that sentence and emit this block first.

## Apple-doc fallback trace

If a direct `apple-appdev-workflow:fetch-apple-docs` lookup fails or returns an unhelpful page, use an explicit fallback line immediately before the first search step:

```text
`apple-appdev-workflow:fetch-apple-docs` direct fetch for the target persistence page was unavailable or insufficient. Falling back to Apple-doc search to locate the exact page before continuing.
```

## Final summary template

Use these exact headings and keep them in this order:

```markdown
Routing: orchestrator-led

Activated skills
- `apple-appdev-workflow:apple-app-orchestrator`: ...
- `apple-appdev-workflow:apple-persistence-orchestrator`: ...
- `apple-appdev-workflow:apple-swiftdata-foundations`: ...
- `apple-appdev-workflow:apple-swiftdata-review`: ...     # include only if used
- `apple-appdev-workflow:apple-core-data-expert`: ...     # include only if used
- `apple-appdev-workflow:fetch-apple-docs`: ...           # include only if used

Persistence scope
- ...

Discovery findings
- ...

Persistence assessment
- ...

Coordinated recommendations
- ...

Migration and rollout notes
- ...

Direct follow-on lanes
1. ...
2. ...
```

## Notes

1. Keep this lane non-mutating for trace-sensitive review and recommendation prompts unless the user explicitly asks to implement.
2. The persistence brigade owns the final answer, but final `Activated skills` must also preserve parent `apple-appdev-workflow:apple-app-orchestrator` ownership.
3. This template supersedes station-owned persistence trace ownership once the brigade is activated.
4. When current Apple persistence docs are needed, prefer `apple-appdev-workflow:fetch-apple-docs` before generic web search or raw `developer.apple.com` search.
