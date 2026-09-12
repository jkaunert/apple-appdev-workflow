# Bundle capabilities

Apple AppDev Workflow coordinates common Apple development work through a
deterministic top-level owner and focused workflow skills.

## Capability Maturity Labels

- `Implemented and validated` — covered by current source and artifact checks.
- `Implemented, guidance-first` — structured guidance is available, but human
  judgment or external execution is still required.
- `Conditional` — depends on the host, OS, Xcode, project, account, or tools.
- `Excluded by design` — intentionally outside the default bundle model.

## Supported workflows

- Natural-language iOS, macOS, and Swift Package requests
- New SwiftUI iOS and macOS app bootstrap
- Non-destructive adoption of existing Xcode projects and Swift packages
- Architecture, implementation, review, debugging, and release-readiness
  guidance
- SwiftUI, UIKit modernization, accessibility, persistence, concurrency, and
  performance guidance
- Swift Testing foundations and focused quality-gate workflows
- UIKit modernization station for existing UIKit projects
- Xcode security-hardening audit and C bounds safety hardening guidance
- Apple documentation lookup through Sosumi

The bundle is guidance-first for decisions that require human judgment,
external credentials, device access, signing, or App Store submission.

## Deterministic routing

A trusted `UserPromptSubmit` hook selects the top-level Apple owner before model
sampling. It recognizes broad Apple intent, explicit plugin and skill text, and
authored macOS and Swift Package signals. The hook fails closed when it is
untrusted, disabled, modified, or blocked by policy.

When hooks are unavailable, use the fully qualified skill form:

```text
$apple-appdev-workflow:apple-app-orchestrator <request>
```

## Host boundaries

- Marketplace Desktop and CLI hosts use plugin-owned Sosumi and XcodeBuildMCP.
- Xcode CodingAssistant uses native `xcode-tools`; the optional companion is
  hook-only and does not provision MCP servers.
- The public-portal profile intentionally contains no plugin-managed MCP
  servers.
- Native Codex memory remains controlled by the active host and is not replaced
  by a bundled Memory MCP.

## Deliberate limits

Greenfield UIKit/AppKit starters, vendor-specific CI/CD, App Store Connect
automation, and heavyweight helper stacks are not default bundle capabilities.
Conditional workflows still depend on the project, host, OS, Xcode, account,
and tool availability.

## Start here

- [Workflow quickstart](WORKFLOW_QUICKSTART.md) for prompt examples
- [MCP setup](MCP_SETUP.md) for server approval and recovery
- [Git workflow guidance](GIT_WORKFLOW_SPECIALIST.md) when branch or worktree
  state matters
