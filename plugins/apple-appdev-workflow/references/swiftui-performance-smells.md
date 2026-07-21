# SwiftUI Performance Smells

Use this reference to audit common SwiftUI runtime bottlenecks.

## High-value smells
- unstable identity in `ForEach`, lists, or tables
- filtering, sorting, formatting, decoding, or allocation work inside `body`
- broad observable dependencies that fan out updates to large trees
- top-level conditional branch swapping that causes identity churn
- layout thrash from `GeometryReader`, preference chains, or deep dynamic stacks
- large images rendered without downsampling
- over-animated hierarchies or implicit animations on large subtrees
- main-thread work long enough to create hangs or hitches

## Default fixes
- narrow state ownership
- stabilize identity
- precompute or cache expensive work
- downsample images before rendering
- simplify layout dependencies
- reduce update fan-out by extracting smaller views or using more granular observable state
