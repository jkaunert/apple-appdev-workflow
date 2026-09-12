# Privacy Policy

Apple AppDev Workflow is a local Codex plugin bundle.

## Data handling

- Plugin skills, docs, and prompts are stored locally on the machine where the plugin is installed.
- MCP servers or CLI providers selected by the user may access local files,
  Xcode projects, simulators, device metadata, and external services according
  to their own runtime behavior.
- The plugin itself does not operate a hosted backend or collect analytics
  independent of the Codex, MCP, and CLI runtimes the user chooses to enable.

## Third-party services

When enabled by the user, bundled MCP integrations such as Sosumi, Memory, and
XcodeBuildMCP may exchange data with local runtimes or external services
according to those tools' own behavior and policies. The `public-portal`
profile bundles no MCP configuration; it may use pinned Sosumi and
XcodeBuildMCP CLI commands when the host permits shell execution.

Codex native memories are a host-controlled optional feature, not a plugin
backend. When the user enables them, Codex may store and inject local memory
files according to the host's memory settings. The plugin does not enable or
edit native memories automatically.

## User responsibility

Users are responsible for reviewing local Codex configuration, memory settings,
MCP server configuration, CLI commands, and any external service usage before
processing sensitive project data.
