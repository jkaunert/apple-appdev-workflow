# C Bounds Safety Hardening

Use this reference behind `apple-appdev-workflow:apple-xcode-security-hardening`
when auditing, planning, implementing, or debugging C `-fbounds-safety`
adoption.

This reference adapts the Xcode 27 exported C bounds safety material into this
bundle's audit-first hardening model. Do not assume the raw exported folder is
available at runtime, and do not default-load its full reference corpus. Keep
all source and build mutation behind the security-hardening station's proposed
delta table and explicit user approval.

## Scope

- `-fbounds-safety` is a C hardening workflow for C headers and C translation
  units.
- Objective-C, C++, and Objective-C++ are relevant as consumers, wrappers,
  mixed-target neighbors, or build-system risk, but do not claim automatic
  migration for those languages.
- Xcode's `ENABLE_C_BOUNDS_SAFETY=YES` setting applies `-fbounds-safety` to C
  files. Do not model it as a blanket native-code flag.
- ABI compatibility is a first-class requirement for public headers. Avoid
  ABI-breaking pointer kinds on consumer-facing APIs unless local evidence and
  user approval justify the break.

## Request Classes

Classify the request before making recommendations:

| Class | Output shape |
| --- | --- |
| Posture audit | Current settings, candidate C files/headers, existing annotations, and risks. |
| Adoption plan | Full versus header-only recommendation, file order, validation plan, and proposed stop points. |
| Build-setting review | Per-target/per-config `ENABLE_C_BOUNDS_SAFETY`, per-file flags, soft-trap settings, and build validation. |
| Diagnostic triage | Compiler diagnostic grouped by annotation, API-surface, pointer-arithmetic, or unsafe-interop issue. |
| Runtime trap debugging | LLDB/crash-log evidence, trap mode, optimized-build caveats, and next debug flag or symbol step. |
| Source implementation | Explicitly approved small-batch edits with compile/build/test proof or skipped-gate rationale. |

## Adoption Choices

Ask the user to choose an adoption mode before implementing when the prompt did
not already choose one.

- Full adoption: annotate headers and compile implementation files with
  `-fbounds-safety`. This gives compile-time and runtime enforcement but needs
  iterative diagnostics and builds.
- Header-only adoption: annotate public headers while leaving implementations
  outside `-fbounds-safety`. This helps clients adopting the mode and is lighter
  when implementation migration is not ready.

For full adoption, prefer an incremental order:

1. inspect public and private headers, C implementation files, existing build
   settings, and tests
2. annotate headers first
3. add or identify a header validation compile target/file
4. adopt implementation files in small batches
5. switch target-level setting only after per-file adoption is proven
6. remove temporary debugging aids before release hardening

## Annotation Guidance

Prefer annotations that express real contracts:

- `__counted_by(count)` for element counts
- `__sized_by(size)` for byte counts or variable-sized objects
- `__ended_by(end)` for begin/end ranges
- `__counted_by_or_null` and `__sized_by_or_null` when null is allowed
- `__null_terminated` or `__terminated_by(value)` for sentinel-terminated data
- `__single` for one object or null

Avoid reaching for unsafe or ABI-breaking constructs by default:

- Treat `__unsafe_indexable` as an escape hatch requiring rationale, owner, and
  follow-up.
- Use `__bidi_indexable` or `__indexable` only where ABI visibility makes that
  safe, usually internal implementation details.
- Preserve public ABI unless the user explicitly accepts the break.
- For public APIs whose natural bounds cannot be expressed in the existing
  signature, prefer a safe-wrapper plan over hiding the risk.
- Include `<ptrcheck.h>` where annotations or helper functions are used, and
  validate that non-`-fbounds-safety` builds still parse when the file is meant
  to support both modes.

## Build Settings And Debugging

Useful settings and flags:

- `ENABLE_C_BOUNDS_SAFETY=YES`: Xcode target/config setting for C files.
- per-file `-fbounds-safety`: safer for incremental adoption.
- `-ferror-limit=0`: useful while collecting diagnostics.
- `-fbounds-safety-unique-traps`: keeps optimized-build traps distinguishable.
- `CLANG_BOUNDS_SAFETY_SOFT_TRAPS=call-minimal` or
  `-fbounds-safety-soft-traps=call-minimal`: adoption/debug aid only, not final
  release hardening.

When debugging runtime traps:

- Prefer unoptimized builds with debug info.
- In LLDB or crash logs, look for bounds-check trap reasons when available.
- In optimized arm64 builds, a `brk #0x5519` stop is consistent with a bounds
  safety trap, but still report the evidence level and symbol/debug-info limits.
- Wide pointer bounds may be unavailable or misleading in optimized debugging.

## Validation

Match validation to the mutation:

- Header annotations: compile a validation file that includes adopted headers
  with `-fbounds-safety`.
- Per-file adoption: compile the changed C file with `-fbounds-safety`, then
  run the narrowest target build or tests available.
- Target setting changes: re-read effective build settings and run a target
  build.
- Runtime trap work: capture LLDB stop reason, crash-log frame, disassembly, or
  soft-trap output as appropriate.
- Public API wrapper changes: compile both adopted and non-adopted caller
  paths when available.

If validation cannot run because the SDK, target, signing, fixture, or native
toolchain is unavailable, report the skipped gate as residual risk. Do not
present the migration as complete.

## Output Requirements

For audits, report:

- files/settings inspected
- existing C bounds safety signals
- recommended adoption mode
- proposed deltas and validation gates
- risks around ABI, unsafe annotations, mixed-language consumers, and runtime
  trap observability

For implementation, report:

- approved changes applied
- files intentionally skipped with reasons
- unsafe or ABI-sensitive choices
- validation run and skipped gates
- follow-up before release hardening
