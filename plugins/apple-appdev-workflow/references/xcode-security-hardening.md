# Xcode Security Hardening Reference

Use this reference when `apple-appdev-workflow:apple-xcode-security-hardening` is auditing Xcode project security posture. The station is audit-first and mutation-gated: inspect, report proposed deltas, ask for approval, then apply only approved changes.

## Audit Surface
- Build settings that affect compiler diagnostics, static analyzer checks, memory safety, pointer authentication, C bounds safety, hardened runtime, sandboxing, signing, and SDK-gated security features.
- Entitlement files that affect sandbox access, hardened runtime exceptions, app groups, keychain access groups, network access, file access, automation, and other capability surfaces.
- Per-target and per-configuration differences, especially Debug versus Release, test targets versus app targets, and app extensions versus containing apps.
- Source files or package settings only when a build setting requires source-level follow-up, such as C bounds safety, C/C++ hardening, allocator usage, or APIs that conflict with stricter warnings.
- C bounds safety adoption and debugging details live in `c-bounds-safety-hardening.md`; load that reference before advising on `-fbounds-safety`, `ENABLE_C_BOUNDS_SAFETY`, `ptrcheck.h`, bounds annotations, or bounds trap diagnostics.

## Tool Mapping
- Prefer XcodeBuildMCP project, scheme, build-setting, build, test, and diagnostics tools when available.
- Use structured parsing for `.pbxproj`, `.xcconfig`, and `.entitlements` files when the MCP surface is insufficient.
- Use shell commands as fallback evidence only, and state that fallback explicitly.
- Do not make Xcode-exported helper names part of this bundle's public contract. This bundle's public surface is the skill, its reference, and the available Codex/XcodeBuildMCP tools.

## Posture Levels
- `likely-safe`: The change is widely expected to improve diagnostics or hardening with low compatibility risk, and can be validated by build or analyze.
- `needs-validation`: The change may expose warnings, affect generated code, or differ by SDK, architecture, dependency, or build configuration.
- `risky`: The change may break binary compatibility, third-party libraries, hardened runtime behavior, entitlements, extension behavior, deployment targets, or release signing.

## Decision Document
When the user asks for a durable record, create or update a project-adjacent decision document, such as an `xcode-security-settings.md` file under that app's own documentation folder. Include:
- project, target, configuration, and SDK inspected
- settings and entitlements enabled
- settings and entitlements explicitly disabled or deferred
- rationale for every disabled or deferred recommendation
- validation commands and results
- follow-up owner or next review date if the project uses those conventions

## Mutation Rules
- Ask before mutation unless the prompt includes exact settings, exact scopes, and explicit authorization to edit.
- Change the smallest owning source of truth. If an `.xcconfig` controls a setting, edit the `.xcconfig` rather than duplicating the value in the project file.
- Preserve existing project structure and configuration-specific intent.
- Keep all changes reviewable in `git diff`.
- Re-read effective settings after mutation instead of assuming the edit took effect.

## Validation
- Re-run XcodeBuildMCP build-setting reads or equivalent structured checks after changes.
- Run `plutil -lint` for changed entitlement plists.
- Run the narrowest relevant build, analyze, test, or archive preflight that proves the setting is accepted by the target.
- For C bounds safety, prefer a header validation file, per-file compile, target build, build-setting readback, or LLDB/crash-log trap evidence depending on the mutation.
- If validation is skipped because tools are unavailable, SDK support is uncertain, or a target requires manual signing/device access, report that gap as residual risk.
