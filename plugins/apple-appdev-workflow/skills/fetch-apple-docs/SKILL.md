---
name: fetch-apple-docs
description: Fetch official Apple documentation as Markdown via Sosumi. Use for Apple API reference, Human Interface Guidelines, WWDC transcripts, Apple Developer Forums context, and external Swift-DocC pages when precise Apple platform details are needed.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Fetch Apple Docs

Use this skill to reliably fetch official Apple documentation as Markdown when coding agents need precise Apple platform details.

## Required context
- Load `../../references/fetch-apple-docs-trace-template.md` when trace-sensitive validation, route-block wording, Apple-doc path discovery, or fallback wording is in scope.

## Transport surfaces

This skill can be carried out through three transport surfaces:
- MCP-backed fetch or lookup tools
- a CLI fetcher such as `@nshipster/sosumi`
- direct HTTP to `sosumi.ai`

Those are implementation details of this skill, not separate alternative routes.
When Apple docs are needed, keep the lookup visibly routed through `apple-appdev-workflow:fetch-apple-docs` rather than manually reproducing the skill with ad hoc shell commands or generic web search.

## Trace discipline

When a calling workflow has a strict routing contract, make `apple-appdev-workflow:fetch-apple-docs` visible before the first Apple-doc lookup step appears in the trace.
For trace-sensitive validation, use the literal snippets in `../../references/fetch-apple-docs-trace-template.md` rather than improvising the route block, path-discovery line, or fallback line.
When surfacing this skill in a route block or final `Activated skills` list, use exactly `apple-appdev-workflow:fetch-apple-docs` once. Never emit `apple-appdev-workflow:apple-appdev-workflow:fetch-apple-docs`.

- If you are about to use direct Sosumi HTTP, say so as `apple-appdev-workflow:fetch-apple-docs` usage before the HTTP fetch appears.
- If you are about to use a CLI fetcher, say so as `apple-appdev-workflow:fetch-apple-docs` usage before the CLI command appears.
- If you need Apple-doc search because the exact Apple page path is still unknown, state that path-discovery reason in the immediately preceding trace step before the first search step appears.
- If you need search fallback after direct fetch proved unavailable or insufficient, state that fallback reason in the immediately preceding trace step before the first search step appears.
- Do not improvise either transition. Emit the corresponding explicit line immediately before the first search event.
- Do not rely on a final-summary `Activated skills` line to establish compliance after the lookup already happened.
- If this skill is the top-level route for the turn, make that visible with a focused-subskill route block before the first Apple-doc lookup step appears.
- If this skill is operating under an orchestrator-led workflow, feed doc evidence back to the parent flow instead of taking over the first route block or the final user-facing answer.

Focused-subskill trace shape:

```text
Routing: focused subskill
Activated skills: `apple-appdev-workflow:fetch-apple-docs`
Fetching the current Apple documentation first, then distilling the practical guidance from those sources.
```

Orchestrator-led trace shape:

```text
Routing: orchestrator-led
Activated skills: `apple-appdev-workflow:fetch-apple-docs`
Fetching the current Apple documentation first, then folding the evidence back into the parent recommendation.
```

Path-discovery search trace shape:

```text
`apple-appdev-workflow:fetch-apple-docs` still needs the exact Apple doc page path for this lookup. Using Apple-doc search to locate the canonical `developer.apple.com` page before returning to direct fetch.
```

Use that line immediately before the first search event when the Apple page path is genuinely unknown. Do not treat path discovery as a direct-fetch failure.

Fallback-to-search trace shape:

```text
`apple-appdev-workflow:fetch-apple-docs` direct fetch for the target Apple doc page was unavailable or insufficient. Falling back to Apple-doc search to locate the exact page before continuing.
```

Use that line immediately before the first search event when direct fetch was unavailable or insufficient. Do not search first and explain later.

## Default move

When the Apple page path is known or predictable, do not use generic web search.
Preferred transport order:
1. MCP-backed fetch if it is available and reliable in the current workflow.
2. Sosumi CLI fetch with a quoted Apple URL.
3. Direct HTTP to the equivalent `sosumi.ai` URL.
4. Search only to discover an unknown Apple page path.

For known or predictable Apple documentation pages, the preferred non-MCP path is the Sosumi CLI, because it is more explicit and less prone to drift into generic web-search behavior than browser search. If CLI is unavailable or failing for environment reasons, fall back to direct HTTP by converting the Apple URL to a Sosumi URL.

CLI usage:

```bash
npx -y @nshipster/sosumi fetch 'https://developer.apple.com/documentation/swift/array'
```

HTTP usage:

```text
Original
https://developer.apple.com/documentation/swift/array

AI-readable
https://sosumi.ai/documentation/swift/array
```

If the path is already known, direct host replacement remains a valid fallback path.
Search is only for cases where the documentation path is genuinely unknown.

## When to use
- Apple platform APIs: Swift, SwiftUI, UIKit, AppKit, Foundation, Combine, SwiftData, etc.
- API signatures, availability, parameter behavior, or return semantics.
- Human Interface Guidelines questions.
- WWDC session transcript lookup.
- Apple Developer Forums references when official docs are insufficient and forum context matters.
- External Swift-DocC documentation on supported hosts.

## Core workflow
1. If MCP-backed fetch is available and the lookup is straightforward, use it first.
2. If you already have a `developer.apple.com` URL, prefer `npx -y @nshipster/sosumi fetch '<apple-url>'` with the URL quoted.
3. If CLI fetch is unavailable or failing for environment reasons, replace the host with `sosumi.ai` and keep the same path.
4. If you know the framework and symbol path well enough to construct it directly, do that instead of searching.
5. If you do not know the exact page path, search the web for the correct `developer.apple.com` page first, then replace the host with `sosumi.ai` or fetch that Apple URL through the CLI.
6. Prefer specific symbol pages instead of broad top-level pages for implementation questions.
7. Keep source links in the answer so the user can verify details quickly.
8. Use Sosumi paths directly when referencing Apple documentation pages.
9. Do not satisfy this skill with generic web search results when a direct Sosumi fetch is possible.
10. A generic search like `site:sosumi.ai ...` is not a direct Sosumi fetch and should not be used as the primary path.
11. If you use HTTP or CLI to fetch Sosumi content, treat that as this skill's transport layer and surface it as `apple-appdev-workflow:fetch-apple-docs` usage in the calling workflow rather than as an unrelated shell or web step.
12. When a calling workflow has a strict routing contract, make it clear that any HTTP, CLI, or MCP fetch is being performed through `apple-appdev-workflow:fetch-apple-docs`; exact wording is not required.
13. When the exact Apple page path is genuinely unknown, emit the literal path-discovery search trace line above in the immediately preceding trace step before the first search step.
14. When you need search fallback because a direct Sosumi fetch returned 404 or sparse output, emit the literal fallback-to-search trace line above in the immediately preceding trace step before the first search step.
15. In strict-routing workflows, do not let the first Apple-doc trace event be a generic search or unlabeled Sosumi fetch. Visible activation must come first.
16. In orchestrator-led workflows, do not let this skill's answer stand in for the parent's final response. Return evidence and synthesis to the caller's summary instead.

## Shell-safe usage

If a documentation URL contains parentheses, underscores, or other shell-significant characters, quote the URL when invoking a CLI fetcher.

Example:

```bash
npx -y @nshipster/sosumi fetch 'https://developer.apple.com/documentation/packagedescription/swiftsetting/strictmemorysafety(_:)'
```

The quoting detail matters only for shell invocation. The underlying fetch path is still just the Apple URL or its Sosumi equivalent.

## Sosumi path patterns

### Apple API reference
- Pattern: `https://sosumi.ai/documentation/{framework}/{symbol}`
- Examples:
  - `https://sosumi.ai/documentation/swift/array`
  - `https://sosumi.ai/documentation/swiftui/view`

### Human Interface Guidelines
- Pattern: `https://sosumi.ai/design/human-interface-guidelines/{topic}`
- Examples:
  - `https://sosumi.ai/design/human-interface-guidelines`
  - `https://sosumi.ai/design/human-interface-guidelines/foundations/color`

### Apple video transcripts
- Pattern: `https://sosumi.ai/videos/play/{collection}/{id}`
- Examples:
  - `https://sosumi.ai/videos/play/wwdc2021/10133`
  - `https://sosumi.ai/videos/play/meet-with-apple/208`

### External Swift-DocC
- Pattern: `https://sosumi.ai/external/{full-https-url}`
- Examples:
  - `https://sosumi.ai/external/https://apple.github.io/swift-argument-parser/documentation/argumentparser/`
  - `https://sosumi.ai/external/https://swiftpackageindex.com/pointfreeco/swift-composable-architecture/1.23.1/documentation/composablearchitecture`

## Best practices
- Prefer MCP first when it is available and reliable for the needed page.
- Prefer Sosumi CLI over direct HTTP when the Apple page path is known or predictable.
- Use direct Sosumi HTTP when CLI is unavailable or failing for environment reasons.
- Search only if the exact path is unknown or a direct Sosumi fetch returns 404 or sparse output.
- Fetch targeted symbol pages for coding questions.
- Prefer official Apple docs and WWDC transcripts over secondary sources.
- Use Apple Developer Forums context only when docs alone do not resolve behavior or migration nuances.
- For PackageDescription, SwiftPM, and build-setting lookups, direct symbol-page fetches are usually better than generic search.

## Troubleshooting
- 404 or sparse output:
  - the path may be incorrect or too broad
  - in strict-routing workflows, emit the literal fallback-to-search trace line in the immediately preceding trace step before the first search event
  - if MCP was unavailable, and CLI then failed or was unavailable, direct HTTP remains valid before search when the path itself is still known
  - search the web for the correct `developer.apple.com` page
  - once you have the correct Apple page, replace `developer.apple.com` with `sosumi.ai`
  - then fetch that Sosumi URL directly or fetch the Apple URL through the CLI
- Unknown page path:
  - if you know the symbol or topic but not the exact Apple URL, emit the literal path-discovery search trace line in the immediately preceding trace step before the first search event
  - search for the canonical `developer.apple.com` page
  - once the correct Apple page is found, return to direct fetch through CLI or direct Sosumi HTTP
- External page cannot be fetched:
  - the host may block access via robots or X-Robots-Tag directives
  - try another canonical page URL for the same symbol
