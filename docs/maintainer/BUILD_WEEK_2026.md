# Build Week 2026 retrospective

This is historical maintainer context, not installation or usage guidance.

## Why the project exists

Apple development in Codex benefits from clear ownership, specialized workflow
stations, disciplined handoffs, and explicit escalation. Apple AppDev Workflow
adapts that brigade model to a deterministic Codex plugin so broad requests can
be routed without requiring users to understand the internal skill graph.

## What the release work established

- a trusted, fail-closed `UserPromptSubmit` router for natural Apple prompts and
  explicit plugin or skill invocations
- deterministic top-level owner injection with negative, resume, and
  post-compaction coverage
- removal of the fork-only `routerSelection` dependency from the product path
- authored macOS and Swift Package prompt provenance
- plugin-owned XcodeBuildMCP with a locked portable runtime
- a separate hook-only Xcode companion for Xcode CodingAssistant

## Public release boundary

The public Marketplace repository contains generated distribution material, not
the private development history or harness control plane. The companion is a
separate signed distribution and does not own Marketplace MCP servers or
Xcode’s native tool provider.

Current releases:

- [Marketplace plugin v0.2.2-beta.1](https://github.com/jkaunert/apple-appdev-workflow/releases/tag/v0.2.2-beta.1)
- [Xcode companion v0.2.2-beta.1](https://github.com/jkaunert/apple-appdev-xcode-companion/releases/tag/v0.2.2-beta.1)
