# Fetch Apple Docs Trace Template

Use this template when validating or tightening `apple-appdev-workflow:fetch-apple-docs` routing behavior in trace-sensitive runs.

## Focused route block

```text
Routing: focused subskill
Activated skills: `apple-appdev-workflow:fetch-apple-docs`
Fetching the current Apple documentation first, then distilling the practical guidance from those sources.
```

## Orchestrator-led route block

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:fetch-apple-docs`
Fetching the current Apple documentation first, then folding the evidence back into the parent recommendation.
```

Use that fully qualified id exactly once when surfacing the docs specialist in a route block or final `Activated skills` list. Do not duplicate the plugin namespace.

## Path-discovery search line

```text
`apple-appdev-workflow:fetch-apple-docs` still needs the exact Apple doc page path for this lookup. Using Apple-doc search to locate the canonical `developer.apple.com` page before returning to direct fetch.
```

## Fallback-to-search line

```text
`apple-appdev-workflow:fetch-apple-docs` direct fetch for the target Apple doc page was unavailable or insufficient. Falling back to Apple-doc search to locate the exact page before continuing.
```
