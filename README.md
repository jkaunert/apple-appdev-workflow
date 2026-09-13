# Apple AppDev Workflow

Apple AppDev Workflow is a Codex Marketplace plugin for building, reviewing,
debugging, testing, and releasing Apple-platform software.

It is designed for natural-language use. A trusted `UserPromptSubmit` hook
detects broad Apple-development intent and injects the owning workflow before
the model responds. Explicit fully qualified skill invocation remains available
when hooks are disabled or restricted.

## What it provides

- Deterministic top-level routing for iOS, macOS, and Swift Package work
- Structured orchestration across architecture, implementation, testing,
  review, debugging, accessibility, and release workflows
- Plugin-owned XcodeBuildMCP with a locked portable runtime
- Direct Sosumi access for Apple documentation
- Fail-closed hook behavior with a fully qualified skill fallback
- Compatibility with Codex Desktop and plugin-capable Codex CLI hosts

The hook itself uses `/usr/bin/python3`; it does not require global Node, Malt,
Homebrew, or npm installation.

## Install

Add the marketplace:

```bash
codex plugin marketplace add jkaunert/apple-appdev-workflow --ref main
```

Then open Codex Settings → Plugins, install **Apple AppDev Workflow**, approve
the declared MCP servers, and review and trust the routing hook.

Start a new chat after installation.

## Try it

```text
Review this iOS SwiftUI project and tell me what should change first.
```

For an explicit fallback:

```text
$apple-appdev-workflow:apple-app-orchestrator Review this iOS project.
```

## Xcode companion

Xcode CodingAssistant uses a separate Codex home. If you want the same routing
behavior inside Xcode, install the separately distributed
[Apple AppDev Xcode Companion](https://github.com/jkaunert/apple-appdev-xcode-companion/releases).

The companion is optional and does not replace Xcode’s Codex agent or native
`xcode-tools` integration.

## Trust and troubleshooting

Automatic routing works only after the installed `UserPromptSubmit` hook is
trusted and enabled. If routing does not appear:

1. Open Codex hook settings.
2. Confirm the Apple AppDev Workflow hook is trusted.
3. Restart Codex and start a fresh chat.
4. Use the explicit fully qualified skill invocation if hooks are unavailable.

See the [workflow quickstart](plugins/apple-appdev-workflow/docs/WORKFLOW_QUICKSTART.md),
[capability guide](plugins/apple-appdev-workflow/docs/BUNDLE_CAPABILITIES.md),
and [MCP setup guide](plugins/apple-appdev-workflow/docs/MCP_SETUP.md).

## Release and support

The current public release is
[v0.2.2](https://github.com/jkaunert/apple-appdev-workflow/releases/tag/v0.2.2).
The optional companion `v0.2.2` build 3 is qualified for Xcode 27.0 RC
(`27A266a`) and Xcode 26.6 (`17F113`).
Release engineering and historical qualification records are maintained under
[`docs/maintainer/`](docs/maintainer/).

Report issues at
[GitHub Issues](https://github.com/jkaunert/apple-appdev-workflow/issues).
Licensed under the [Apache License 2.0](LICENSE).
