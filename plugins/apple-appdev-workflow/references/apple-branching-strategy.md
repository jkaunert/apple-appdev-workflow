# Apple Branching Strategy

## Terminology
- Repository initialization is not a branch policy. Standalone bootstrap creates
  or reuses git provenance before feature work.
- Bootstrap repository policy describes git provenance, the codelines that
  exist immediately after scaffold, and the first legal topic-branch handoff.
- Branch policy describes the ongoing integration, review, protection, and
  merge expectations after the repository exists.
- Forge provider describes the reviewed merge surface: GitHub pull request,
  GitLab merge request, or a generic reviewed branch-merge flow.
- Git worktrees are workspace topology, not a separate branch strategy. Use
  them to keep multiple branches checked out safely without creating loose
  clones, but still follow the same integration, review, and validation policy.

Source framing:
- Martin Fowler's branching patterns emphasize frequent integration and a
  healthy mainline.
- GitHub Flow uses short-lived branches plus pull requests into the default
  branch.
- GitLab Flow keeps feature work on branches, reviews through merge requests,
  and can add production, stable, release, or environment branches when the
  release model needs them.

## Required Branch Policy
- do not perform implementation work directly on `main`
- do not perform implementation work directly on `dev`
- do not perform implementation work directly on `codex/dev`
- do implementation work on a topic branch only

## Expected Flow
1. identify the repo's intended integration branch from discovered policy, tracking branch, or explicit user instruction
2. create or switch to a scoped topic branch from that intended integration branch
3. perform scoped work on that topic branch
4. add or update adequate tests for changed code paths
5. run focused validation until the relevant tests are green
6. run an explicit review pass on the topic-branch diff, not a generic codebase review
7. fix material findings and re-run focused validation until green
8. commit only after review and green validation are complete
9. merge or hand off the topic branch according to the repo's discovered policy

Legacy repositories may still use `main` -> `dev` -> `codex/dev` ->
`codex/<topic>`. Treat that as a repo-local policy, not the default for every
new scaffold.

## Orchestrator Rule
- before mutating an existing repository, confirm the current branch is a topic branch
- if the current branch is an integration/default branch such as `main`, `dev`, or `codex/dev`, create a topic branch from the repo's intended integration branch before editing
- when a standalone scaffold reports `legacy-codex-dev`, the first feature branch must be created from `codex/dev`, not directly from `main` or top-level `dev`
- when a standalone scaffold reports `init-main-only` or `harness-topic-ready`, the first feature branch must be created from the reported intended integration branch before edits begin
- before committing code changes, require a branch-diff review plus adequate, meaningful, green tests for the changed behavior
- before merging back to an integration branch, confirm the branch completed implementation, tests, review, fixes, and re-validation
- a user request to `commit`, `merge`, or `go ahead` is not permission to skip the precommit review-and-validation sequence

## Experiment Branch Hygiene
- keep each pilot or experiment on its own topic branch from a clean base; do not start a new runner, runtime, or lane-contract pilot on top of unrelated dirty branch state
- checkpoint bundle hardening separately before starting runner or runtime experiments so upstream-adjacent pilot branches do not inherit unrelated plugin-contract churn

## Exceptions
- read-only analysis
- planning-only documentation if no repository policy applies yet

## Bootstrap Note
- for brand-new generated repos, initialize the branching model explicitly before feature work begins
- when a standalone scaffold target is not already inside a git repository,
  initialize a new repository on `main` with the initial scaffold commit
- `legacy-codex-dev` may create `dev` from `main`, then `codex/dev` from `dev`, but only when explicitly selected
- no-git scaffolding is not a supported standalone repository policy
- `--repo-policy` is the canonical bootstrap CLI wording; `--branch-policy`
  remains a compatibility alias for older prompts and transcripts
- default forge provider is `github`; use `gitlab` when the user or target repo
  asks for merge-request language, and `generic` only when the forge is
  unknown or intentionally host-neutral
- create the first feature branch from the reported intended integration branch before implementation begins
- do not start feature implementation on the default branch and “fix it later”
