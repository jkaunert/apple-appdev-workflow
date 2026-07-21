# Swift Testing Baseline (Modern)

## Framework preference
- Prefer Swift Testing for new unit and integration tests.
- Use XCTest for UI tests, legacy suites, or tooling gaps.
- When XCTest is used for new tests, document the reason.

## Test construction rules
- Build subject-under-test with explicit protocol-based dependencies.
- Reuse canonical mock/test utility factories when available.
- Avoid duplicating factory/setup helpers without discovery.

## Minimum criteria for new feature work
- At least one Swift Testing unit test for critical logic path.
- At least one negative/error-path assertion.
- Integration or flow test when cross-module behavior changes.

## Concurrency and isolation
- Keep async tests deterministic.
- Validate actor/main-thread boundaries where behavior depends on them.
