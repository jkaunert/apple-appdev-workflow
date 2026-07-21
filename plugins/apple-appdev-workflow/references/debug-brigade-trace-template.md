# Debug Brigade Trace Template

Use this template when validating or tightening the broad runtime-debug brigade.

## First routing block for iOS

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-debug-orchestrator`, `apple-appdev-workflow:apple-runtime-debugger-ios`
Reproducing the issue first, then collapsing runtime evidence, likely cause, and the next diagnostic step into one brigade summary.
```

## First routing block for macOS

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:apple-debug-orchestrator`, `apple-appdev-workflow:apple-runtime-debugger-macos`
Reproducing the issue first, then collapsing runtime evidence, likely cause, and the next diagnostic step into one brigade summary.
```

## Final summary headings

```text
Routing: orchestrator-led
Activated skills
Debug scope
Reproduction status
Discovery findings
Evidence reviewed
Likely root cause
Validation gaps
Next diagnostic step
Recommended fix path
Residual risks
```

## Final `Activated skills` expectations

- In lane-local acceptance, preserve `apple-appdev-workflow:apple-debug-orchestrator` in the final summary and prove the parent app owner through the invocation envelope.
- In full app-orchestrated transcripts, preserve both `apple-appdev-workflow:apple-app-orchestrator` and `apple-appdev-workflow:apple-debug-orchestrator` in the final summary.
- Include at least one runtime debugger station: `apple-appdev-workflow:apple-runtime-debugger-ios` or `apple-appdev-workflow:apple-runtime-debugger-macos`.
- Include `apple-appdev-workflow:apple-testing-quality-gates` only when validation evidence materially shaped the pass; it is not a runtime-station replacement.
