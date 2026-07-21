# Swift Testing Organization

Use this reference for parameterized tests, traits, tags, availability placement, and Xcode workflow guidance.

## Parameterization
- Prefer parameterized tests when behavior is the same and inputs vary.
- Avoid cartesian explosion when multiple argument collections are used.
- Prefer zipped or named-case inputs when pairwise intent matters.

## Traits and tags
- Use tags for stable cross-suite grouping and test-plan filtering.
- Use traits for behavior and metadata such as disabling, time limits, bugs, or serialization.
- Keep disabled tests actionable with a reason, and attach bug context when possible.
- Apply traits or tags at the narrowest correct scope.

## Availability placement
- Put `@available` on test functions, not on entire suites, when the behavior is OS-gated.

## Xcode workflow
- Prefer tag-based grouping and filtering over fragile naming conventions.
- Use parameterized test reruns at the failing-argument level for fast iteration.
- Keep test-plan organization aligned with team workflows such as core, integration, and release-gate plans.
