# MCP Setup

Use this bundle's MCP metadata so the Apple workflow can reach its external tools.

## Included MCPs

- `sosumi` for Apple-doc MCP fetch/search
- `XcodeBuildMCP` for Xcode integration
- `memory` for durable workflow context

The current bundle setup standardizes on Node/npm-backed launch paths for all
three MCPs.

The active `sosumi` endpoint is declared in `.mcp.json`. That file uses the
official direct server-map shape documented for bundled Codex plugin MCP
servers. Use it as the source of truth if your Codex install asks you to review
or grant MCP server configuration.

## Marketplace install

Marketplace installs should use the plugin-declared MCP server configuration in `.mcp.json`. After installing the plugin, open the Codex MCP servers settings and confirm these servers are connected:

- `sosumi`
- `XcodeBuildMCP`
- `memory`

If the UI reports no MCP servers, the plugin has not been granted or materialized its MCP configuration yet. Reopen the plugin install flow, grant the requested MCP setup, then restart Codex.

## Local CLI runtime

For source checkouts or manual local testing, install the pinned CLI runtime
first:

```bash
cd /path/to/apple-appdev-workflow
bash ./codex-cli/setup-plugin-runtime.sh
```

Verify the pinned local runtime:

```bash
cd /path/to/apple-appdev-workflow
bash ./codex-cli/verify-plugin-runtime.sh
```

That installs the local CLI surface under
`~/.codex/plugin-runtime/apple-appdev-workflow/node_modules/.bin` for:

- `sosumi`
- `xcodebuildmcp`
- `xcodebuildmcp-doctor`
- `mcp-server-memory`
- `mcp-remote`
- `mcp-proxy`

The pinned runtime dependencies are declared in `package.json`. Rerun setup
after updating package metadata.

Before packaging or installing a refreshed runtime into a host-specific Codex
home, run:

```bash
npm audit --omit=dev
```

If the audit is fixed by safe transitive updates, prefer
`npm audit fix --omit=dev --package-lock-only` first so direct dependency pins
remain explicit. After changing `package-lock.json`, reinstall any host-specific
runtime copy, such as the Xcode CodingAssistant proxy runtime, from the updated
lockfile.

## Persistent Xcode MCP proxy

`codex-cli/xcode-mcp-proxy-manager.sh` provides an opt-in workaround for hosts
where Codex opens and closes `xcrun mcpbridge` on every request. The manager
keeps one local `mcp-proxy` process running in front of `xcrun mcpbridge` and
exposes it at `http://127.0.0.1:9876/mcp`.

On macOS, `start` uses a user LaunchAgent by default so the proxy survives the
noninteractive shell that launched it. Set `XCODE_MCP_PROXY_LAUNCH_MODE=direct`
only when you explicitly want a direct background process instead of launchd.

Use it only for source-checkout or fork-local validation; marketplace installs
should continue to use `.mcp.json` unless a host-specific Xcode bridge defect is
being diagnosed.

```bash
cd /path/to/apple-appdev-workflow
bash ./codex-cli/xcode-mcp-proxy-manager.sh start
bash ./codex-cli/xcode-mcp-proxy-manager.sh status
```

To register the proxy in the active Codex home:

```bash
bash ./codex-cli/xcode-mcp-proxy-manager.sh codex-register
```

To roll back to the direct native Xcode bridge:

```bash
bash ./codex-cli/xcode-mcp-proxy-manager.sh codex-rollback
```

### Xcode CodingAssistant home

Xcode uses its own Codex home at
`~/Library/Developer/Xcode/CodingAssistant/codex`. That home may expose Xcode's
built-in direct `xcode-tools` MCP entry even when the fork-local Codex home is
already using `xcode-proxy`.

Treat this as the `xcode-headless` host-maintenance surface. It is not
marketplace evidence, fork-extended product evidence, or GUI smoke evidence.
Before changing any Xcode CodingAssistant registration, run the read-only
preflight:

```bash
python3 ./scripts/check_xcode_headless_surface.py --repo-root .
```

That checker reports whether `xcode-tools` is command-backed, whether the
separate `xcode-proxy` entry is present, whether the plugin-review guard is in
place, whether `XcodeBuildMCP` appears in the Xcode home, and whether live
processes suggest duplicate automation owners, desktop/fork-extended overlap,
or transient-launcher TCC prompt risk. It does not edit `config.toml`, register
MCP servers, restart app-server, or run the deep native bridge probe.

After the surface check is clean, use the Xcode-headless routing matrix when
the question is whether plugin routing, explicit skill invocation, or
deterministic top-level owner selection is working inside Xcode CodingAssistant:

```bash
uv run python ./scripts/check_xcode_headless_routing_smoke.py --print-prompts
```

Run the prompts in fresh Xcode CodingAssistant chats, paste each answer into a
text file, then score it with the matching scenario id. This matrix is manual
`xcode-headless` evidence only; it does not replace desktop GUI, marketplace,
remote-control, or public-release smokes.

For unattended or AFK Xcode automation, use the stricter prompt gate before
starting a long-running smoke. The gate fails when live process state can
trigger either of the observed interactive prompts: Xcode's external-agent
authorization for `mcp-proxy`, or XCTest's "Enable UI Automation" password
prompt.

```bash
python3 ./scripts/check_xcode_headless_surface.py \
  --repo-root . \
  --require-afk-safe
```

After approving the relevant prompts for that host run, make the acknowledgement
explicit:

```bash
python3 ./scripts/check_xcode_headless_surface.py \
  --repo-root . \
  --require-afk-safe \
  --acknowledge-xcode-proxy-auth \
  --acknowledge-xctest-ui-automation
```

The proxy manager exposes the same gate with the Xcode CodingAssistant home
already selected:

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-afk-preflight \
  --acknowledge-xcode-proxy-auth \
  --acknowledge-xctest-ui-automation
```

Treat the `XcodeBuildMCP` warning source as part of the diagnosis. A
`xcodebuildmcp_config_entry` warning means Xcode's `config.toml` directly
declares `XcodeBuildMCP`, so config rollback or removal can be the right local
fix. A `xcodebuildmcp_plugin_exposure` warning means `codex mcp list` sees
`XcodeBuildMCP` through plugin-managed `.mcp.json` metadata under Xcode's Codex
home, not through `config.toml`; `codex mcp remove XcodeBuildMCP` is not the
right remediation for that case. Use an Xcode-specific plugin/profile
containment path, or document the residual overlap, rather than globally
removing `XcodeBuildMCP` from the desktop/fork-local plugin surface.

Live-process warnings are separate from static Xcode-home exposure. A
`desktop_xcodebuildmcp_process_visible` or
`desktop_xcodebuildmcp_xcode_bridge_overlap` warning means the checker found
live `XcodeBuildMCP` processes owned by a CodexFork desktop app-server while
Xcode's config, MCP list, and plugin cache do not expose `XcodeBuildMCP`.
Treat that as cross-surface process overlap from the desktop or fork-extended
surface. Do not remediate it by editing Xcode's `config.toml`; decide
separately whether the desktop/remote app should keep the full Apple validation
tool surface or use a stripped remote profile.

For plugin-cache-backed exposure from this bundle, render and install the
skill-only Xcode profile instead of editing the desktop plugin manifest:

```bash
python3 ./scripts/install_xcode_headless_profile.py \
  --repo-root . \
  --quarantine-build-ios-apps
```

The installer validates an `xcode-headless` artifact, backs up the current
Xcode-home `apple-appdev-workflow` cache entry under
`~/Library/Developer/Xcode/CodingAssistant/codex/.tmp/plugins/quarantine/`,
installs the carry-free profile while omitting `.mcp.json` and `mcpServers`,
and can optionally move the stock
`build-ios-apps` temp plugin aside. Use `--dry-run` first when diagnosing an
unfamiliar host.

Marketplace installation already carries default plugin hooks and MCP metadata
for supported Codex plugin surfaces. It does not expose an arbitrary
post-install lifecycle for mutating Xcode's separate CodingAssistant home;
npm-backed plugin sources are downloaded without package lifecycle scripts.
Until Xcode exposes a supported shared marketplace surface, distribute the same
portable routing payload through a separate explicit, signed Xcode provisioning
envelope rather than a hidden hook side effect.

Xcode or Codex updates can repopulate the stock `build-ios-apps` temp plugin
after a previously clean install. That plugin declares `xcodebuildmcp` through
its own `.mcp.json`, so the Xcode-headless checker treats an active
`.tmp/plugins/plugins/build-ios-apps/.mcp.json` as a failed clean-surface gate
even if `codex mcp list` does not currently surface `XcodeBuildMCP`. Repair only
that cache entry with:

```bash
python3 ./scripts/install_xcode_headless_profile.py \
  --repo-root . \
  --repair-build-ios-apps-cache
```

This repair is intentionally narrower than a global plugin uninstall. It moves
only Xcode's active temp `build-ios-apps` cache aside and preserves desktop,
fork-extended, VS Code, and CLI surfaces where `XcodeBuildMCP` remains the
expected non-Xcode control plane.

When validating the proxy inside Xcode, run Xcode-specific proxy commands with
`CODEX_HOME` set to Xcode's CodingAssistant Codex home. The proxy LaunchAgent
label is shared per user and port, so this lets the Xcode home claim the
long-lived process instead of accidentally reusing a proxy owned by another
Codex home. Normal Xcode-headless operation now requires the native proxy app
bundle, or the raw native proxy binary as a local developer fallback. The
manager fails closed instead of launching Node when the native proxy is missing.

Install or refresh the native proxy before preparing an Xcode-hosted session
for unattended work:

```bash
cd /path/to/apple-appdev-workflow
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-install-native-proxy
```

Node `mcp-proxy` remains available only as an explicit manual recovery path.
Installing the local Node runtime is allowed, but normal start/register paths
will not use it unless `XCODE_MCP_PROXY_ALLOW_NODE_FALLBACK=1` is set:

```bash
cd /path/to/apple-appdev-workflow
XCODE_MCP_PROXY_ALLOW_NODE_FALLBACK=1 \
  CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
  bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-install-proxy-runtime
```

The manager now packages the SwiftPM proxy as a small macOS app bundle under
the target Xcode CodingAssistant plugin runtime and prefers the bundle
executable over the older raw-binary fallback unless `XCODE_MCP_PROXY_USE_NATIVE=0`
is set. Set `XCODE_MCP_NATIVE_PROXY_CODESIGN_IDENTITY` or
`APPLE_APPDEV_WORKFLOW_CODESIGN_IDENTITY` to sign with a stable Developer ID or
Apple Development identity; if omitted, packaging falls back to ad-hoc signing
for local proof only. The current native proof serves `/ping`, is classified as
distribution-safe process identity, supports non-streaming Streamable HTTP POST
forwarding for the SDK `initialize`/`notifications/initialized`/`tools/list`
sequence, supports JSON-RPC batch decomposition, can wrap POST responses as
`text/event-stream` for SSE-only clients, acknowledges downstream session
`DELETE`, recovers after a request timeout, and reuses one upstream `mcpbridge`
process across downstream HTTP MCP sessions by default. In proof validation, a
fake stdio MCP bridge returned `XcodeListWindows` through the native proxy.

Strict source-level native proxy parity now passes when fake-bridge transport
proof is paired with live Xcode tool-call evidence. Fake-bridge validation
proves `GET /mcp` SSE stream opening, upstream notification fan-out to
already-open downstream streams, downstream disconnect propagation to
bridge-side `notifications/cancelled` for pending POST requests, and resumable
`Last-Event-ID` replay for retained per-session SSE events. Live
`xcrun mcpbridge` tool-call validation remains required before promotion claims.

Do not promote the native proxy as the production `mcp-proxy` replacement, and
do not treat notarization as the next release step, until the strict parity gate
passes against the current source and intended live host:

```bash
uv run python scripts/check_xcode_native_proxy_full_parity.py \
  --require-full-parity
```

The non-strict checker mode is useful for current-state reporting; strict mode
is the promotion gate.

As of 2026-06-18, strict parity passed with `gap_count: 0` when run with
`--live-xcode-url http://127.0.0.1:9876/mcp`. Packaging, LaunchAgent ownership,
notarization, stapling, and externally distributable install proof remain
separate release gates.

On 2026-06-17 the native proxy installed and launched successfully in the real
Xcode CodingAssistant home. The first live MCP inventory timed out while Xcode
was open without a project loaded; the external-agent authorization prompt
appeared only after opening an Xcode project. After that prompt surfaced,
deep inventory completed through the native proxy and returned the 21-tool Xcode
inventory, including `XcodeGetCurrentFile` and `XcodeListWindows`.

Treat "Xcode has a project/workspace open and the external-agent prompt has
been approved" as a precondition for live `status-probe`/`listTools`
validation. An Xcode app process with no loaded project is not enough evidence
that the native bridge is ready.

`status` is prompt-light by default: it checks the process, LaunchAgent owner,
context, and `/ping` health but does not run MCP `listTools`. Use
`status-probe` only when you deliberately want live inventory and are prepared
to approve Xcode's external-agent prompt:

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh status-probe
```

The first same-raw-binary restart proof still produced repeated prompts for
`apple-appdev-xcode-mcp-proxy-probe`, including for the native proxy PIDs. A
later Developer ID-signed app-bundle install improved the executable identity,
but screenshots still showed prompts for both the diagnostic probe client name
and `Codex`, plus another prompt after proxy restart. That means signing and
notarization are necessary for distribution identity, but not sufficient as the
only prompt mitigation. The active mitigation is:

- keep ordinary `status` prompt-light;
- make `status-probe` use the production-like `Codex` MCP client name by
  default, avoiding a second diagnostic authorization identity;
- keep one upstream `mcpbridge` process alive across downstream HTTP MCP
  sessions by default.

Use `--isolatedBridgeSessions` only for diagnostics where per-session upstream
bridge behavior is explicitly required.

On 2026-06-18, after reinstalling the Developer ID-signed app bundle with the
shared upstream bridge behavior, two consecutive `status-probe` runs returned
the full 21-tool inventory while the process tree showed one native proxy and
one `mcpbridge`. The operator observed only the initial Xcode authorization
prompt and no repeat prompt on the second probe. Treat that as the current
steady-state pass condition: a first prompt for a new signed client identity is
normal; repeat prompts while the proxy process remains alive are the regression.

On 2026-06-19, after the proxy surface was pruned to helper-only tools, the
Xcode-hosted inventory smoke passed with native `xcode-tools` exposing build,
test, documentation, preview, issue, and file tools while `xcode-proxy` exposed
only `XcodeGetCurrentFile` and `XcodeListWindows`. The required Xcode
authorization prompt did not appear at app launch; it appeared only after
quitting and reopening Xcode, opening a new CodingAssistant chat, and sending
the first prompt that touched the proxy. After approval, the strict native
proxy parity checker passed including live `XcodeListWindows`. Treat this as
expected first-use behavior for the signed proxy identity, not as proof that the
prompt will appear during passive app launch.

If the deep native doctor reports a stale config PID, it now prefers the
currently running selected Xcode process for the probe and prints the override:

```text
xcode_tools_config_pid_stale: <old-pid>
xcode_tools_probe_pid_override: <live-pid>
```

Use the distribution preflight to make that distinction explicit:

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-distribution-preflight
```

`xcode-codingassistant-distribution-preflight` fails when live `xcode-proxy`
processes are rooted in Node/npx recovery transport, including local plugin
runtime Node, transient `npm exec` or `_npx` paths, Homebrew or global Node
installs, ambient `node` resolution, or any other Node identity. An
installed-but-idle Node recovery runtime is not a blocker, but an active
Node-backed `xcode-proxy` process is. A distributable Xcode-headless package
must use the native proxy.

Normal native-proxy startup must use the signed
`XcodeMcpNativeProxy.app/Contents/MacOS/xcode-mcp-native-proxy` bundle
executable. The raw `bin/xcode-mcp-native-proxy` executable is manual
recovery-only and is ignored by normal start/register paths unless
`XCODE_MCP_NATIVE_PROXY_ALLOW_RAW_FALLBACK=1` is set explicitly. An idle raw
binary is not a blocker, but an active raw-native `xcode-proxy` process fails
the distribution preflight because it bypasses the app-bundle identity Xcode
prompts and Gatekeeper checks are meant to prove.

For native-proxy release packaging, build a Developer ID app bundle and run the
release checker separately from live Xcode validation:

```bash
APPLE_APPDEV_WORKFLOW_CODESIGN_IDENTITY="Developer ID Application: Example Team (TEAMID1234)" \
tools/xcode-mcp-native-proxy/scripts/package_app.sh \
  --output /tmp/XcodeMcpNativeProxy-release-check.app \
  --version 0.1.0 \
  --build 1 \
  --release

uv run python scripts/check_xcode_native_proxy_release_package.py \
  --app /tmp/XcodeMcpNativeProxy-release-check.app \
  --require-developer-id \
  --expect-bundle-id com.joshuakaunert.apple-appdev-workflow.xcode-mcp-native-proxy
```

This proves a notarization-ready local package shape, not Apple notarization
acceptance. Submit and staple only as an explicit operator action:

```bash
tools/xcode-mcp-native-proxy/scripts/notarize_app.sh \
  --app /tmp/XcodeMcpNativeProxy-release-check.app \
  --keychain-profile apple-appdev-workflow-notary
```

Use `--dry-run` first when checking credentials or command shape. After
stapling, rerun the release checker with `--require-spctl` to require Gatekeeper
acceptance.

After installing the proxy into Xcode CodingAssistant home, rerun the live
distribution preflight. It must report the active native proxy form as the app
bundle, not raw fallback, before the Xcode-headless beta path can be treated as
closed on proxy signing.

For the profile-only Xcode companion, render the `xcode-headless` artifact and
package it instead of trying to run a hidden Marketplace post-install step:

```bash
python3 scripts/render_plugin_manifest_profile.py \
  --repo-root . \
  --output-dir /tmp/apple-appdev-xcode-headless-0.2.0 \
  --profile xcode-headless \
  --validate

APPLE_APPDEV_WORKFLOW_CODESIGN_IDENTITY="Developer ID Application: Example Team (TEAMID1234)" \
tools/xcode-headless-installer/scripts/package_dmg.sh \
  --plugin-profile /tmp/apple-appdev-xcode-headless-0.2.0 \
  --plugin-version 0.2.0 \
  --output-dir /tmp/apple-appdev-xcode-headless-installer \
  --release \
  --notarize \
  --keychain-profile AppleAppsBrigade
```

After Gatekeeper accepts the exact DMG, install explicitly with
`--install-plugin-profile`. A same-version cache entry is backed up under Xcode
Codex home's plugin quarantine root, and the installer prints the path accepted
by `--restore-plugin-profile`. Profile install and restore never write the
Xcode `Agents` tree.

For Xcode-headless primary-agent canaries, use the same installer-DMG path
instead of a bare agent directory or ZIP. The optional agent mode packages the
embedded Codex agent in a signed app, creates a signed DMG, and can submit that
exact DMG to Apple notarization:

```bash
APPLE_APPDEV_WORKFLOW_CODESIGN_IDENTITY="Developer ID Application: Example Team (TEAMID1234)" \
tools/xcode-headless-installer/scripts/package_dmg.sh \
  --agent-runtime /path/to/codex \
  --agent-version 0.142.0-alpha.1-fork-xcode-canary \
  --agent-url local-fork-runtime://0.142.0-alpha.1-fork-xcode-canary/codex \
  --output-dir /tmp/apple-appdev-xcode-headless-installer \
  --release \
  --notarize \
  --keychain-profile AppleAppsBrigade
```

This package step does not activate the Xcode agent. After mounting an accepted
DMG, activation is still an explicit operator action:

```bash
"/Volumes/Apple AppDev Xcode Headless Installer/AppleAppDevXcodeHeadlessInstaller.app/Contents/MacOS/xcode-headless-installer" \
  --install-agent \
  --activate-agent
```

The embedded agent metadata is part of the Xcode acceptance surface. The
installer package must write `Info.plist` after signing the embedded `codex`
runtime, with `checksum` equal to `shasum -a 512 codex` for the final signed
binary. If Xcode reports that the agent code-signing identity did not match
expectations, check this metadata before assuming Developer ID, hardened
runtime, or notarization failed.

The installed agent directory should also match Xcode's stock component shape:
only `codex` and `Info.plist`, with removable quarantine metadata cleared and
without packaging-only backup files. The installer intentionally clears
removable extended attributes during activation and excludes backup files so
Xcode does not evaluate stale mount-time metadata as part of the agent sandbox.
macOS may still attach system-managed provenance xattrs to locally created
files; quarantine attributes and extra files are the actionable defects.

Closeout note: on 2026-06-21 the Xcode 26 build `17F42` canary still failed
with Xcode's code-signing identity / sandboxing error after the active agent
directory matched the stock two-file shape, the checksum matched the final
signed runtime SHA-512, removable quarantine metadata was absent, and the native
proxy app bundle passed Developer ID, notarization, stapling, and Gatekeeper
checks. Do not keep iterating Xcode 26 primary-agent packaging from that state;
the remaining block is Xcode/provider acceptance unless Apple exposes a
supported component/provider registration path or new evidence identifies a
different required artifact.

Live proxy start and deep `status-probe` checks require Xcode to be running
unless you are intentionally binding a specific Xcode MCP context with
`XCODE_MCP_PROXY_BIND_XCODE_SESSION=1`. If Xcode is closed, the manager should
fail before leaving a retrying LaunchAgent behind.

```bash
cd /path/to/apple-appdev-workflow
XCODE_CA_CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex"

CODEX_HOME="$XCODE_CA_CODEX_HOME" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-register

CODEX_HOME="$XCODE_CA_CODEX_HOME" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh status
```

`xcode-codingassistant-register` leaves Xcode's built-in `xcode-tools` entry in
place and adds only `xcode-proxy -> http://127.0.0.1:9876/mcp`.
`status` reports `launch_agent_owner: different_runtime` when the active
LaunchAgent runner belongs to another Codex home. It also reports the current
native `xcode-tools` `MCP_XCODE_PID` and whether `MCP_XCODE_SESSION_ID` is
present. The proxy remains external by default so it can expose the broader
external-bridge inventory; set `XCODE_MCP_PROXY_BIND_XCODE_SESSION=1` only for
targeted tests that intentionally compare the proxy against Xcode's native
agent-mode bridge context.

The normal Xcode-headless proxy surface is helper-only. Native proxy launches
default `XCODE_MCP_PROXY_TOOL_ALLOWLIST` to
`XcodeGetCurrentFile,XcodeListWindows`, so the proxy does not duplicate native
`xcode-tools` build, test, documentation, preview, issue, or file-operation
tools in ordinary hosted sessions. Set `XCODE_MCP_PROXY_TOOL_ALLOWLIST=all`
only for full-passthrough diagnostics or native-proxy parity checks, and do not
use that mode for distribution-surface claims.

2026-06-15 live baseline: after Xcode was running and the operator approved the
external-agent prompt, `status` reported the proxy owned by the plugin runtime,
`health: healthy`, `mcp_health: connected`, `mcp_tool_count: 21`,
`mcp_has_window_tab_tool: yes`, and both `XcodeGetCurrentFile` and
`XcodeListWindows` through the separate `xcode-proxy` server. Treat this as
Xcode-headless proxy health evidence only. It does not clear future AFK auth
prompt risk, desktop-owned `XcodeBuildMCP` overlap, or any marketplace,
fork-extended, GUI, prompt-matrix, remote-control, or public-release gate.

In launchd mode, the generated runner supervises Xcode's native bridge context
without making periodic MCP `listTools` calls. It reads the selected Xcode
process PID every two seconds by default and restarts only the proxy child when
that PID changes, falling back to Xcode CodingAssistant's configured
`MCP_XCODE_PID` only when the process is not discoverable. This
prevents a stale upstream `mcpbridge` child from surviving an Xcode restart and
avoids racing the first Xcode assistant discovery pass, because the config PID
can update only after the embedded app-server starts. `MCP_XCODE_SESSION_ID` is
still reported for diagnostics, but it is not a restart trigger by default
because Xcode may change that value across assistant attempts while the same
Xcode process remains alive. Disable monitoring only for diagnosis with
`XCODE_MCP_PROXY_CONTEXT_MONITOR=0`, change the interval with
`XCODE_MCP_PROXY_CONTEXT_INTERVAL_SECONDS`, or opt into the old session-churn
probe with `XCODE_MCP_PROXY_CONTEXT_KEYS=pid-session`. Diagnostic MCP inventory
probes allow 30 seconds by default via `XCODE_MCP_PROBE_TIMEOUT_MS` so the first
post-restart bridge warm-up does not produce a false disconnected result.

Use the read-only doctor when host behavior changes, when Xcode regenerates
`config.toml`, or when a smoke prompt appears to lose tools:

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-doctor
```

The doctor reports the selected Xcode version, Xcode's embedded Codex runtime
version, the shell Codex version, Apple AppDev Workflow plugin status and skill
count, key MCP registrations, and the effective `xcode-tools` backend. It is
prompt-light by default: it does not spawn a new native `mcpbridge` inventory
client because that can trigger Xcode or macOS permission prompts. Treat plugin
availability, direct native `xcode-tools` capability, and external proxy
capability as separate checks: Xcode may have the plugin loaded while the
embedded-agent bridge exposes only project, file, search, build, test, and
preview operations. The manager also verifies MCP `listTools` health for
proxy-backed entries, so a proxy that responds to `/ping` but returns
`MCP error -32603: Not connected` is now treated as disconnected and restarted
by `start`/`restart`.

Xcode-hosted plugin maintenance has an additional guard. The Xcode
CodingAssistant approval bridge can wedge when a request emits multiple
parallel shell, git, filesystem, native Xcode MCP, or proxy MCP calls: some
approvals may complete while other pending calls remain hidden, leaving the
assistant thinking indefinitely. `xcode-codingassistant-register` and
`xcode-codingassistant-recover-tool-surfacing` install the
`Xcode Hosted Plugin Review Guard` and `Xcode Hosted Approval-Safe Tool Use`
into Xcode's `developer_instructions` so ordinary Apple app/project work stays
on Xcode MCP tools, plugin-bundle review/debug/maintenance is handed off to
Codex desktop or another fork-local Codex session by default, and any
approval-sensitive shell/git/native/proxy work is serialized.

If shell-based plugin maintenance is explicitly authorized from Xcode, issue
only one shell command at a time and wait for its approval and result before
issuing another. The same one-at-a-time rule applies to read-only git probes and
native/proxy MCP calls that might require Xcode external-agent authorization.

To reinstall only that guard after Xcode rewrites `config.toml`:

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-install-plugin-guard
```

For unattended or AFK Xcode validation, the stricter preflight now fails if the
approval-safe guard is missing, even when no live prompt-risk process is visible.

Use the deep native probe only when diagnosing the direct `xcode-tools`
bridge. It can prompt because it creates a fresh native `mcpbridge` client:

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
XCODE_MCP_PROXY_DEEP_NATIVE_PROBE=1 \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-doctor
```

If Xcode-hosted Codex still cannot see `xcode-proxy` after the proxy is
registered and MCP-healthy, refresh Xcode's embedded Codex app-server discovery
cache instead of renaming or aliasing MCP servers:

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-recover-tool-surfacing
```

That recovery path preserves native `xcode-tools`, verifies the separate
`xcode-proxy` URL endpoint with MCP `listTools`, registers only a missing
separate `xcode-proxy` entry, and then sends `TERM` only to Xcode's embedded
`codex app-server` child. The next Xcode assistant request starts a fresh
app-server and should rediscover both `xcode-tools` and `xcode-proxy`. To audit
the process without stopping the app-server, run the same command with
`XCODE_MCP_PROXY_DRY_RUN=1`.

Apple's external-agent permission is still required for the external proxy
path. In Xcode, open Settings > Intelligence and enable "Allow external agents
to use Xcode tools"; Xcode may prompt when a new external client connects. This
permission is necessary but not sufficient evidence that Xcode-hosted Codex has
the same tools as an external agent: the Xcode-provided `MCP_XCODE_PID` and
`MCP_XCODE_SESSION_ID` agent-mode environment can expose a narrower direct
`mcpbridge` inventory than an external proxy connection.

The default topology is concurrent: direct native `xcode-tools` remains
registered and `xcode-proxy` is added as a separate URL-backed server. Keep that
shape. Do not replace Xcode's built-in `xcode-tools` entry with the proxy URL;
that hides the native direct bridge under the server name that should remain
available for host-provided Xcode tools.

Also keep the default proxy inventory pruned. If `xcode-proxy` exposes native
duplicates such as `BuildProject`, `RunAllTests`, `DocumentationSearch`, or
file-editing tools, treat that as full-passthrough diagnostic mode or stale
LaunchAgent state. Restart through `xcode-codingassistant-register` without
`XCODE_MCP_PROXY_TOOL_ALLOWLIST=all` before scoring the default
Xcode-headless surface.

Use the config-status check to verify the backend. A proxy-backed Xcode tools
entry reports `xcode_tools_backend: url`; a direct native bridge reports
`xcode_tools_backend: command`.

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-config-status
```

If `xcode_tools_backend: url`, the Xcode CodingAssistant home is in legacy
alias drift. Restore a backup that has `xcode-tools` registered as a command,
then run `xcode-codingassistant-register` again if the separate `xcode-proxy`
entry is missing:

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
XCODE_MCP_PROXY_CONFIG_BACKUP="$HOME/Library/Developer/Xcode/CodingAssistant/codex/config.toml.bak-<timestamp>" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-restore-config
```

In Xcode prompts, ask the assistant to use the Xcode MCP tools, avoid shell or
AppleScript fallbacks, and use tools that the doctor confirms are present.
Current Xcode 26.5 / build 17F42 sessions may not expose window/tab inspection
through the embedded direct `mcpbridge` server; use `XcodeLS`, `XcodeRead`, or
`XcodeGrep` for the lightest read-only smoke unless the doctor reports a
window/tab tool. On the 2026-06-11 regression compare, the direct
Xcode-hosted agent-mode bridge exposed 19 tools and omitted `XcodeListWindows`
and `XcodeGetCurrentFile`, while the restarted external proxy exposed 21 tools
including both. Treat that as a tool-surfacing gap to measure with both
registrations present, not as a reason to rename or overwrite `xcode-tools`.

If you are debugging XcodeBuildMCP directly, note that its `xcode-ide` workflow
contains `xcode_ide_list_tools`, `xcode_ide_call_tool`, and
`xcode_tools_bridge_status`, but that workflow is hidden in Xcode agent mode.
It can be available in an external Codex session while the Xcode-hosted
assistant sees only the host-provided `xcode-tools` inventory.

To restore the most recent backup:

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-restore-config
```

Restart the Xcode CodingAssistant chat, or restart Xcode if needed, after
rewriting the config. Already-open assistant sessions may keep the old
developer-instructions block in memory.

To remove only the proxy entry from Xcode's Codex home:

```bash
CODEX_HOME="$HOME/Library/Developer/Xcode/CodingAssistant/codex" \
bash ./codex-cli/xcode-mcp-proxy-manager.sh xcode-codingassistant-remove
```

## Persistent Codex fork MCP proxy

`codex-cli/codex-fork-mcp-proxy-manager.sh` exposes a fork-local Codex runtime
as a separate HTTP MCP server. It keeps `mcp-proxy` in front of
`codex mcp-server` and exposes `codex-fork-headless` at
`http://127.0.0.1:9888/mcp` by default.

Use this only for source-checkout or fork-local validation. It is an operator
bridge for testing a forked headless Codex runtime from hosts such as Xcode
CodingAssistant; it is not part of the marketplace MCP manifest and should not
replace Xcode's built-in `xcode-tools` server.

The manager defaults to:

- `CODEX_FORK_MCP_CODEX_HOME=${CODEX_HOME:-$HOME/.codex-fork}`
- `CODEX_FORK_MCP_RUNTIME_REPO=$HOME/Developer/codex`
- `CODEX_FORK_MCP_INSTALLED_CODEX_BIN` under
  `$CODEX_FORK_MCP_CODEX_HOME/plugin-runtime/apple-appdev-workflow/codex-fork-runtime/bin/codex`
  when an installed release runtime exists
- source release, then source debug, then `codex` on `PATH` when no installed
  release runtime exists
- `CODEX_FORK_MCP_RUNTIME_CONTRACT` to the fork-local runtime carry contract
  in source checkouts
- `CODEX_FORK_MCP_PROXY_PORT=9888`

Build and install the current runtime carry into the stable fork-local runtime
path:

```bash
cd /path/to/apple-appdev-workflow
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh install-runtime
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh runtime-install-status
```

`install-runtime` builds `codex-cli` with the release profile from
`CODEX_FORK_MCP_RUNTIME_REPO`, copies the resulting `codex` binary into the
fork-local plugin runtime directory, and writes a manifest with the runtime
branch, head, upstream head, installed version, and installed sha256.

Start and inspect the proxy:

```bash
cd /path/to/apple-appdev-workflow
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh start
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh status
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh doctor
```

By default, the fork MCP manager starts a lightweight proxy-side reasoning
policy wrapper on the public endpoint and runs the generic `mcp-proxy` on an
internal port:

- public endpoint: `http://127.0.0.1:9888/mcp`
- internal upstream endpoint: `http://127.0.0.1:9889/mcp`
- opt-out: `CODEX_FORK_MCP_REASONING_POLICY_MODE=off`
- internal port override: `CODEX_FORK_MCP_REASONING_POLICY_UPSTREAM_PORT`

The wrapper forwards ordinary MCP traffic unchanged. For `tools/call` requests
to the `codex` tool, it preserves an explicit
`config.model_reasoning_effort`; otherwise it classifies the request with
`scripts/reasoning_policy.py`, injects `config.model_reasoning_effort`, and
adds a short developer-instruction trace note before forwarding to the forked
runtime.

Policy callers may pass sidecar context fields such as `intent`,
`changedFiles`, `activeFile`, or `paths` to help the proxy classify a request.
The proxy strips those fields before forwarding to the Codex MCP tool, because
the runtime schema accepts only the Codex tool arguments.

Model switching is not enabled in this proxy. The forked Codex MCP tool accepts
a top-level `model` argument, so future proxy-side model selection is
technically possible without a runtime carry, but automatic model switching is
intentionally deferred for the shipped setup path. Any future selector should
start as trace-only evidence rather than default injected behavior.

`doctor` checks the pinned runtime carry contract, the proxy health endpoint,
and the live child `codex` binary. It fails if the running proxy is still
serving an older binary than the configured fork binary. By default it treats
new upstream commits as a warning so bridge health can still be checked after
upstream moves. Use strict mode before rebuild, package, release, or current
prompt-matrix evidence:

```bash
CODEX_FORK_MCP_STRICT_RUNTIME_UPSTREAM=1 \
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh doctor
```

To force a specific carry binary:

```bash
CODEX_FORK_MCP_CODEX_BIN="$HOME/Developer/codex/codex-rs/target/release/codex" \
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh start
```

To register the fork endpoint in the fork-local Codex home:

```bash
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh codex-register
```

To register the same endpoint in Xcode's CodingAssistant Codex home without
removing `xcode-tools`:

```bash
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh xcode-codingassistant-install
```

That command installs the release runtime first when the stable installed
binary is missing, starts the proxy, registers `codex-fork-headless` in
`~/Library/Developer/Xcode/CodingAssistant/codex`, leaves Xcode's built-in
`xcode-tools` MCP entry intact, and then runs the Xcode-specific doctor.
Set `CODEX_FORK_MCP_REBUILD_RUNTIME=1` to force a rebuild and reinstall before
registration.

Use these checks when validating an Xcode-facing install:

```bash
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh xcode-codingassistant-doctor
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh xcode-codingassistant-smoke
```

The smoke runs a fresh `codex exec` through Xcode's Codex home and asks the
`codex-fork-headless` MCP server to reply with
`CODEX_FORK_HEADLESS_MCP_PONG`. Passing this smoke proves that Xcode's Codex
home can reach the forked headless runtime through the registered HTTP MCP
endpoint.

### Reasoning policy probe

Before adding any new runtime carry for reasoning-tier routing, use the
proxy-side policy probe:

```bash
python3 ./scripts/run_reasoning_policy_proxy_probe.py --dry-run --json
```

The dry run classifies representative Xcode, proxy/protocol, and
cross-platform schema scenarios, then prints the selected reasoning effort,
queue class, timeout budget, reason codes, and direct/proxy command templates.
This is intentionally non-invasive: it uses existing runtime effort surfaces
for command templates and keeps the generic MCP proxy unchanged until
performance or correctness evidence justifies deeper integration.

Live runs are opt-in:

```bash
python3 ./scripts/run_reasoning_policy_proxy_probe.py --run-direct --run-proxy-health --json
```

For a cleaner fork-local comparison, use the installed fork binary and the
direct Streamable HTTP MCP tool leg:

```bash
python3 ./scripts/run_reasoning_policy_proxy_probe.py \
  --scenario xcode_quick_fix \
  --codex-bin "$HOME/.codex-fork/plugin-runtime/apple-appdev-workflow/codex-fork-runtime/bin/codex" \
  --run-direct \
  --run-proxy-direct-tool \
  --json
```

The direct MCP tool leg calls `http://127.0.0.1:9888/mcp` without routing
through a parent Codex agent, passes the chosen effort through the existing
`config.model_reasoning_effort` surface, and captures bounded stdout/stderr
previews so the result proves both timing and returned content. Use
`--run-proxy-smoke` separately when you need end-to-end Xcode CodingAssistant
proof; that smoke includes parent-agent tool-selection overhead and should not
be treated as pure proxy overhead.

To prove the wrapper injects effort when the caller omits it:

```bash
python3 ./scripts/run_reasoning_policy_proxy_probe.py \
  --scenario xcode_quick_fix \
  --run-proxy-policy-injection \
  --json
```

The live log should include a `reasoning policy trace: <effort>` line. A
latency-critical Xcode-style smoke should trace `low` unless the caller passes
explicit changed-file or intent context that justifies a higher tier.

For the durable scenario-aware benchmark, use:

```bash
python3 ./scripts/run_reasoning_policy_benchmark.py \
  --output-dir "$HOME/.codex-fork/quarantine/reasoning-policy-benchmarks/<run-id>" \
  --repeat 2 \
  --timeout-seconds 300
```

The benchmark writes `dry-run.json`, `transport-benchmark.json`,
`summary.json`, and `summary.md`. It checks representative low/high policy
selection, raw transport trace headers, first-byte timing, final body timing,
and post-disconnect proxy health.

For the full fork-local performance gate, compare direct CLI, explicit proxy
effort, and proxy policy injection across the representative scenarios with the
installed fork runtime binary:

```bash
python3 ./scripts/run_reasoning_policy_proxy_probe.py \
  --scenario xcode_quick_fix \
  --scenario plugin_proxy_policy \
  --scenario cross_platform_schema \
  --run-direct \
  --run-proxy-direct-tool \
  --run-proxy-policy-injection \
  --codex-bin "$HOME/.codex-fork/plugin-runtime/apple-appdev-workflow/codex-fork-runtime/bin/codex" \
  --json \
  --timeout-seconds 300
```

The 2026-06-11 post-refresh measurement returned `PONG` on all legs with these
durations: `xcode_quick_fix` direct 7.063s, proxy explicit 3.484s, proxy
injected 2.903s; `plugin_proxy_policy` direct 4.904s, proxy explicit 3.293s,
proxy injected 2.870s; `cross_platform_schema` direct 5.311s, proxy explicit
3.394s, proxy injected 5.457s. Treat this as bounded transport/policy evidence;
run richer task smokes before claiming user-facing quality or streaming
behavior.

For the raw transport gate, use:

```bash
python3 ./scripts/run_reasoning_policy_proxy_transport_probe.py \
  --json \
  --timeout-seconds 300
```

This probe initializes a Streamable HTTP MCP session without the SDK client,
calls the `codex` tool through the reasoning-policy proxy, checks the
`x-codex-fork-reasoning-policy` response header, records response header/body
timing, and forces an early client disconnect before checking `/ping` again.
The 2026-06-11 post-hardening run returned `PONG`, preserved
`content-type: text/event-stream`, injected trace header `low`, returned
response headers and the first SSE body byte in 0.007s, completed the final
body in 3.559s, and kept `/ping` healthy after a client close at 0.161s. This
proves metadata/SSE framing, streamed first-byte behavior, and disconnect
tolerance through the proxy. It does not prove upstream model-task cancellation
propagation.

The later 2026-06-11 scenario-aware benchmark passed two repeats for
`xcode_quick_fix`, `plugin_proxy_policy`, and `cross_platform_schema`. Observed
trace headers matched the expected efforts: `low`, `high`, and `high`. Keep
durable evidence paths and caveats in the local benchmark output directory for
the run being cited.

To remove only the fork endpoint from Xcode:

```bash
bash ./codex-cli/codex-fork-mcp-proxy-manager.sh xcode-codingassistant-remove
```

## Manual CLI setup

Manual CLI configuration is optional for normal marketplace installs. Prefer the
plugin-declared `.mcp.json` path unless you are deliberately configuring a
source checkout or CLI-only environment.

Equivalent manual setup uses `codex mcp add`:

```bash
codex mcp add memory \
  --env MEMORY_FILE_PATH="$HOME/.codex/memory.json" \
  -- npx -y @modelcontextprotocol/server-memory@2026.1.26

codex mcp add sosumi \
  -- npx -y mcp-remote@0.1.38 \
  https://sosumi.ai/mcp

codex mcp add XcodeBuildMCP \
  --env XCODEBUILDMCP_ENABLED_WORKFLOWS="coverage,debugging,device,logging,macos,project-discovery,project-scaffolding,session-management,simulator,simulator-management,swift-package,ui-automation,utilities,xcode-ide" \
  -- npx -y xcodebuildmcp@2.3.2 mcp
```

After manual `codex mcp add`, set the fork-local timeout override in
`$CODEX_HOME/config.toml`:

```toml
[mcp_servers.XcodeBuildMCP]
tool_timeout_sec = 600
```

The source helper applies this automatically. Keep the override in disposable
validation homes too; otherwise cold simulator tests can hit the default Codex
MCP tool-call envelope before a healthy `xcodebuild test` completes.

The source helper:

- defaults `memory` to `~/.codex/memory.json`
- reuses that file automatically if it already exists
- can restore from a backup if you set `MEMORY_RESTORE_SOURCE=/path/to/memory.json`
- sets `XcodeBuildMCP` `tool_timeout_sec` to `600` by default

Example restore:

```bash
cd /path/to/apple-appdev-workflow
MEMORY_RESTORE_SOURCE="/path/to/backup/memory.json" \
bash ./codex-cli/setup-codex-mcp.sh
```

Source checkouts can verify XcodeBuildMCP config with:

```bash
bash ./codex-cli/verify-xcodebuildmcp.sh
```

## Config Surfaces

- Marketplace payload: `.mcp.json`
- Source checkout helpers: `codex-cli/config.mcp.toml` and `codex-cli/config.full.toml`

## Expected XcodeBuildMCP surface
- This bundle expects XcodeBuildMCP to start with the full workflow set enabled, including:
  - `coverage`
  - `debugging`
  - `device`
  - `logging`
  - `macos`
  - `project-discovery`
  - `project-scaffolding`
  - `session-management`
  - `simulator`
  - `simulator-management`
  - `swift-package`
  - `ui-automation`
  - `utilities`
  - `xcode-ide`
- If a Codex session exposes only simulator tools, the MCP configuration is incomplete. Re-run the marketplace MCP grant flow or manual CLI setup, confirm `XCODEBUILDMCP_ENABLED_WORKFLOWS` is present in Codex MCP config, and restart Codex.

Conditional XcodeBuildMCP capabilities:

- `doctor` is available in `xcodebuildmcp@2.3.2`, but the MCP package only exposes it when `XCODEBUILDMCP_DEBUG=true`. Keep it opt-in for targeted diagnostics rather than turning verbose debug mode on for every install.
- `workflow-discovery` is available in `xcodebuildmcp@2.3.2`, but the MCP package only exposes it when `XCODEBUILDMCP_EXPERIMENTAL_WORKFLOW_DISCOVERY=true`. Keep it opt-in because it can mutate enabled workflows at runtime.
- `xcode-ide` can be declared in config on all hosts, but native Xcode IDE bridge proxying requires a compatible host. Treat macOS versions below `26` or Xcode versions below `26` as `xcode-ide-unavailable-host`, not as a plugin config regression. On macOS `15.7.5` with Xcode `26.3`, `xcrun --find mcpbridge` succeeds but `xcrun mcpbridge --help` fails with a missing `AppSandbox` symbol, so ordinary XcodeBuildMCP project, simulator, package, logging, and UI automation workflows remain the supported fallback.

## Workflow expectations

- `apple-app-orchestrator` should assume these MCPs are available when installed.
- Apple documentation retrieval should route through `fetch-apple-docs`, which
  may use the plugin-owned `sosumi` MCP as its preferred transport.
- If MCP startup fails temporarily, the CLI fallbacks remain available via:
  - `npm exec --prefix "$HOME/.codex/plugin-runtime/apple-appdev-workflow" -- sosumi ...`
  - `npm exec --prefix "$HOME/.codex/plugin-runtime/apple-appdev-workflow" -- xcodebuildmcp ...`
  - `bash ./codex-cli/xcode-mcp-proxy-manager.sh start`
  - `bash ./codex-cli/codex-fork-mcp-proxy-manager.sh start`
- Do not copy `node_modules/` into the plugin install source. Codex indexes
  nested `skills/` directories recursively, and dependency-owned `skills/`
  folders inside `node_modules/` will surface as duplicate skills.
- All MCP-assisted conclusions that matter to the project should still be written into normal markdown artifacts or task output.
