# SwiftUI Performance Audit

Use this reference for the default SwiftUI performance workflow.

## Default loop
- measure symptoms
- identify likely causes
- optimize targeted bottlenecks
- re-measure

## Code-first review
When code is available, start by checking:
- broad invalidation fan-out
- unstable identity in lists or tables
- heavy work in `body`
- image decoding or formatting on the main thread
- layout thrash from geometry or preference churn
- large animated hierarchies

## Escalation to profiling
If code review is inconclusive, ask for a narrow Instruments capture tied to the exact interaction that feels slow.
