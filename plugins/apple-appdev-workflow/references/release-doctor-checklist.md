# Release Doctor Checklist

Use this checklist to decide whether the current release candidate has enough human validation to support a ship recommendation.

## Core checklist
- install or update succeeds cleanly
- cold launch succeeds
- resume from background behaves correctly
- the primary user journey completes without trust-breaking issues
- destructive actions have clear confirmation and recovery behavior
- empty, offline, and failure states remain understandable
- permissions prompts and recovery wording match the current product behavior
- export, import, share, or file workflows behave correctly where relevant
- UI and exported or shared artifacts stay consistent where the feature depends on both

## Trust checks
- no trust-breaking regression in the changed flow
- no misleading status, permissions, privacy, or sync language
- no release-critical mismatch between simulator confidence and device behavior
- no high-confidence release claim without supporting manual evidence

## Exit rule
- If the top user journey, the top risky capability, or the top trust surface is still pending manual validation, ship readiness remains pending.
