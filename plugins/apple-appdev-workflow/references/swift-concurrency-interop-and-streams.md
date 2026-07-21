# Swift Concurrency Interop and Streams

Use this reference when bridging legacy APIs or handling stream-like async work.

## Bridging rules
- Prefer async wrappers over new callback-first code.
- Audit continuations so every path resumes exactly once.
- Prefer modern async stream factories where available.
- Finish async streams on all cleanup and termination paths.

## Interop rules
- Prefer Swift concurrency over GCD for new application-level code.
- Keep GCD, locks, or framework-specific threading where low-level interop genuinely requires it.
- Treat Core Data, delegate APIs, and Combine bridges as boundary-sensitive code that needs explicit ownership.
