# Architecture Assessment Trace Template

Use this reference for orchestrator-led, non-mutating architecture or app-structure assessments such as:
- assessing an app's current architecture
- evaluating whether package or module boundaries are real
- recommending what should change first in app structure or dependency flow

## First progress update

Use this exact shape for the first structured routing block the bundle emits for the lane. Emit it before any bundle-authored setup prose, discovery narration, or lines such as `I'm reviewing...` or `I'm using...`. If a host/runtime build prepends one generic kickoff sentence first, treat that as host-layer noise and emit this block immediately after it:

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-architecture-orchestrator`, `apple-appdev-workflow:apple-discovery-first`, `apple-appdev-workflow:apple-architecture-design`
Inspecting the current app structure, ownership seams, and dependency flow first, then identifying the highest-leverage architectural change to make next.
```

Do not replace those labels with paraphrases. Do not use first-person skill narration such as `I'm using apple-discovery-first...`. If another skill would normally lead with a generic discovery sentence, suppress that sentence and emit this block first. A host-inserted generic kickoff sentence is tolerated only when this block still appears immediately after it.
Do not substitute a line such as `Using ...` or a checkmark-style progress list for this block.
Do not substitute generic architecture kickoff narration such as `I'm assessing the SwiftUI app's current architecture...`, `I'm starting by loading the architecture review skill...`, or `I'm starting with project discovery...`. Those are bundle-authored route failures, not tolerated setup text.

Until this block has been emitted, do not send any other bundle-authored progress update for the lane. In particular:
- do not emit exploratory summaries such as `I found a very small Apple app...`
- do not narrate current-state findings before the routing block
- do not report that tests or builds are running before the routing block
- do not let downstream discovery or architecture stations surface their own interim narration first

After the first routing block is visible, later progress updates may continue normally.

## Final summary template

Use these exact headings and keep them in this order:

```markdown
Routing: orchestrator-led

Activated skills
- `apple-appdev-workflow:apple-app-orchestrator`: ...
- `apple-appdev-workflow:apple-architecture-orchestrator`: ...
- `apple-appdev-workflow:apple-discovery-first`: ...
- `apple-appdev-workflow:apple-architecture-design`: ...
- `apple-appdev-workflow:apple-swiftdata-foundations`: ...   # include only if used
- `apple-appdev-workflow:apple-swift-concurrency-foundations`: ...   # include only if used
- `apple-appdev-workflow:apple-swift-concurrency-review`: ...   # include only if used
- `apple-appdev-workflow:apple-swift-testing-foundations`: ...   # include only if used
- `apple-appdev-workflow:fetch-apple-docs`: ...   # include only if used
- `apple-appdev-workflow:apple-decision-stress-test`: ...    # include only if used

Assessment scope
- ...

Discovery findings
- ...

What Should Change First
- ...

Recommended follow-on structure
- ...

Risks
- ...

Next implementation entry points
1. ...
2. ...
```

## Notes

- Keep this lane assessment-only unless the user explicitly asks to implement changes.
- Broad architecture prompts should route through `apple-appdev-workflow:apple-architecture-orchestrator`; `apple-appdev-workflow:apple-discovery-first` and `apple-appdev-workflow:apple-architecture-design` feed evidence upward inside that brigade.
- Keep the first route block architecture-brigade-scoped, but preserve parent `apple-appdev-workflow:apple-app-orchestrator` ownership in the final `Activated skills` section.
- When an `.xcodeproj` or `.xcworkspace` is present, use `XcodeBuildMCP` as the default control plane for project discovery, scheme listing, and test execution in this lane. Treat raw `xcodebuild` as fallback-only, and call out any MCP availability gap explicitly before falling back.
- Feed findings into `Discovery findings` and the main recommendation into `What Should Change First`; do not replace the final answer with standalone `P1` or `P2` finding cards.
- This lane is intentionally not a branch-diff review. If the user truly wants a code review, route that through the review brigade instead.
