# App Bootstrap Generated Docs

## Purpose
Ensure generated bootstrap docs produce useful next-step guidance instead of a generic starter note.

## Required README Content
- baseline assumptions
- layout summary
- package guidance when packages are present
- explicit handoff into architecture, design, implementation, testing, observability, and manual validation workflows
- the applied repository policy and the next topic-branch step before feature work
- forge-provider handoff language for GitHub pull requests, GitLab merge
  requests, or a generic reviewed branch-merge flow

## Final Summary Surfacing
- For greenfield scaffolds, the final bootstrap `Files created or assessed` section must include clickable links to both generated docs:
  `README.md` and `docs/HARNESS_HANDOFF.md`, with absolute path targets and optional `:1` line anchors.
- Do not rely on generic prose such as "created README and docs"; the Electron UI should surface the docs as openable outputs.

## Tone
- practical
- short
- not aspirational
- no false claims about ship readiness or automation completeness

## Guardrails
- generated docs must reflect the actual scaffold and current bundle behavior
- do not describe starter capabilities that are not actually generated
- keep the handoff aligned to Apple bundle skills and `XcodeBuildMCP`
- do not imply extra editor integrations, workspace wrappers, or package layouts unless those were explicitly requested and actually generated
- do not prescribe `dev` plus `codex/dev` unless the scaffold was generated with the explicit `legacy-codex-dev` repository policy
