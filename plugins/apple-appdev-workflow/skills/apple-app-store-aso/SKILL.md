---
name: apple-app-store-aso
description: App Store listing and ASO workflow for Apple apps. Use when optimizing App Store metadata, reviewing listing quality, shaping screenshot messaging, or preparing store-facing positioning updates for release.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple App Store ASO

## Required context
- Load `../../references/app-store-aso-foundations.md`.
- Load `../../references/app-store-metadata-limits.md`.
- Load `../../references/app-store-screenshot-strategy.md` when screenshots or promotional visuals are in scope.
- Load `../../references/app-store-competitive-positioning.md` when positioning or competitor framing matters.
- Load `../../references/app-store-localization-and-ratings.md` when localization, ratings, or category decisions matter.

## Responsibilities
- Own App Store listing strategy and metadata optimization.
- Optimize app name, subtitle, promotional text, keywords, description framing, and screenshot-message strategy.
- Keep recommendations compliant with Apple's character limits and storefront expectations.
- Treat ASO as product-positioning and conversion work, not build or release automation.

## Workflow
1. Confirm the app's audience, value proposition, and release context.
2. Determine whether the task is metadata optimization, listing review, screenshot strategy, competitive positioning, or localization/rating guidance.
3. Generate or review metadata using the limits and ASO references.
4. Keep title, subtitle, keywords, and screenshots aligned around the same positioning story.
5. Activate `apple-appdev-workflow:apple-app-store-release-notes` when the work also includes storefront “What’s New” text.
6. Do not activate `apple-appdev-workflow:apple-decision-stress-test` inside this skill. If storefront positioning still needs challenge-review, recommend a separate isolated stress-test pass.
7. Activate `apple-appdev-workflow:apple-build-release-ops` only when store-facing content work is part of a broader release-prep task.

## Output contract
- Metadata recommendations or review findings
- Character-count awareness and any limit risks
- Screenshot storyboard or messaging sequence when relevant
- Positioning rationale and competitive notes when relevant
- Follow-on validation steps and adjacent skills activated

## Guardrails
- Do not drift into build, archive, upload, or App Store Connect API workflows.
- Do not make external ASO tools or validation scripts a dependency.
- Do not produce keyword stuffing or repetitive metadata that weakens readability.
- Do not recommend storefront claims that conflict with the actual product or release evidence.
