# Apple AppDev Workflow

Apple AppDev Workflow is a Codex Marketplace plugin for building, reviewing,
debugging, and releasing iOS and macOS apps. Its defining behavior is
deterministic, pre-sampling top-level routing: a trusted `UserPromptSubmit`
hook classifies broad Apple-development prompts and injects the owning workflow
before the model responds.

Version `0.2.0` runs that routing path on stock Codex without the retired
fork-only `routerSelection` carry. Fully qualified skill invocation remains the
explicit fallback when hooks are disabled, declined, changed, or restricted.

## Install

Add this Git marketplace with a plugin-capable Codex CLI:

```bash
codex plugin marketplace add jkaunert/apple-appdev-workflow --ref main
```

Then open Codex Settings, choose Plugins, find **Apple AppDev Workflow by
Joshua Kaunert**, and install **Apple AppDev Workflow**. Review and trust the
routing hook, and approve the plugin-declared MCP servers when Codex asks.

Start a fresh chat after installation. A natural request such as
`Review this iOS branch before merge` should route automatically. The explicit
equivalent is:

```text
$apple-appdev-workflow:apple-app-orchestrator Review this iOS branch before merge.
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
