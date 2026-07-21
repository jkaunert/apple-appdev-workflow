# Brigade Output Contract

Use this shared contract for broad brigade-orchestrator lanes. It does not
replace lane-specific trace templates, required section lists, or station
activation rules.

## Shared Rules

1. The final user-facing brigade summary starts with `Routing: orchestrator-led`.
2. The first bundle-authored structured route block appears before setup prose,
   discovery narration, severity cards, findings, blocker bullets, tool logs,
   task-plan updates, skill-loading narration, or station-local wrap-up text.
   If the host/runtime already emitted one generic kickoff sentence, treat it
   as host noise and emit the route block immediately after it.
   The first route block is always a compact three-line block: line 1 is
   `Routing: orchestrator-led`, line 2 is an inline `Activated skills: ...`
   list containing fully qualified plugin skill ids, and line 3 is the lane
   context sentence. Do not use an `Activated skills` heading plus bullets as
   the first route block; that shape is reserved for the final summary section
   after the compact route block has already appeared.
3. The brigade summary is the final answer. Supporting shell output, work logs,
   screenshots, station findings, or transient progress narration must be
   collapsed into the lane's required sections.
4. Use the exact lane-specific section labels and order declared by the active
   orchestrator or trace template. A partial wrap-up is incomplete even when its
   substance is correct.
5. `Activated skills` uses fully qualified plugin skill ids without `$`, for
   example `apple-appdev-workflow:apple-review-orchestrator`. Include
   `apple-appdev-workflow:apple-app-orchestrator` in final summaries for broad
   parent-owned work, include the active domain orchestrator, and include each
   station that materially shaped the result.
6. Downstream stations return evidence upward. They do not replace the domain
   brigade or parent orchestrator as the final narrator.
7. Prompt/control-plane invocation examples may use
   `$apple-appdev-workflow:<skill>`, but route blocks, final summaries, scoring
   artifacts, and model-visible evidence use `apple-appdev-workflow:<skill>`.

## Completion Test

A broad brigade answer is incomplete when it omits a required section, omits a
required visible owner from final `Activated skills`, starts with free-form
prose instead of the lane route block, or lets raw logs/station-local findings
stand in for the required brigade summary. When the final summary is also the
first visible output, it must still begin with the compact three-line route
block before the final summary's `Activated skills` section.
