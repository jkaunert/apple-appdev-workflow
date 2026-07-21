# CI Gate Layout

Use this reference for release-oriented CI expectations without tying the bundle to a specific CI vendor.

## Minimum gate order
1. static/config sanity
2. changed-scope unit tests
3. integration tests for boundary and service contracts
4. critical smoke or UI path checks
5. artifact build validation
6. manual validation and release review handoff

## Principles
- fail fast on cheap checks
- keep branch validation narrower than release-candidate validation
- require evidence that maps back to acceptance criteria and release risk
- do not treat CI green alone as ship proof when manual or rollout-sensitive evidence is still missing

## Expected outputs
- which gates must pass before a release candidate exists
- which gates are advisory vs blocking
- what evidence gets attached to the release candidate
