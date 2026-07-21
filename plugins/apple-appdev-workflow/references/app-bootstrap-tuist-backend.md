# App Bootstrap Tuist Backend Pilot Contract

## Status

This reference defines the Tuist backend contract and current executable
surface.

Current executable behavior remains:

- default backend: `xcodegen`
- implemented script backends: `xcodegen` and `tuist`
- Tuist backend: explicit opt-in path behind `--backend tuist`
- Tuist provider: host-provided `tuist` on `PATH`; Mise is recommended
  provider evidence, not a required or plugin-managed install surface
- package-layout support with Tuist: selected local Swift packages under
  `Packages/<Name>/Package.swift`, referenced from `Project.swift` as local
  packages

## Backend Selection

- Use `xcodegen` unless the user or intake contract explicitly selects
  `tuist`.
- Do not auto-select Tuist because `tuist` is installed on the host.
- Do not switch to Tuist because XcodeGen is missing, sandboxed, or failed.
- Do not switch from Tuist back to XcodeGen silently after a Tuist preflight or
  generation failure.
- Treat backend selection as scaffold setup only. It must not change the
  bootstrap brigade owner, repository policy, deployment-target policy, or
  generated handoff responsibilities.

## Tuist Preconditions

A Tuist-selected new-project path must prove:

- `tuist` is available and reports a version, or the run produces a clear
  unsupported-preflight result.
- `mise` availability is reported as provider evidence for project-scoped or
  one-off Tuist management. Missing `mise` is advisory only and must not fail a
  Tuist run when `tuist` itself is already available.
- the selected platform, UI framework, deployment target, app name, bundle id,
  and output directory are already confirmed under the normal bootstrap intake
  rules.
- the destination is safe for scaffold generation under the same empty-path
  rules as the default backend.
- the requested layout is either `single-target` or `app-plus-packages` with
  generated local packages only.
- any command that could open Xcode, prompt interactively, connect to a remote
  service, resolve dependencies over the network, or mutate release
  infrastructure is either avoided or explicitly approved.

## Provider Policy

The Phase 3A pilot does not install, update, or vendor Tuist. It expects
`tuist` to be resolvable in the executing environment and records the observed
Tuist version as evidence.

Mise is the recommended host-level provider because it supports project-scoped
or one-off tool resolution without requiring a permanent global Tuist install.
However, missing Mise is not a failure when `tuist` itself is available and
version probing succeeds.

For installed Electron validation, the app-server process must inherit a
`PATH` that resolves the intended `tuist` executable. Temporary wrapper-based
validation is acceptable when the candidate app is launched from the canonical
isolated launcher with the wrapper directory on `PATH`.

Do not add plugin-managed Tuist installation, `--tuist-bin`, or a tool-runner
override unless new evidence shows the `PATH` contract is unreliable in the
installed runtime, or marketplace packaging requires a plugin-owned provider
surface.

Tuist docs present `tuist init` as the generated-project entrypoint and note
that it can also integrate an existing Xcode project or workspace. Phase 3A must
verify a non-interactive automation shape before using that path in the bundle.
If `tuist init` cannot be made deterministic for this plugin, generate minimal
skill-owned Tuist manifests and validate them with `tuist generate --no-open`
instead.

## Allowed Command Surface

The Tuist backend may use these command classes after preflight:

- `tuist version` for availability and version evidence.
- `mise --version` for advisory provider evidence.
- `tuist generate --no-open` to produce a workspace without opening Xcode.
- local package graph resolution as part of `tuist generate --no-open` when the
  graph contains only bootstrap-generated local packages.
- `xcodebuild` or `XcodeBuildMCP` against the generated workspace for build and
  test validation.

The Tuist backend may mention, but must not execute by default:

- `tuist install`, because current bootstrap does not generate external
  package dependencies.
- `tuist edit`, because it opens an editor/Xcode flow.
- `tuist graph`, because it can emit and open graph artifacts that are useful
  for human review but not required for scaffold generation.
- Tuist Cloud, registry, cache, previews, selective testing, or test-insights
  setup.

## New-Project Output Contract

A Tuist-backed scaffold must preserve the same user-confirmed inputs as the
default backend:

- app name
- bundle identifier
- platform
- UI framework
- deployment target and provenance
- package layout selection, including selected local packages when
  `app-plus-packages` is explicit
- repository policy
- release-intent handoff context

Generated docs must record:

- selected backend and Tuist version evidence
- backend provider evidence, including whether `mise` was available
- commands executed
- commands intentionally not executed
- validation handoff to `XcodeBuildMCP` or raw `xcodebuild` fallback
- downstream owners for release, ASO, App Store Connect, CI/CD, signing,
  metadata, screenshots, manual validation, and quality gates when release
  intent was declared

When generating a skill-owned Tuist manifest, create a minimal `Tuist/` root
marker before `tuist generate --no-open`. Tuist uses a `Tuist/` or `.git`
directory to resolve the project root, and bootstrap initializes git only after
backend generation succeeds.

## Adopt-Mode Contract

For existing Tuist projects, adopt mode may report:

- manifest presence, such as `Tuist.swift`, `Project.swift`, and
  `Tuist/Package.swift`
- generated workspace or project presence
- likely schemes and validation commands
- dependency-resolution and generation risks

For existing Xcode projects, Tuist migration remains report-only unless the
user explicitly requests migration work after bootstrap concludes. Bootstrap may
identify Tuist as a suitable follow-on path, but it must not rewrite project
manifests, delete project files, or replace the build graph during ordinary
adoption.

## Failure Modes

Fail clearly and non-destructively when:

- Tuist is missing or version probing fails.
- the host lacks required Xcode or Swift tooling.
- the selected command path is interactive-only.
- Tuist attempts or requires remote account setup, cloud features, registry,
  cache, previews, selective testing, or test-insights configuration.
- dependency resolution would require network access without explicit approval.
- generated workspace validation cannot start because project generation did
  not produce the expected artifacts.
- the selected platform, UI framework, package layout, or release-intent
  combination has no tested Tuist template.

Do not treat these as permission to mutate a fallback backend or to continue
with partial generated state.

## Out Of Scope For Current Tuist Bootstrap

- Tuist as the default backend.
- Tuist Cloud account setup.
- registry, cache, previews, selective testing, or test-insights setup.
- external package dependencies and `tuist install`.
- Fastlane, GitHub Actions, or other CI config generation.
- App Store Connect config generation.
- signing certificate, profile, keychain, or team mutation.
- screenshot or metadata generation.
- product feature implementation after scaffold generation.

## Handoff Owners

After a successful Tuist-backed scaffold, validation and follow-on ownership
remain the same as the default backend:

- `apple-appdev-workflow:apple-bootstrap-orchestrator` owns bootstrap summary
  aggregation.
- `apple-appdev-workflow:apple-app-bootstrap` owns scaffold or adoption
  execution.
- `XcodeBuildMCP` owns project-aware validation where available.
- `apple-appdev-workflow:apple-release-orchestrator` owns release readiness.
- `apple-appdev-workflow:apple-build-release-ops` owns archive, signing, and
  CI/CD follow-up.
- `apple-appdev-workflow:apple-app-store-aso` owns store metadata,
  screenshots, privacy, and positioning follow-up.
- `apple-appdev-workflow:apple-app-store-release-notes` owns user-facing
  changelog follow-up.
- `apple-appdev-workflow:apple-manual-validation` and
  `apple-appdev-workflow:apple-testing-quality-gates` own validation follow-up.
