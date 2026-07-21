# Swift Concurrency Migration

Use this reference for Swift 6 and strict-concurrency rollout.

## Migration policy
- migrate incrementally with minimal blast radius
- build, fix, rebuild, and only proceed when clean
- do not combine concurrency migration with unrelated refactors unless explicitly requested

## Rollout guidance
- start with isolated files, modules, or targets
- update dependencies before interpreting migration noise
- prefer async alternatives before rewriting whole implementations
- treat default actor isolation and approachable concurrency as project-level behavior choices, not local code hacks
