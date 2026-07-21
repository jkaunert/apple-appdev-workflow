# Xcode Headless Host Policy

This reference defines the tool-selection override for the `xcode-headless`
profile installed into Xcode CodingAssistant.

## Purpose

`xcode-headless` exists to make Apple AppDev Workflow skills usable from inside
Xcode without replacing Xcode's built-in tool surface. It preserves the same
workflow graph as fork-local, but adapts overlapping execution tools to native
Xcode surfaces. It is not a desktop runtime profile and not a public release
profile.

The profile must preserve deterministic selection and the top-level owner
contract. Xcode-headless strips plugin-managed MCP declarations because Xcode
owns the native tool surface. Its production manifest now omits retired
`routerSelection` metadata and ships the same default-discovered hook, neutral
policy, and compact owner kernel proven across all 9 live Xcode cases. The old
post-render probe override is historical evidence only and is no longer an
installer or product-profile path.

Use `xcode-headless-tool-adapter.md` for the lane-level mapping between
fork-local execution tools and Xcode-native equivalents. This policy defines
the host boundary; the adapter defines how the normal orchestrators and stations
keep functioning inside that boundary.

For the current Xcode 27 ACP capability inventory and native-provider parity
matrix, consult the source checkout's Xcode ACP native tool parity map before
rendering or packaging Xcode-headless artifacts.

## Tool Hierarchy

When the active host is Xcode CodingAssistant or the installed plugin artifact
is the `xcode-headless` profile:

1. Prefer Xcode's native `xcode-tools` server for Xcode-aware file, build,
   test, documentation, issue, preview, and project operations.
2. Use `xcode-proxy` only for Xcode bridge capabilities that native
   `xcode-tools` does not expose in the current session, such as current-file
   or window/tab context.
3. Use `codex-fork-headless` only for broader Codex orchestration or delegation
   when the Xcode-hosted assistant needs the forked runtime as a backend. Do not
   treat it as the default owner of native Xcode operations.
4. Do not invoke `XcodeBuildMCP` from Xcode-headless unless the session
   explicitly exposes it and the user has asked to test or compare that
   alternate path. Its absence is expected in this profile, not a defect.
5. Do not install, register, or mutate plugin-managed MCP servers as part of
   normal Xcode-headless skill execution. Proxy registration and recovery
   helpers are manual host-maintenance paths.

The normal `xcode-proxy` tool surface should be pruned to non-duplicate helper
tools. Full native-proxy passthrough is useful for parity diagnostics, but it
must require an explicit override such as `XCODE_MCP_PROXY_TOOL_ALLOWLIST=all`.
Do not expose proxy copies of `BuildProject`, `RunAllTests`,
`DocumentationSearch`, file-editing tools, or other native `xcode-tools`
operations in the default Xcode-headless profile.

## Approval-Safe Execution

Xcode CodingAssistant has a distinct approval and external-agent authorization
surface. A turn can appear to hang when it launches several shell, git,
filesystem, native Xcode MCP, or proxy MCP calls in parallel: some approvals may
complete while later approvals remain hidden from the user.

Inside Xcode-headless, approval-sensitive work must be serialized:

- prefer native `xcode-tools` for project operations, then `xcode-proxy` for
  missing bridge context
- use shell or git only for narrow evidence that the native tools cannot provide
- issue at most one approval-sensitive shell, git, native Xcode MCP, or proxy
  MCP call at a time
- wait for the result before starting the next approval-sensitive call
- if a turn hangs after earlier calls completed, stop and report a likely hidden
  Xcode approval or elicitation queue instead of launching more probes

The Xcode CodingAssistant `developer_instructions` must contain both
`Xcode Hosted Plugin Review Guard` and `Xcode Hosted Approval-Safe Tool Use`
before unattended or AFK Xcode-hosted validation.

## Distribution Identity Gate

AFK-safe and distribution-safe are different gates. Approving Xcode's
external-agent prompt can make the current host usable for local validation, but
it does not prove that the proxy executable identity is stable enough for a
notarized or distributable Xcode-headless package.

For local development, the proxy may run through the pinned plugin-runtime
`mcp-proxy` dependency while using the developer's current `node`. For
distribution readiness, `xcode-proxy` must not depend on transient `npm exec` or
`_npx` paths, Homebrew Node, global Node, ambient `node` lookup, or another
external Node executable that will vary by developer machine.

The acceptable distribution shapes are:

- a bundled and signed Node runtime with a stable executable path under the
  plugin runtime
- a native proxy that removes Node from the runtime trust boundary

The native proxy is the preferred long-term shape for an installable
Xcode-headless beta. Until that exists, the distribution preflight must block
release claims when the live proxy is rooted in dev-mode Node.

That proxy gate is conditional on the artifact claiming or requiring the
proxy. The profile-only companion envelope produced by
`tools/xcode-headless-installer` contains no `mcpServers`, proxy executable, or
Node runtime and makes no proxy-availability claim. It may be distributed for
the native `xcode-tools` baseline after its own Developer ID, notarization,
Gatekeeper, rollback, and exact-package host gates pass. If the installed host
later opts into `xcode-proxy`, that separately provisioned surface must satisfy
the identity gate before its behavior is included in a distribution claim.

Distribution readiness also requires the live proxy to preserve the
non-duplicate tool surface: native `xcode-tools` owns build, test,
documentation, and file operations, while `xcode-proxy` exposes only helper
tools that Xcode's native server does not currently provide. A full passthrough
proxy is a diagnostic mode, not a release surface.

The Xcode plugin profile is also a separate distribution surface from both the
proxy and primary-agent canaries. The supported shape is a signed installer app
inside a signed, notarized, stapled DMG. Profile install must be explicit,
validate that `mcpServers` and retired `routerSelection` are absent, preserve a
same-version rollback backup, offer a validated restore command, and never
write the active Xcode agent symlink. Marketplace install does not have
post-install authority to mutate Xcode CodingAssistant's Codex home.

Primary Xcode Codex-agent canaries are a separate distribution surface from the
native proxy. Do not submit or distribute a bare agent directory, raw executable,
or ZIP of `Agents/codex/<version>` as release evidence. The supported
distribution-equivalent shape is a signed installer app inside a signed,
notarized, stapled DMG. Packaging and notarization must not change the active
Xcode `Agents/XcodeVersions/<build>/codex` symlink; activation is a separate
operator step after the installer artifact passes Gatekeeper validation.

## Bootstrap And Adopt Override

In Xcode ACP, Xcode's native New Project flow owns initial greenfield app and
project creation unless the user explicitly asks for bundle bootstrap scripts.
The Apple bootstrap lane still owns adoption, harness handoff, repository
policy, release-intent steering, and validation routing after a project exists.

After a scaffold or adopt pass produces or locates an Xcode project inside
Xcode-headless, validate with native Xcode tools first:

- `BuildProject` for build validation
- `RunAllTests` or `RunSomeTests` for test validation
- `GetBuildLog`, `GetTestList`, and `XcodeListNavigatorIssues` for diagnosis
- `DocumentationSearch` for Apple documentation lookups when the host can
  provide it

Use raw shell `xcodebuild` only when native Xcode tools or the proxy cannot
answer the question, and state the specific host-tool gap before falling back.

The same rule applies to review, debug, release, architecture, testing, and
specialist lanes: keep the Apple workflow owner, then execute Xcode-aware work
through the host-native adapter.

## Non-Xcode Surfaces

This policy does not change desktop, fork-extended, marketplace, VSCode, or CLI
behavior. Outside Xcode-headless, `XcodeBuildMCP` remains the primary
Xcode-aware build, test, simulator, and project execution surface when available.
