# Git Workflow Specialist

## Purpose

`git-workflow-specialist` is the read-only specialist for repo, branch,
worktree, dirty-state, and source-pair ambiguity. It exists because Apple
AppDev Workflow work often spans more than one surface: plugin source, runtime
carry source, Electron app bundles, extension mirrors, partner forks, generated
scaffolds, and evidence directories.

The specialist reduces accidental branch debt and validation ambiguity. It does
not replace the domain brigade that owns the user-visible Apple work.

## Boundary

This specialist may inspect and recommend. It may not mutate by default.

Allowed by default:

- identify the current git root
- inspect current branch, upstream, ahead/behind, and dirty state
- inspect registered fleet state through `repos.yaml`
- classify dirty files and worktree roles
- recommend branch, commit, patch-archive, source-pair, or validation sequence

Not allowed without explicit user approval:

- `git reset --hard`
- `git clean`
- `git checkout --`
- force-push
- branch deletion
- worktree removal
- stash drop
- deleting generated or evidence directories

## Canonical Local Helper

For this bundle's own repo fleet, run:

```bash
python3 ./scripts/report_git_workflow_state.py --inventory repos.yaml --current-path .
```

The helper is read-only and report-only by default. Use strict mode only when a
CI-like gate should fail on dirty required-clean repos or missing registered
surfaces:

```bash
python3 ./scripts/report_git_workflow_state.py --inventory repos.yaml --current-path . --strict
```

`scripts/check_repo_fleet.py` remains the policy checker. The specialist
report is the operator-facing diagnostic that turns fleet state into
next-action guidance.

## Classification Model

### Work surface

- `protected baseline`: branch should not receive opportunistic edits
- `active task branch`: bounded work owns specific files through `tasks.yaml`
- `candidate validation branch`: package/smoke evidence may depend on this
- `runtime carry branch`: fork-extended carried-runtime behavior or app-server protocol
- `historical/provenance branch`: evidence surface, not active development
- `unregistered worktree`: inspect before using as evidence

### Dirty state

- `current-task intentional`: owned by the active task
- `unrelated user changes`: preserve and avoid staging
- `generated residue`: remove only through an approved cleanup task
- `evidence artifacts`: preserve or move into the correct transcript/ledger path
- `stale or accidental residue`: ask before cleanup
- `unknown`: stop and ask for classification before mutating

## Output Shape

Standalone specialist reports should include:

1. `Git workflow scope`
2. `Registered surfaces`
3. `Current repo and branch`
4. `Dirty-state classification`
5. `Risk assessment`
6. `Recommended next actions`
7. `Commands run`

For orchestrator-led Apple work, the specialist returns only the repo/worktree
facts needed by the active domain lane.

## Integration Notes

In this bundle's source checkout, repo-fleet policy, plugin branch workflow,
task coordination, source-pair evidence, and filesystem surfaces each have their
own control-plane documents or YAML maps. Prefer those source-of-truth files
over chat memory when they are present.
