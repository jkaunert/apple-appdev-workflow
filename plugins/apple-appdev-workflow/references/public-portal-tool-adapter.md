# Public Portal Tool Adapter

This reference defines the execution-provider contract for the `public-portal`
profile. The profile is intentionally compatible with the public plugin upload
surface: it declares no plugin-managed MCP servers and ships no npm runtime
payload, while preserving the same deterministic hook, routing policy, owner
kernel, skills, and final evidence contracts as the other product profiles.

## Contract

- Deterministic owner selection still comes from the default-discovered
  `UserPromptSubmit` hook. Tool-provider selection must never become a routing
  dependency.
- The absence of plugin-managed MCP servers is expected in `public-portal`.
  Do not diagnose it as a broken install.
- Do not mutate `config.toml`, enable experimental features, or install global
  tools automatically. Those are user-controlled host settings.
- Keep critical project decisions and release evidence in checked-in Markdown.
  Provider-local state is supporting context, not the canonical record.

## Provider Order

### Xcode CodingAssistant

Use Xcode's native `xcode-tools` for project-aware file, build, test,
documentation, issue, preview, and project operations. Apply
`xcode-headless-tool-adapter.md` for the detailed operation mapping.

### Codex Desktop, CLI, and IDE hosts with shell execution

Use the pinned XcodeBuildMCP CLI as the first Xcode-aware provider. The CLI
exposes the package's coverage, debugging, device, logging, macOS, project
discovery, project scaffolding, simulator, simulator management, Swift package,
UI automation, utilities, and Xcode IDE workflows without registering an MCP
server. Its setup/profile surface owns reusable session defaults.

Prefer a matching installed binary only after confirming its version. The
portable pinned form is:

```bash
npx -y xcodebuildmcp@2.3.2 tools --json
npx -y xcodebuildmcp@2.3.2 setup --format yaml
```

After defaults are configured, use the narrow workflow command that answers
the current question. Examples:

```bash
npx -y xcodebuildmcp@2.3.2 simulator test --scheme <Scheme> --derived-data-path /tmp/apple-appdev-deriveddata/<run-id>
npx -y xcodebuildmcp@2.3.2 swift-package test --package-path <PackagePath>
```

Keep build actions serialized and keep DerivedData outside the repository. If
the pinned CLI cannot run because shell execution, network access, the package
cache, or a required host capability is unavailable, name that concrete gap
before using narrow `xcodebuild` or `swift` commands.

### Apple documentation

Keep `apple-appdev-workflow:fetch-apple-docs` as the workflow owner. With no
plugin MCP server, use the pinned Sosumi CLI transport first when the Apple URL
is known:

```bash
npx -y --package='https://github.com/NSHipster/sosumi.ai/archive/refs/tags/v1.0.2.tar.gz' sosumi fetch '<developer.apple.com URL>'
```

Use direct `sosumi.ai` HTTP only when the CLI is unavailable or fails for an
environment reason. Search remains path discovery or last-resort fallback, not
the primary transport.

### Memory and continuity

Use Codex's native local memories when the host exposes them and the user has
enabled them. Native memories can carry useful context from earlier work into
future Desktop, CLI, and connected IDE sessions without a Memory MCP server.
See the official [Memories](https://learn.chatgpt.com/docs/customization/memories)
documentation for availability, storage, and user controls.

Native memory is deliberately optional:

- the plugin does not turn it on or alter its settings
- `/memories` and the host's Personalization settings remain user controls
- generated memory is recall support, not a queryable knowledge-graph API
- required routing, policy, architecture, testing, and release facts remain in
  `AGENTS.md` or checked-in documentation
- when native memory is unavailable, continue from repository evidence rather
  than adding a new persistence dependency

No bundle workflow currently requires explicit Memory MCP graph mutation or
query operations. If a future workflow introduces such a requirement, that is
a new capability decision and must not be silently represented as native-memory
parity.

## Distribution Boundary

The public plugin artifact can carry this policy and the deterministic routing
harness, but it does not run a post-install package manager or provision tools
into Xcode's separate Codex home. Xcode installation remains an explicit,
auditable companion step until Xcode exposes a shared supported plugin install
surface.
