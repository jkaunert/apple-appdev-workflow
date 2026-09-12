# MCP setup

This guide covers the MCP surface delivered by the installed Marketplace
profile. Most users only need to install the plugin, approve its servers, and
start a new chat.

## Included servers

- `sosumi` — Apple documentation search and retrieval
- `apple-appdev-xcodebuildmcp` — plugin-owned XcodeBuildMCP workflows for
  project, simulator, macOS, and Swift Package work

The plugin uses a locked portable XcodeBuildMCP runtime. Its routing hook uses
macOS `/usr/bin/python3`; global Node, npm, Malt, Homebrew, and a global
`xcodebuildmcp` command are not required.

Native Codex memory remains host-controlled. This release does not install a
Memory MCP.

## Install and approve

After installing the Marketplace plugin, open Codex MCP settings and approve
the requested servers. Confirm that both names above appear as enabled, then
restart Codex and start a fresh chat.

Do not add a second copy of these servers with `codex mcp add`; duplicate
registrations can create competing runtimes and misleading tool inventories.

## First use

The first XcodeBuildMCP request may take a little longer while the plugin-owned
runtime is provisioned. The launcher verifies the locked release before making
it available and reuses the installed copy for later requests.

## Xcode

The Marketplace profile is for ordinary Codex Desktop, CLI, and compatible IDE
hosts. Xcode CodingAssistant has a separate Codex home and uses Xcode’s native
`xcode-tools` provider. Install the optional signed
[Xcode companion](https://github.com/jkaunert/apple-appdev-xcode-companion/releases)
for hook-native routing inside Xcode; the companion does not install MCP
servers.

## Public portal profile

The `public-portal` profile intentionally declares no bundled MCP servers. That
profile relies on the host’s native Xcode tools or its documented CLI fallback;
the absence of MCP entries there is expected.

## Troubleshooting

**The servers are missing.** Reopen the plugin installation flow, approve the
requested MCP configuration, restart Codex, and check `codex mcp list` again.

**XcodeBuildMCP starts slowly or fails once.** Retry after the first-use
provisioning completes. If it still fails, report the exact error and host
version rather than installing a global replacement; the locked runtime is the
release path.

**Automatic routing is missing.** Open hook settings and trust the Apple AppDev
Workflow `UserPromptSubmit` hook, then restart Codex and start a fresh chat. If
hooks are unavailable, use the explicit fallback:

```text
$apple-appdev-workflow:apple-app-orchestrator Review this Apple project.
```

**Memory recall differs between hosts.** Native memory is controlled by the
active Codex home. Required project and release facts should remain in the
project’s checked-in documentation.
