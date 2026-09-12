# Release Provenance

## Apple AppDev Workflow 0.2.2-beta.1

This prerelease payload was rendered from the canonical private `main` source
at the qualified merge commit
`722fda0943993fe2506e3a32dd6b12bbd1c92511` using the `marketplace`
distribution profile. The public repository contains generated distribution
material only; it does not reproduce the private development history or its
control-plane artifacts.

The beta adds authored `macos` and Swift Package prompt provenance while
retaining deterministic, fail-closed UserPromptSubmit routing. It ships the
plugin-owned XcodeBuildMCP 2.7.0 runtime and direct Sosumi MCP configuration;
the hook remains dependency-free `/usr/bin/python3` and native Codex memory is
not replaced by a bundled Memory MCP.

### Behavioral payload hashes

| Surface | SHA-256 |
| --- | --- |
| `hooks/hooks.json` | `5764ee6b8f736cfa9d084681756c26e4fb1bdd22d62cc4d8e630914622cf5ded` |
| `hooks/apple_hook.py` | `4bbc6636f5272becbb99841ee76c05ebe5641079825dd2b580355d26674b6f3c` |
| `hooks/apple_router.mjs` | `8195ca4054b68d9b8815acd38b85cee6a6af7c809fc2e974ba1448255dc657c2` |
| `hooks/apple_contract_guard.mjs` | `895cef34b9c45ca0ae5557fccde5693854def4d33734acd621494e5090dadfe8` |
| `routing/router-policy.json` | `df5d4384e7336784d0ee4df7bcd9618d0368c72e1b26f36703db8a3a217e58ca` |
| `routing/top-level-owner-kernel.md` | `2d00c2577be2174de4aa9b30c7a8f3380e8ded50455dc3d030604d67f7a45949` |
| `.codex-plugin/plugin.json` | `dfed5d8c165d62b153bc791bc78caec3559d53df22fdc2b43f1bc017b44bfd7f` |

### Qualification

- The signed stock Codex Desktop 26.901.51231 / CLI 0.153.4 matrix passed all
  12 cases, including natural macOS and Swift Package prompts, hook trust
  controls, resume, and post-compaction routing.
- The separate Xcode 27 Beta 5 / CLI 0.145.0 companion matrix passed all 11
  cases against the exact rendered hook-only profile.
- The clean Marketplace install gate passed with physical, symlink-free
  payload, plugin-owned XcodeBuildMCP and Sosumi attribution, and no external
  hook runtime dependency.

The separately distributed Xcode companion is paired by version but is not
part of this Marketplace repository or artifact. Its package carries the
official Node LTS runtime required by Xcode's sanitized hook environment.

## Apple AppDev Workflow 0.2.0

The plugin payload in this repository was rendered from the canonical private
source on `main` at commit
`c30409e917a5bcdb02010c0b78b4971c2b3fa42a` using the `marketplace`
distribution profile. The public repository contains generated distribution
material only; it does not reproduce the private development history or its
control-plane artifacts.

The promotion lineage is:

- qualified hook-native topic head:
  `d5ed6961bba3551b8d86e4470e5b80ac09dd6f4f`
- private reconciliation merge:
  `3832a00dfee997e66d6abcc03658b911ca61322c`
- exact post-merge private source:
  `c30409e917a5bcdb02010c0b78b4971c2b3fa42a`

## Behavioral Payload Hashes

These hashes bind the public payload to the stock-Codex qualification:

| Surface | SHA-256 |
| --- | --- |
| `hooks/hooks.json` | `c0b8ef69261c5f61c2fe47609f5f4ffedb68f1736461e033e86fc64f4c01d68d` |
| `hooks/apple_router.mjs` | `df4e1a87faabc7759de483424ad99b3daee265b28bd3e73704236a562ff28073` |
| `routing/router-policy.json` | `1acbd8a3243a4eb470c0400b52e25466ae45405a841014ca53c60cadb1415f49` |
| `routing/top-level-owner-kernel.md` | `2d00c2577be2174de4aa9b30c7a8f3380e8ded50455dc3d030604d67f7a45949` |
| `.codex-plugin/plugin.json` | `121f45d9389549e030d659546516b78a8333266e1cb26ae23495167babc27d15` |

The direct plugin archive is
`AppleAppDevWorkflow-0.2.0-marketplace.zip`, SHA-256
`6ed4f4f2597b4dba02cff67d6112765d7dc64d62f8cce3db32234996c7b84068`.

## Qualification

- 17 hook-router tests passed.
- 110 plugin contract tests passed.
- The signed stock-Codex behavior matrix passed 12 of 12 scenarios.
- A clean Marketplace install and plugin-owned MCP attribution gate passed.
- The public release claim gate passed with `runtime_carry_required: false`.
- The Marketplace, fork-extended, and Xcode-headless profiles rendered and
  validated independently from the same source commit.

The Xcode CodingAssistant compatibility result is separate host evidence. Its
signed installer is intentionally excluded from this Marketplace repository
and archive.
