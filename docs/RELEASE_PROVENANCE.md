# Release Provenance

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
