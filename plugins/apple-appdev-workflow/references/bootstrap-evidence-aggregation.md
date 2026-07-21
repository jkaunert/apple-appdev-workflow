# Bootstrap Evidence Aggregation

Broad bootstrap outputs should aggregate discovery, preflight, and handoff evidence instead of listing raw commands or script output.

## Required sections

Broad bootstrap workflows must end with:
1. `Activated skills`
2. `Bootstrap scope`
3. `Discovery findings`
4. `Mode`
5. `Inputs confirmed`
6. `Preflight status`
7. `Actions taken`
8. `Files created or assessed`
9. `Git and branch handoff`
10. `Validation handoff`
11. `Recommendation`

## What belongs in each section

### Activated skills
- name `apple-appdev-workflow:apple-app-orchestrator` as the top-level owner for orchestrator-led broad bootstrap work
- name `apple-appdev-workflow:apple-bootstrap-orchestrator`
- name `apple-appdev-workflow:apple-app-bootstrap`
- include only the additional downstream skills that actually shaped the result
- use fully qualified plugin skill ids for every bundle-contributed entry in this block
- if `apple-appdev-workflow:apple-app-orchestrator` is omitted from an orchestrator-led final summary, the bootstrap workflow is incomplete
- if `apple-appdev-workflow:apple-bootstrap-orchestrator` is omitted, the bootstrap workflow is incomplete
- do not reduce broad bootstrap work to `apple-appdev-workflow:apple-app-orchestrator` plus `apple-appdev-workflow:apple-app-bootstrap` only
- if Apple docs were consulted, name `apple-appdev-workflow:fetch-apple-docs` here as `apple-appdev-workflow:fetch-apple-docs` and ensure the earlier trace already made that skill visible before the first Apple-doc lookup step
- if Apple-doc search fallback was used, ensure the earlier trace stated the fallback reason in the immediately preceding step before the first search event; do not let the final summary paper over a late explanation

### Bootstrap scope
- say whether this is new app creation, project adoption, package adoption, assessment-only, or bootstrap plus follow-on work

### Discovery findings
- summarize the real local context that shaped the route
- include target-path state, repo state, support-matrix fit, and project-shape or package-shape signals when relevant
- include the effective working root when the shell directory differs from the real repo or package root

### Mode
- state `new` or `adopt`

### Inputs confirmed
- show scaffold-critical inputs or adopt-critical path targets
- make missing values explicit

### Preflight status
- say whether doctor or preflight passed, is pending, or could not run yet

### Actions taken
- summarize what actually happened
- avoid command transcripts

### Files created or assessed
- say what was scaffolded, analyzed, or intentionally left untouched
- for `new` scaffolds, include clickable links to generated `README.md` and `docs/HARNESS_HANDOFF.md` using the real scaffold output paths, absolute path targets, and optional `:1` line anchors so the Electron UI exposes the generated docs as openable outputs

### Git and branch handoff
- make branch state and next branch expectation explicit
- for standalone scaffolds, name the applied repository policy and the next required topic-branch step before feature work
- for standalone scaffolds, name the forge provider when known so follow-on
  work uses the correct pull-request or merge-request language
- if `legacy-codex-dev` was selected, say whether `dev` and `codex/dev` were initialized

### Validation handoff
- state whether `XcodeBuildMCP`, MCP `swift_package_*` workflows, architecture, design, implementation, or testing skills own the next phase

### Recommendation
- say whether bootstrap is complete, blocked on missing inputs, assessment-only, or ready for downstream work
- if the branch model is not yet ready for feature work, state that explicitly instead of implying the scaffold is fully ready
- recommend a host app or workspace only when the next requested phase needs app-specific runtime, UI automation, or release behavior

## Incomplete pass rule

If any required section is omitted, the bootstrap workflow is incomplete.
If `Routing: orchestrator-led` is missing, or `Activated skills` omits `apple-appdev-workflow:apple-app-orchestrator`, `apple-appdev-workflow:apple-bootstrap-orchestrator`, or `apple-appdev-workflow:apple-app-bootstrap`, the bootstrap workflow is incomplete.
If the first route block is a hybrid parent/domain block that omits `apple-appdev-workflow:apple-app-bootstrap`, includes `apple-appdev-workflow:apple-app-orchestrator`, or replaces the bootstrap discovery, input-confirmation, or preflight sentence with `Scope:` or other custom heading prose, the bootstrap trace is incomplete even when the final summary later names the right skills.
The full bootstrap brigade summary must be the first visible final output; do not prepend freeform scaffold wrap-up prose or headings such as `Result` before `Routing`.
