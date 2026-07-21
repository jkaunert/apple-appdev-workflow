---
name: codebase-archaeology
description: Reconstruct how a codebase, plugin bundle, runtime fork family, or mixed host/runtime workspace got to its current state. Use when current behavior depends on historical decisions across repos, branches, docs, transcripts, caches, or runtime surfaces, and you need a grounded explanation of what was tried, kept, thrown away, and why.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Codebase Archaeology

## Required context
- Load skill-local `references/evidence-ladder.md`.
- Load skill-local `references/output-patterns.md`.

## Entry rule
- Use this skill when the main task is reconstruction, not implementation:
  - how did this system get here
  - which branch or repo is source of truth
  - what changed, was reverted, or was normalized later
  - why docs, code, runtime, or host behavior disagree
  - which fixes were durable product decisions versus temporary probes or workarounds
- Use it for single repos, sibling repo families, plugin bundles, runtime forks, deployment surfaces, host integrations, or mixed workspace archaeology.

## Workflow
1. Define the archaeology target precisely:
   - the behavior, contract, lane, subsystem, or regression in question
   - the surfaces that may matter: repo, runtime fork, plugin cache, host app, CI, docs, or user config
2. Build the surface map before drawing conclusions:
   - identify the active repo or workspace root
   - identify sibling repos, worktrees, or forks that may preserve earlier or alternate states
   - identify installed or live runtime surfaces separately from checked-in source
   - identify host surfaces separately from runtime surfaces
3. Establish the present-state baseline first:
   - inspect current checked-in code, config, metadata, validators, and live artifacts
   - verify branch names and current heads
   - record any current source-of-truth pairings explicitly
4. Walk history backward with the smallest useful scope:
   - inspect commit history for the files or docs that define the current contract
   - trace key flags, prompts, validators, templates, or routing rules through the relevant commits
   - compare sibling branches only where they answer a concrete lineage question
5. Recover intent from secondary evidence:
   - checked-in plans, decision records, smoke findings, transcripts, and probe scripts
   - out-of-repo session logs, issue threads, or host notes only when needed and clearly labeled as external evidence
6. Reconcile contradictions using the evidence ladder:
   - separate present truth from historical intent
   - separate durable product decisions from runtime-survival experiments
   - separate bundle behavior from runtime behavior and host behavior
7. Synthesize the result as a system reconstruction:
   - lineage and historical phases
   - what was tried
   - what was kept
   - what was rejected, demoted, or left as canary-only
   - what is still genuinely unsettled
8. End with decision-useful guidance:
   - what should stay the same
   - what should change
   - what still needs validation
   - which repo/runtime/host pair should be treated as the next scoring surface

## Output contract
- Default to a reconstruction memo that includes:
  1. `Scope`
  2. `Evidence base`
  3. `Current source of truth`
  4. `Historical phases` or `Lineage`
  5. `What was tried`
  6. `What stayed`
  7. `What was rejected or demoted`
  8. `Current drifts or open questions`
  9. `Implications` or `Next moves`
- When the user wants a narrower artifact, adapt the output but preserve the same underlying logic.
- Name the repo branch, runtime branch, and host surface whenever a conclusion depends on them.

## Guardrails
- Do not treat current docs as more authoritative than current code, validators, or verified live runtime behavior.
- Do not treat current parser defaults or current loader behavior as proof that historical policy states were behaviorally equivalent.
- Do not reason from one repo when sibling repos or forks clearly preserve alternate states.
- Do not collapse bundle, runtime, installed-cache, and host-app behavior into one undifferentiated surface.
- Do not claim provenance or upstream influence unless the linkage is explicit.
- Do not mistake missing `reports` or `experiments` directories for missing evidence; use the equivalent local surfaces that actually exist.
- Do not turn the result into a raw changelog dump. Synthesize phases, decisions, and implications.
- Do not overstate certainty. If the evidence is incomplete, say what is known, what is inferred, and what remains unresolved.
