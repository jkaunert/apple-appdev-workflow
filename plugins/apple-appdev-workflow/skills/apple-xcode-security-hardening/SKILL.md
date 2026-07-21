---
name: apple-xcode-security-hardening
description: Audit-first Xcode build-setting, diagnostic, entitlement, and security-hardening station for iOS/macOS projects. Use for Enhanced Security posture, compiler or static-analyzer hardening, pointer-authentication and memory-hardening review, C -fbounds-safety adoption audits, ENABLE_C_BOUNDS_SAFETY, ptrcheck.h, bounds annotations such as __counted_by/__sized_by/__ended_by/__single/__unsafe_indexable, bounds trap debugging, and mutation-gated project-setting or native-code recommendations.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Xcode Security Hardening

## Required Context
- Load `../../references/apple-mcp-workflow.md`.
- Load `../../references/xcode-security-hardening.md`.
- Load `../../references/c-bounds-safety-hardening.md` when the request mentions C bounds safety, `-fbounds-safety`, `ENABLE_C_BOUNDS_SAFETY`, `ptrcheck.h`, bounds annotations, C native-code hardening, or bounds trap debugging.
- If the request is broad release readiness, branch review, or app-level hardening, start with `apple-appdev-workflow:apple-app-orchestrator` and let the appropriate review or release orchestrator activate this station.

## Entry Rule
- Use this skill directly only for focused Xcode security posture audits, build-setting hardening, entitlement hardening, static-analyzer or compiler-warning security settings, Enhanced Security review, pointer-authentication review, memory-hardening setting review, or C `-fbounds-safety` audit/planning/diagnostic work.
- Keep this station audit-first. Do not mutate `.xcodeproj`, `.xcworkspace`, `.pbxproj`, `.xcconfig`, `.entitlements`, package, or source files until the user has approved the proposed deltas after seeing the audit.
- If the user asks to "fix" or "apply" security settings, still run the audit and present the proposed changes first unless the prompt already contains exact settings, targets, configurations, and explicit mutation authorization.
- Use current local project settings as the source of truth. Treat Xcode 27 exported skill material as a reference input, not as text or tooling to copy into this bundle.
- Treat C bounds safety as C-header and C-translation-unit hardening. Objective-C, C++, and Objective-C++ are boundary or consumer-risk surfaces unless local compiler evidence proves a specific file participates in the C bounds workflow.

## Workflow
1. Discover the project root, project/workspace, schemes, targets, configurations, platforms, and effective build-setting sources.
   - Prefer XcodeBuildMCP project and build-setting tools when available.
   - Use structured parsing for `project.pbxproj`, `.xcconfig`, and `.entitlements` files when Xcode-aware tools are unavailable or incomplete.
2. Classify the security-hardening surface:
   - compiler diagnostics and security warnings
   - static analyzer checks
   - hardened runtime, sandbox, signing, and entitlement posture
   - Enhanced Security or SDK-conditional settings
   - pointer authentication, readonly platform memory, stack initialization, typed allocator, C bounds safety, and C/C++ hardening posture when relevant to the target
3. Compare current settings against the desired posture for each target and build configuration.
4. Produce an audit table before mutation:
   - setting or entitlement
   - current value and source
   - recommended value
   - scope: project, target, configuration, xcconfig, or entitlement file
   - impact: likely-safe, needs-validation, or risky
   - rationale and validation needed
5. Ask for explicit confirmation before applying any change.
6. After approved mutation, keep edits narrow and reversible:
   - change the smallest source of truth that owns the setting
   - avoid duplicating a setting in both `.pbxproj` and `.xcconfig` unless the project already uses that pattern
   - preserve per-configuration intent
   - record disabled or deferred settings with rationale when the user asks for a decision document
7. Validate after any mutation:
   - re-read effective build settings or entitlements
   - run `plutil -lint` for changed entitlement plists
   - run the narrowest build, analyze, test, or project validation gate available for the touched target
   - report skipped validation explicitly with the reason

## C Bounds Safety Workflow
Use this subflow only after loading `c-bounds-safety-hardening.md`.

1. Classify the request as posture audit, adoption plan, build-setting review, compiler-diagnostic triage, source implementation, or runtime trap debugging.
2. Identify whether the project has C headers, C implementation files, existing `ptrcheck.h` usage, bounds annotations, per-file `-fbounds-safety` flags, or `ENABLE_C_BOUNDS_SAFETY`.
3. For adoption planning, ask whether the user wants full adoption or header-only adoption unless the prompt already makes that explicit.
4. Before source or build mutation, produce a proposed-change table covering files, settings, annotation strategy, validation command, and risk. Ask for approval before applying it.
5. During approved implementation, process small file batches, keep public API ABI compatibility explicit, prefer counted/sized/ended annotations over unsafe escape hatches, and isolate any `__unsafe_indexable` or forge usage with rationale.
6. Validate with the narrowest available proof: header validation file, per-file compile, Xcode build-setting readback, target build, analyzer/test run, or LLDB/crash-log evidence for runtime traps.

## Output Contract
- Routing: `focused subskill`
- Project, targets, configurations, and setting sources inspected
- Current security posture summary
- Recommended deltas with scope, impact, and validation requirement
- Mutation status: not requested, awaiting confirmation, applied, or blocked
- Validation evidence and skipped gates
- Deferred settings and rationale
- Residual risks and next recommendation

## Mutation Gate
Before editing project settings, entitlements, or source files, the response must include a clear proposed-change table and an approval question. If the user approves, preserve the table in the final result with an `applied` or `not applied` status for each row.

## Guardrails
- Do not claim a setting exists in Xcode 27+ unless the local SDK, project build settings, official Apple docs, or an explicit user-provided source proves it.
- Do not enable settings across all targets when only one target was audited.
- Do not collapse Debug and Release configuration differences without checking why they differ.
- Do not weaken signing, sandbox, hardened runtime, or entitlement posture to make a build pass without reporting it as a security regression.
- Do not treat compiler warnings as sufficient security proof; they are one part of the hardening posture.
- Do not present C bounds safety as automatic C++, Objective-C, or Objective-C++ migration.
- Do not treat soft traps as final security hardening; they are an adoption/debugging aid that must be removed for release hardening.
- Do not hide `__unsafe_indexable`, unsafe forge, or ABI-breaking annotation choices in prose. Surface them as explicit risks and validation items.
- Do not make marketplace-facing claims that this station automatically fixes all Xcode security issues. It audits, proposes, applies approved deltas, and validates what local tools can prove.
