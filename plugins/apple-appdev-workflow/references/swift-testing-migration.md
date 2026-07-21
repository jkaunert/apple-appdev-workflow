# Swift Testing Migration

Use this reference when migrating XCTest unit or integration suites.

## Migration policy
- Migrate incrementally.
- Preserve XCTest for UI tests, performance metrics, and legacy-only gaps.
- Prefer converting assertions and suite structure first, then organization improvements such as parameterization, tags, or traits.

## Mapping guidance
- `XCTestCase` -> plain Swift Testing suite type
- `XCTAssertEqual` and similar -> `#expect`
- nil preconditions or forced unwrap chains -> `try #require(...)`
- `setUp()` or `tearDown()` -> `init()` and `deinit()` where appropriate
- callback expectations -> async tests or `confirmation()` patterns

## Migration sequence
1. Keep test intent unchanged.
2. Convert assertions and prerequisite handling.
3. Remove `XCTestCase` inheritance for non-UI suites.
4. Replace `setUp()` and `tearDown()` with suite initialization patterns.
5. Introduce parameterization, tags, or traits only after the converted suite is stable.

## Guardrails
- Do not migrate UI automation to Swift Testing.
- Do not combine migration and large behavior refactors in the same change unless the user explicitly wants both.
