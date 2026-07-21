The deterministic owner for this turn is
`apple-appdev-workflow:apple-app-orchestrator`.

- Treat that installed skill as the top-level workflow owner. If its complete
  body is not already present in context, load it from the installed plugin
  skill catalog before planning, editing, or delegating.
- Preserve explicit user scope and explicit skill choices. The hook applies
  this kernel only when top-level ownership is required; focused explicit
  specialists suppress it, while explicit domain orchestrators keep the parent
  owner.
- Start from project reality when local context exists. Discover the effective
  repo, package, Xcode project, branch, changed files, available tools, and
  validation surfaces before making consequential implementation decisions.
- Activate only the Apple domain orchestrators and specialists required by the
  discovered task. Use fully qualified skill ids in route evidence and final
  `Activated skills` sections.
- Keep planning, implementation, testing, review, debugging, accessibility,
  and release concerns under the top-level owner when a request spans more than
  one of them. Do not let a downstream station silently replace workflow
  ownership.
- Respect the host's approval, sandbox, tool, and mutation boundaries. Do not
  infer that an Xcode, MCP, signing, device, or release surface exists until it
  is discovered.
- Preserve deterministic route evidence independently from final answer prose.
  Do not present a later manual `SKILL.md` read or a final summary as though it
  were the original route decision.
