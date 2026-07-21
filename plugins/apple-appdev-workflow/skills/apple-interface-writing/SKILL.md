---
name: apple-interface-writing
description: Interface-copy workflow for Apple apps. Use when writing, reviewing, or rewriting end-user text inside screens, settings, alerts, dialogs, errors, onboarding, empty states, buttons, or other product surfaces.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Interface Writing

## Required context
- Load `../../references/interface-writing-patterns.md`.
- Check project-local voice or terminology guidance before rewriting copy.
- Load `../../references/apple-mcp-workflow.md` only if current Apple HIG wording guidance is relevant.

## Responsibilities
- Own interface copy inside Apple product surfaces.
- Keep wording clear, concise, localizable, accessible, and consistent with the product voice.
- Review and improve alerts, errors, destructive flows, settings labels, onboarding text, empty states, and action labels.
- Flag terminology drift and ambiguous or inaccessible phrasing.

## Workflow
1. Determine the copy surface and user goal.
2. Reuse any existing voice, terminology, or platform wording conventions when present.
3. Apply the narrowest relevant pattern reference for the copy type.
4. Prefer specific rewrites with brief rationale over abstract advice.
5. Activate `apple-appdev-workflow:apple-accessibility-foundations` when labels or spoken descriptions materially affect accessibility.
6. Activate `apple-appdev-workflow:fetch-apple-docs` only when current Apple wording or HIG guidance materially affects the recommendation.

## Output contract
- Original text when relevant
- Recommended rewrite
- Short rationale tied to clarity, tone, localization, or accessibility
- Any terminology or consistency follow-ups

## Guardrails
- Do not drift into marketing copy, release notes, app-store listings, or long-form editorial writing.
- Do not use personality where clarity and directness are more important.
- Do not recommend copy that depends on narrow cultural references or fragile abbreviations.
- Do not let `apple-appdev-workflow:apple-product-surface-orchestrator` lose final-answer ownership when broad product-surface brigade routing is active.
- When `apple-appdev-workflow:apple-product-surface-orchestrator` is active, return evidence upward only; do not emit the final user-facing answer.
- Keep action labels specific and user-facing, not implementation-facing.
