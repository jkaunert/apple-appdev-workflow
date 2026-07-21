# Review Brigade Trace Template

Use this template when validating or tightening the broad branch-diff review brigade.

## First routing block

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-review-orchestrator`, `apple-appdev-workflow:apple-testing-quality-gates`, `apple-appdev-workflow:apple-review-hardening`
Reviewing the actual branch diff first, then aggregating findings, coverage gaps, and residual risk into one brigade summary.
```

Emit that block before any bundle-authored setup prose, discovery narration, or lines such as `Reviewing ...`, `Using ...`, or `I'm loading ...`. If a host/runtime kickoff sentence appears first, treat that as tolerated host noise and emit this block immediately after it.
Do not substitute generic review kickoff narration, a checklist, station-local narration, `First route: ...`, arrow-style route prose, `Review mode: ...`, or `Evidence boundary: ...` for this block. The second line must literally be an inline `Activated skills: ...` line with fully qualified plugin skill ids.
Until this block has been emitted, do not send any other bundle-authored progress update for the review lane.
For PR review-suggestion triage, Copilot/CodeRabbit suggestion validation, or
review-remediation follow-up turns, this same first routing block must appear
before `update_plan`, skill-loading narration, GitHub review-thread fetching,
or any `Using apple-appdev-workflow:...` sentence.
For direct, bounded, evidence-only inline-evidence review validation, keep the first two lines unchanged and replace only the third line with `Reviewing the provided inline evidence first, then aggregating findings, coverage gaps, and residual risk into one brigade summary.`
For direct forecast-only or routing-only validation where the user forbids file reads, shell, MCP tools, or repo inspection, keep the first two lines unchanged and replace only the third line with `Reviewing the forecast-only review request in no-op mode, then separating actual injected evidence from proposed/not-run review work.`
This forecast-only variant is intentionally self-contained; do not refuse, add a preamble, or wrap the route block in a fenced code block merely because no file reads are allowed.

## Final summary headings

```text
Routing: orchestrator-led
Activated skills
Review scope
Discovery findings
Overall assessment
Findings
Test coverage assessment
Residual risks
Recommendation
```

When the first visible output is already the final brigade summary, still emit
the compact three-line route block first, then continue into these final summary
headings. Do not use a heading-only `Activated skills` section as a substitute
for the first route block.
