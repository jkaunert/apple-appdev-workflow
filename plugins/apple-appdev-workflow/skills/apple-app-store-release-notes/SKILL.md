---
name: apple-app-store-release-notes
description: App Store release-notes workflow for Apple apps. Use when creating or reviewing user-facing “What’s New” text from real product changes for App Store submission.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple App Store Release Notes

## Required context
- Load `../../references/app-store-release-notes.md`.
- Load `../../references/app-store-release-notes-qa.md`.
- Load `../../references/apple-mcp-workflow.md` only when release-range collection or repo-state context is relevant.

## Responsibilities
- Own user-facing App Store “What’s New” text.
- Turn real user-visible changes into short, benefit-focused release bullets.
- Filter out internal-only work, refactors, tooling, and implementation jargon.
- Keep release notes concise, storefront-appropriate, and traceable to real changes.
- Keep the source basis explicit when notes are grounded in a dirty working tree or uncommitted branch state.

## Workflow
1. Determine the source change range or release scope.
2. Check whether the notes are grounded in committed history, a staged diff, or a dirty working tree.
3. If material user-visible changes are still uncommitted, treat the notes as provisional and recommend a checkpoint commit before App Store submission or branch-grounded reuse.
4. Identify user-visible changes and group them into the smallest meaningful themes.
5. Draft short benefit-focused bullets and remove internal-only or duplicate items.
6. Apply the QA checklist before finalizing.
7. Activate `apple-appdev-workflow:apple-app-store-aso` when release notes are part of a larger App Store listing refresh.
8. Activate `apple-appdev-workflow:apple-build-release-ops` when release notes are being prepared as part of release packaging work.

## Output contract
- Final App Store “What’s New” bullets
- Source basis for the notes when it is not obvious from the request
- Any ambiguity or coverage gaps called out explicitly
- Provisional-state note when the bullets are grounded in uncommitted changes
- Notes about excluded internal-only changes when relevant
- Adjacent skills activated when release notes are part of a broader release-prep task

## Guardrails
- Do not include internal jargon, tickets, file paths, or implementation details.
- Do not invent user-facing changes from ambiguous commits.
- Do not turn release notes into marketing copy or a long-form changelog.
- Do not rely on helper scripts or git-history automation as a required dependency.
- Do not present notes derived from a dirty working tree as though they were already grounded in a stable committed branch state.
