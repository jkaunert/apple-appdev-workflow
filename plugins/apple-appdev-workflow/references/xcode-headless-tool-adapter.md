# Xcode Headless Tool Adapter

This reference defines how the `xcode-headless` profile preserves the normal
Apple AppDev Workflow graph while swapping overlapping execution tools to
Xcode-native surfaces.

For the current Xcode 27 ACP provider inventory and skill-to-provider matrix,
consult the source checkout's Xcode ACP native tool parity map before rendering
or packaging Xcode-headless artifacts.

## Contract

`xcode-headless` is not a reduced plugin and not a generic Xcode-tools prompt.
It must keep the same high-level behavior as the fork-local Apple workflow:

- natural-language requests still route through
  `apple-appdev-workflow:apple-app-orchestrator`
- domain requests still hand off to the same bootstrap, review, debug,
  release, architecture, accessibility, persistence, product-surface, and
  specialist stations
- route blocks, final `Activated skills`, and brigade summaries keep the same
  owner evidence as fork-local
- deterministic ownership comes from the default-discovered hook and neutral
  policy; retired `routerSelection` metadata is absent
- only the execution adapter changes for operations Xcode already owns

If Xcode-hosted output bypasses the Apple orchestrators and directly behaves
like a generic Xcode tool wrapper, the profile is failing this contract even if
native `xcode-tools` is available.

## Tool Adapter Order

When the active host is Xcode CodingAssistant or the rendered artifact is the
`xcode-headless` profile, use this order for Xcode-owned operations:

1. Xcode native `xcode-tools`.
2. Separate `xcode-proxy` for bridge capabilities missing from native
   `xcode-tools`.
3. Narrow CLI fallback only after the specific host-tool gap is named.
4. `XcodeBuildMCP` only for explicit comparison or diagnosis of that alternate
   path.

`codex-fork-headless` is the deterministic orchestration backend. It is not the
default owner of native Xcode file, build, test, documentation, preview, issue,
or window-context operations.

Default `xcode-proxy` exposure is helper-only. The native proxy may still
support full passthrough transport for diagnostics, but ordinary
Xcode-headless sessions should expose only non-duplicate bridge helpers such as
`XcodeGetCurrentFile` and `XcodeListWindows`. Use explicit full-passthrough
diagnostic mode only when comparing proxy parity or investigating bridge
behavior.

Approval-sensitive adapter calls must be serialized in Xcode. Do not fan out
parallel shell, git, filesystem, native `xcode-tools`, or `xcode-proxy` calls
when any call might need approval or external-agent authorization. A hidden
approval queue is a host-state blocker, not a signal to launch more probes.

`xcode-proxy` availability does not by itself prove distribution readiness. For
local validation, a plugin-runtime `mcp-proxy` dependency may still run through
the developer's current `node`. For an installable Xcode-headless beta, the
proxy must pass the distribution identity gate: use a bundled/signed Node
runtime under the plugin runtime or replace the Node-based proxy with a native
proxy.

A profile-only installer that declares no plugin MCP servers and does not
bundle or claim `xcode-proxy` is narrower than that beta: it may qualify the
native `xcode-tools` workflow baseline independently. The proxy identity gate
becomes mandatory as soon as a package includes, provisions, requires, or
claims the proxy. Keep those results separate in release evidence.

## Operation Mapping

| Fork-local or desktop operation | Xcode-headless adapter |
| --- | --- |
| Project and workspace discovery through XcodeBuildMCP project tools | `XcodeLS`, `XcodeGlob`, `XcodeGrep`, `XcodeGetCurrentFile`, `XcodeListWindows`, and focused project-file reads |
| Scheme, target, and test inventory | `GetTestList`, focused project-file reads, and `XcodeListNavigatorIssues` |
| Build validation such as `build_sim`, `build_macos`, or `build_device` | `BuildProject`; use `GetBuildLog` for failure diagnosis |
| Test validation such as `test_sim`, `test_macos`, or `test_device` | `RunAllTests` or `RunSomeTests`; use `GetTestList` before targeted tests |
| Build log and issue diagnosis | `GetBuildLog`, `XcodeListNavigatorIssues`, and focused `XcodeRead` |
| Xcode-aware source edits | `XcodeRead`, `XcodeUpdate`, `XcodeWrite`, `XcodeMV`, `XcodeRM`, and `XcodeMakeDir` |
| Apple documentation lookups | `DocumentationSearch` when sufficient; `apple-appdev-workflow:fetch-apple-docs` remains available for broader official-doc context |
| Swift package build and test validation | Prefer Xcode-native build/test surfaces when the package is open in Xcode; otherwise use narrow `swift package` CLI fallback and state the host-tool gap |
| Simulator launch, screenshots, UI hierarchy, device evidence, or runtime logs | Use native or proxy Xcode tools only when exposed; otherwise record the missing host capability and hand off to manual validation or narrow CLI evidence |

## Lane Rules

Bootstrap:

- Keep `apple-appdev-workflow:apple-bootstrap-orchestrator` and
  `apple-appdev-workflow:apple-app-bootstrap` as the owners for scaffold and
  adoption work.
- In Xcode ACP, natural greenfield app creation should default to Xcode's
  native New Project flow unless the user explicitly asks for bundle bootstrap
  scripts. The bootstrap lane still owns adoption, harness handoff, repository
  policy, release-intent steering, and validation routing after a project
  exists.
- Outside Xcode ACP and xcode-headless, keep the existing bundle bootstrap
  scripts as the normal scaffold-generation provider.
- After a project exists, validate through `BuildProject`, `RunAllTests` or
  `RunSomeTests`, and `GetBuildLog` before considering CLI fallback.

Review:

- Keep `apple-appdev-workflow:apple-review-orchestrator` as the broad review
  owner.
- Use Xcode-native project, issue, build, and test evidence when fresh
  validation is needed.
- Do not downgrade a broad review into generic file inspection just because the
  host is Xcode.

Debug:

- Keep `apple-appdev-workflow:apple-debug-orchestrator` as the broad debug
  owner.
- Use native Xcode runtime evidence where available.
- If the Xcode host does not expose launch, screenshot, log, or simulator
  interaction tools, name that gap and route the evidence need to the right
  fallback lane instead of pretending the debug contract was satisfied.

Release:

- Keep `apple-appdev-workflow:apple-release-orchestrator` as the release owner.
- Use Xcode-native build, test, issue, and documentation evidence where
  available.
- Treat archive, signing, TestFlight, App Store Connect, and device-only gaps
  as release-operation or manual-validation gaps unless the host exposes a
  native tool that can prove them.

Specialists:

- Specialist station selection does not change in Xcode-headless.
- Only the concrete build, test, documentation, file-edit, or runtime-evidence
  tool calls should adapt to Xcode-native equivalents.

## Prohibited Regressions

- Do not remove bootstrap, review, debug, release, or specialist station
  behavior from Xcode-headless simply because Xcode provides overlapping tools.
- Do not route natural Apple requests directly to `xcode-tools` without the
  Apple top-level owner when the request is broad or multi-step.
- Do not treat absent plugin-declared `XcodeBuildMCP` as a defect in
  Xcode-headless.
- Do not expose proxy duplicates of native `xcode-tools` operations in the
  default Xcode-headless surface. If `xcode-proxy` lists `BuildProject`,
  `RunAllTests`, `DocumentationSearch`, or native file-editing tools, treat the
  proxy as diagnostic/full-passthrough mode rather than the normal host profile.
- Do not claim Xcode-headless parity from static render validation alone; live
  Xcode-hosted smoke evidence is still required after resync.
- Do not claim notarized or distributable Xcode-headless beta readiness while
  live `xcode-proxy` depends on transient, Homebrew, global, ambient, or
  otherwise external Node.
