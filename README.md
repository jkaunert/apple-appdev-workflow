# Apple AppDev Workflow

Apple AppDev Workflow is a Codex Marketplace plugin for building, reviewing,
debugging, and releasing iOS and macOS apps. Its primary interface is broad,
natural language—not manual skill selection. Its defining behavior is
deterministic, pre-sampling top-level routing: a trusted `UserPromptSubmit`
hook infers the intent of an Apple-development request and injects the owning
workflow before the model responds.

Version `0.2.0` runs that routing path on stock Codex without the retired
fork-only `routerSelection` carry. Fully qualified skill invocation remains the
explicit fallback when hooks are disabled, declined, changed, or restricted.

## OpenAI Build Week 2026

### Why I built it

I already really enjoyed the general Codex experience. The frustration was
specific to Apple development: workflows would drift, ambiguity was resolved
poorly, and context was easy to lose across a large codebase or several repos
and worktrees. Even when the individual answers were useful, the overall effort
could feel disjointed and unfocused.

I had experimented with orchestration frameworks such as crewAI the previous
year, but the models were not yet capable enough to deliver the full promise. I
also knew a very different orchestration system firsthand. I have worked in
commercial kitchens, trained formally in culinary arts, and owned and operated
a successful establishment. Escoffier's *brigade de cuisine* gave me the idea:
clear ownership, specialized stations, disciplined handoffs, and escalation
might also be an effective way to coordinate a multi-skill workflow in Codex.

Apple AppDev Workflow is my attempt to adapt that insight into a deterministic
orchestration harness for end-to-end Apple-platform development. It is not the
complete expression of the idea, but it is a promising first result.

### Natural language is the control surface

The user does not have to understand the routing graph or decide which skill
owns a broad request. A prompt such as:

```text
Review this iOS app and tell me if it is ready for release.
```

is enough. Before model output begins, the trusted deterministic hook recognizes
the broad Apple intent and assigns the top-level owner. That owner grounds the
turn in the real project, resolves the release-readiness intent, and coordinates
the release workflow and its required review, testing, manual-validation, and
release-operations stations. Explicit skill invocation exists as a reliable
fallback; it is not the normal user experience.

### What changed during Build Week

The project existed before the Build Week submission period. Most of its
experimental development used GPT-5.5. The work submitted for Build Week is the
release-defining extension completed after July 13, 2026:

- a trusted, fail-closed `UserPromptSubmit` router for natural Apple prompts and
  plugin or skill invocations
- explicit routing policy, top-level owner injection, negative cases, resume
  behavior, and post-compaction behavior
- removal of the fork-only router-selection dependency from the product path
- a 12-case signed stock Codex Desktop routing matrix
- a separate 9-case live Xcode CodingAssistant compatibility matrix
- public-release gates, a clean Git Marketplace distribution, and the published
  `v0.2.0` release

The private qualification source records 25 post-cutoff commits (21 non-merge
commits). Relative to its pre-window baseline, that train changed 79 files with
10,499 insertions and 1,004 deletions. The public artifact maps back to exact
private source commit `c30409e917a5bcdb02010c0b78b4971c2b3fa42a` and public
release commit `c3702d917fedaa6674a750695d3173e36d714522` in the
[release provenance](docs/RELEASE_PROVENANCE.md).

### How Codex, GPT-5.5, and GPT-5.6 were used

Most of the exploratory product development happened in Codex with GPT-5.5.
Later in Build Week, I used the experimental plugin itself with GPT-5.6 for the
more expensive release task: replace the custom-runtime routing dependency,
coordinate work across the private source and clean public release, qualify the
result in stock Codex, and publish `v0.2.0`. I would not have attempted that
release train with GPT-5.5; GPT-5.6 handled the long context, ambiguity, and
cross-repository coordination with relative ease.

The primary GPT-5.6 Codex thread preserved the path from product decisions
through repository archaeology, implementation, hostile-input testing,
stock-host validation, carry-removal analysis, release gates, documentation,
and public packaging. The human-owned decisions remained explicit:
deterministic pre-sampling ownership was non-negotiable; hooks had to fail
closed when trust was unavailable; explicit skill invocation had to remain a
safe fallback; and Desktop, Xcode, private-harness, and public-distribution
evidence could not be blended into one claim.

Primary Codex session ID:
`019f6e9b-331e-7e62-b7fc-85340818ae86`.

Qualification recorded 17 hook-router tests and 110 plugin-contract tests. The
12-case Desktop run used an earlier package whose four routing payloads are
byte-for-byte identical to `v0.2.0`; a fresh public `v0.2.0` install separately
proved Marketplace registration, app-server read and install, runtime
provisioning, and plugin-owned MCP attribution. The Xcode 9/9 result is
host-compatibility evidence and is not presented as Marketplace-distribution
evidence.

## Install

Add this Git marketplace with a plugin-capable Codex CLI:

```bash
codex plugin marketplace add jkaunert/apple-appdev-workflow --ref main
```

Then open Codex Settings, choose Plugins, find **Apple AppDev Workflow by
Joshua Kaunert**, and install **Apple AppDev Workflow**. Review and trust the
routing hook, and approve the plugin-declared MCP servers when Codex asks.

Start a fresh chat after installation. A broad natural request such as
`Review this iOS app and tell me if it is ready for release` should infer intent
and route automatically. The explicit fallback is:

```text
$apple-appdev-workflow:apple-app-orchestrator Review this iOS app and tell me if it is ready for release.
```

The bundle declares `sosumi`, `memory`, and `XcodeBuildMCP` in its plugin-owned
MCP configuration. Node.js and npm are needed when those npm-backed MCP tools
are materialized.

## What Ships Here

- the exact qualified `0.2.0` Marketplace profile under
  `plugins/apple-appdev-workflow/`
- deterministic natural-prompt and textual-chip routing through the plugin hook
- explicit fully qualified skill invocation as a security-boundary fallback
- Apple workflow skills, references, assets, and plugin-owned MCP declarations

The Xcode CodingAssistant companion is compatible with the same routing
payload but uses a separate signed provisioning envelope. It is intentionally
not included in this Marketplace repository or the `0.2.0` Marketplace
artifact.

## Trust Boundary

Automatic routing depends on Codex accepting the installed plugin's hook. If
the hook is untrusted, disabled, modified, or blocked by policy, automatic
injection must fail closed; use an explicit
`$apple-appdev-workflow:<skill>` invocation instead.

See [release provenance](docs/RELEASE_PROVENANCE.md), the
[privacy policy](docs/PRIVACY_POLICY.md), and the
[terms of service](docs/TERMS_OF_SERVICE.md).

## Support and License

Use [GitHub Issues](https://github.com/jkaunert/apple-appdev-workflow/issues)
for public support. The plugin is licensed under the
[Apache License 2.0](LICENSE).
