# SwiftUI Performance Instruments

Use this reference when code review alone is insufficient.

## Profiling workflow
- Profile a Release build.
- Use the SwiftUI template with SwiftUI timeline, Time Profiler, and hangs or hitches where relevant.
- Reproduce the exact slow interaction.
- Inspect long view body updates, other long updates, update groups, and hitch or hang evidence.
- Correlate slow update ranges with Time Profiler.

## What to ask from the user
- trace export or screenshots of the SwiftUI timeline lanes
- Time Profiler call tree for the slow interaction
- device, OS, and build configuration
- reproduction steps and expected behavior
