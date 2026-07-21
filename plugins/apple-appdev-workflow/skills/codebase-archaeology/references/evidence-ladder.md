# Evidence Ladder

Use this order of trust unless the user asks for a different framing.

## Tier 1: Present-state truth

These answer what is true now.

1. checked-in code, config, metadata, validators, and scripts
2. verified live runtime behavior
3. verified installed-cache or deployment artifacts
4. verified branch names and commit heads

If Tier 1 contradicts older docs, the docs describe history or drift, not the
present state.

## Tier 2: History with source control

These answer when and where a contract changed.

1. commit history for the defining files
2. branch ancestry and worktree lineage
3. tagged baselines, checkpoints, and merge-base comparisons

Use this tier to locate inflection points and distinguish one-time experiments
from later normalization.

## Tier 3: Intent and interpretation

These explain why a change was made or how it was supposed to behave.

1. checked-in plans
2. decision records
3. smoke findings
4. transcripts
5. probe and validation scripts

This tier is strong for intent, but weaker than code for present-state truth.

## Tier 4: Sibling surfaces

These preserve alternate or earlier realities.

1. sibling repos
2. experimental branches
3. forked runtime lines
4. adoption or upstream probe worktrees

Use this tier when one repo alone cannot explain the full system history.

## Tier 5: External or ambient evidence

These are often necessary, but should be labeled clearly.

1. local session logs outside the repo
2. host-app state and caches
3. issue threads and PR discussions
4. local notes or ad hoc operator artifacts

Treat these as external evidence and distinguish them from checked-in project
truth.

## Contradiction rules

1. First decide whether the contradiction is about present state, historical
   intent, runtime behavior, or host behavior.
2. Prefer present-state truth over stale documentation for "what is true now."
3. Prefer source-control history over memory for "what changed when."
4. Prefer named, verified surfaces over generic labels such as "the runtime" or
   "the fork."
5. If two surfaces disagree, name both explicitly instead of flattening them
   into one conclusion.
