# Swift Testing Foundations

Use this reference for the default structure and assertion model for Swift Testing in Apple projects.

## Default framework policy
- Use Swift Testing for new unit and integration tests.
- Keep XCTest for UI automation, performance metrics, Objective-C-only tests, or confirmed tooling gaps.
- When non-UI XCTest is retained for new coverage, document why.

## Core construction rules
- Import `Testing` in test targets only.
- Prefer suite structs over classes unless class semantics are required.
- Do not inherit from `XCTestCase` for Swift Testing suites.
- Prefer `init()` or `deinit()` patterns over `setUp()` and `tearDown()`.
- Use `#expect` by default and `#require` when later lines depend on a prerequisite value.
- Avoid `XCTAssert*` in Swift Testing unit or integration tests.
- Keep tests readable with clear Arrange-Act-Assert structure.

## Assertion guidance
- State verification is the default.
- Use `#require` to unwrap optionals or stop after prerequisite failure.
- Use throw expectations instead of manual error plumbing when testing failures.
- Avoid macro-hostile boolean negation patterns when a direct comparison is clearer.

## Scope guidance
- Keep each test focused on one behavior.
- Prefer parameterized tests when the logic is identical and only inputs differ.
- Keep test names readable; description strings are fine, and raw identifiers are optional only when the project already prefers them.

## Hard boundaries
- Swift Testing does not replace UI tests in this bundle.
- This skill covers unit and integration tests only.
