# Product Surface Design Trace Template

Use this reference only for orchestrator-led, non-mutating product-surface design, review, or recommendation passes such as:
- reviewing a SwiftUI app's main product surface and recommending what should change first
- reviewing navigation, empty states, hierarchy, and on-screen copy as one coordinated surface
- recommending what should change first in a product surface without editing code

## First progress update

Use this exact shape for the first structured routing block the bundle emits for the lane. Emit it before any bundle-authored setup prose, discovery narration, or lines such as `I'm reviewing...` or `I'm editing...`. If a host/runtime build prepends one generic kickoff sentence first, treat that as host-layer noise and emit this block immediately after it:

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-product-surface-orchestrator`, `apple-appdev-workflow:apple-design-system-ux`, `apple-appdev-workflow:apple-swiftui-ui-patterns`, `apple-appdev-workflow:apple-interface-writing`
Inspecting the current product surface first, then producing a design-only recommendation that tightens hierarchy, navigation, empty states, and on-screen copy without editing code in this pass.
```

If `apple-appdev-workflow:apple-liquid-glass` is genuinely in scope, include it in the same line:

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-product-surface-orchestrator`, `apple-appdev-workflow:apple-design-system-ux`, `apple-appdev-workflow:apple-swiftui-ui-patterns`, `apple-appdev-workflow:apple-interface-writing`, `apple-appdev-workflow:apple-liquid-glass`
Inspecting the current product surface first, then producing a design-only recommendation that tightens hierarchy, navigation, empty states, copy, and style coherence without editing code in this pass.
```

Do not replace those labels with paraphrases. Do not use first-person skill narration such as `I'm using apple-design-system-ux...`. If another skill would normally lead with generic discovery or implementation narration, suppress that sentence and emit this block first.
Suppress generic bundle-authored kickoff lines such as `Reviewing...`, `I’m starting with...`, `I’ve got the project shape...`, or similar setup narration until after this block is visible.

Until this block has been emitted, do not send any other bundle-authored progress update for the lane. In particular:
- do not announce that code edits are starting
- do not narrate simulator or test execution
- do not let downstream stations surface their own interim narration first
- do not emit a generic setup or discovery sentence before the route block, even if it does not mention a skill by name

## Final summary template

Use these exact headings and keep them in this order:

```markdown
Routing: orchestrator-led

Activated skills
- `apple-appdev-workflow:apple-app-orchestrator`: ...
- `apple-appdev-workflow:apple-product-surface-orchestrator`: ...
- `apple-appdev-workflow:apple-design-system-ux`: ...
- `apple-appdev-workflow:apple-swiftui-ui-patterns`: ...
- `apple-appdev-workflow:apple-interface-writing`: ...
- `apple-appdev-workflow:apple-liquid-glass`: ...   # include only if used

Surface scope
- ...

Discovery findings
- ...

Surface assessment
- ...

Coordinated recommendations
- ...

Validation and rollout notes
- ...

Direct follow-on lanes
1. ...
2. ...
```

## Notes

- Keep this lane design-only unless the user explicitly asks to implement, edit files, or carry the recommendations into code in the same turn.
- For trace-sensitive smokes and other non-mutating validation, prefer review or recommendation wording such as `review this product surface` or `what should change first` instead of bare `redesign`.
- Do not let command narration, test execution, branch-diff review, or implementation summaries replace the brigade summary in this lane.
- Feed concrete UI issues into `Surface assessment` and the proposed redesign into `Coordinated recommendations`; do not invent alternate headings such as `Outcome`, `Implementation`, or `Tests Added Or Updated`.
- If the user later wants implementation, that is a follow-on mutating pass which must re-enter branch policy before the first edit.
- Keep the first route block product-surface-brigade-scoped, but preserve parent `apple-appdev-workflow:apple-app-orchestrator` ownership in the final `Activated skills` section.
