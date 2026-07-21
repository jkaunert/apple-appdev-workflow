# SwiftUI SDK 27 Compatibility

Use this reference when a SwiftUI task mentions Xcode 27, SDK 27, 2027 OS
targets, post-SDK-update SwiftUI compile errors, or SDK 27 deprecation/source
compatibility work.

## Adoption stance

- Treat Xcode 27 exported Apple Agent skills as official Apple source input
  that this bundle adapts into routed station behavior.
- Do not depend on raw exported folders being present at runtime. Integrate
  important behavior through this bundle's references, triggers, and validation
  gates instead of unmanaged parallel skills or default-loaded export corpora.
- Keep exact API names, overloads, and availability claims gated by local SDK
  evidence or current Apple documentation.
- Prefer source-compatibility fixes before opportunistic adoption of new APIs.
- Preserve behavior unless the user explicitly asks for redesign or new
  platform behavior.
- Add availability checks and fallback behavior when deployment targets still
  include older OS versions.

## Triage

Classify the task before editing:

1. Compile break after SDK update.
2. Deprecation cleanup.
3. Intentional adoption of a new SDK 27 SwiftUI capability.
4. Design-system or adaptive-layout update affected by SwiftUI changes.
5. Document, toolbar, list, grid, image-loading, alert/dialog, or drag/drop
   behavior that changed because the SDK changed.

If the task is broad, start with a narrow audit and list files or patterns that
need follow-up instead of rewriting the whole SwiftUI surface.

## Export-derived topic map

The 2026-06-09 local Xcode 27 export highlighted these SwiftUI areas as worth
checking when the symptoms match:

- state storage and initialization source compatibility
- result-builder or content-builder overload ambiguity
- drag reorder behavior in non-trivial containers
- async image loading and caching behavior
- toolbar visibility, overflow, minimization, and dynamic toolbar content
- item-bound alert and confirmation-dialog presentation
- swipe actions outside the simplest list cases
- document-based app APIs and file-access behavior
- hard and soft deprecation cleanup
- data flow, environment, localization, modifier, animation, and `ForEach`
  best-practice review

Use this map to decide what to inspect. Do not treat it as enough evidence to
write exact code from memory.

## Workflow

1. Identify the installed Xcode/SDK and the deployment targets.
2. Reproduce or inspect the exact compiler diagnostic, deprecation warning, or
   behavior being addressed.
3. Search the local code for the smallest affected SwiftUI pattern.
4. Verify the relevant API shape using local SDK symbols, current Apple docs, or
   an already-reviewed local reference before editing.
5. Apply the narrowest source-compatible change.
6. Keep unrelated visual redesign, architecture cleanup, and API adoption out of
   the same diff.
7. Validate with the smallest build or SwiftSyntax/source check that proves the
   compatibility fix.

## Guardrails

- Do not wholesale-import exported folders in a way that bypasses this bundle's
  routing, trigger, traceability, or validation model.
- Do not claim SDK 27 behavior is stable while the source is beta-only.
- Do not apply a visually plausible fix for a source-compatibility diagnostic
  without checking whether the runtime behavior changes.
- Do not migrate document, toolbar, state, image-loading, or drag/drop code just
  because a new API exists.
- Do not widen this reference into UIKit modernization, C bounds safety, or
  security-hardening guidance.
