# Swift Testing Modernization

Use this reference when the user asks to modernize, migrate, convert, update,
or review existing unit or integration test structure.

This reference adapts the Xcode 27 exported `test-modernizer` material into the
bundle's `apple-swift-testing-foundations` station. Keep it as a focused
modernization reference: do not default-load it for brand-new tests, ordinary
test execution, UI automation, performance-test work, or unrelated failure
debugging.

## Scope

- Modernize existing Swift Testing tests or XCTest unit/integration tests.
- Keep behavior and coverage intent stable unless the user explicitly asks for
  new coverage.
- Leave UI automation, performance tests, Objective-C-only test surfaces, and
  confirmed legacy tooling gaps in XCTest.
- A file may stay mixed during incremental migration when that is the smallest
  safe step.

## Migration Flow

1. Classify each changed file as XCTest migration, Swift Testing cleanup, mixed
   incremental migration, or retained XCTest.
2. Preserve imports deliberately. Replace `import XCTest` with `import Testing`
   only when the file no longer needs XCTest. Add `Foundation` if the migrated
   file still uses Foundation types that XCTest previously re-exported.
3. Convert one XCTest class, Swift Testing suite, or coherent file group at a
   time.
4. Prefer `struct` suites. Use `actor` or `final class` when teardown, shared
   reference identity, actor isolation, or lifecycle cleanup requires it.
5. Move `setUp` work to stored-property defaults or `init`. Convert
   `tearDown` to `deinit` only when the suite shape supports it.
6. Convert implicitly unwrapped fixture properties to non-optional stored
   properties or explicitly required values.
7. Re-run the smallest relevant unit or package test command before widening
   validation.

## XCTest To Swift Testing Mapping

| XCTest shape | Swift Testing shape |
| --- | --- |
| `XCTestCase` subclass | Swift Testing suite, usually a `struct` |
| `func testSomething()` | `@Test func something()` or a sentence-case raw identifier |
| `setUp()` | stored-property default or `init()` |
| `tearDown()` | `deinit` on `actor`/`final class`, or explicit cleanup helper |
| `XCTAssert...` | `#expect(...)` when failure can be non-halting |
| `XCTUnwrap` | `try #require(...)` |
| `XCTestExpectation` plus fulfillment | async test or `confirmation` when the toolchain supports it |
| `XCTSkipIf` / `XCTSkipUnless` | `.disabled(if:)`, `.enabled(if:)`, `@available`, or `Test.cancel` depending on timing |
| `XCTExpectFailure` | `withKnownIssue` when supported and locally appropriate |
| `XCTAttachment` | `Attachment.record(...)` only when the project/toolchain already supports attachments or explicitly wants them |

## Assertions And Halting Behavior

- Use `#expect` for non-halting checks.
- Use `try #require` when later test logic depends on the value, when migrating
  `XCTUnwrap`, or when XCTest intentionally stopped after failure.
- If an XCTest method or suite used `continueAfterFailure = false`, preserve
  that intent with `try #require` for dependent checks and mark affected tests
  `throws`.
- Map equality, identity, nil, greater/less-than, and boolean assertions to
  direct Swift expressions inside `#expect`.
- For throwing behavior, prefer `#expect(throws:)` when the expected error type
  or value is clear. Keep custom error inspection when the original test checked
  fields or conditions that a simple expected value cannot express.
- Do not replace an existing `try #require` with `#expect`; that changes test
  control flow.

## Issue Recording And Explicit Failures

- Convert `XCTFail` or `Issue.record` to `#expect` when the test can continue
  meaningfully.
- Convert guard-style failure plus `return` to `try #require` when the guarded
  value is needed by later assertions.
- Keep an explanatory message only when the expression alone would not make the
  failure clear.

## Async And Callback Expectations

- Prefer async tests over callback expectation scaffolding when the production
  API already supports async/await.
- Replace callback fulfillment with `confirmation` only when the project
  toolchain supports it and the callback count semantics are clear.
- Preserve over-fulfillment and expected-count behavior. Use a range-style
  expected count only when the original test deliberately allowed more calls.
- Do not hide race conditions by serializing a suite before checking whether the
  callback or fixture can be isolated.

## Skips, Known Issues, And Availability

- Convert OS or platform skips to availability annotations when availability is
  static.
- Use conditional traits for runtime skip conditions that belong at test
  selection time.
- Use `Test.cancel` for mid-test cancellation where the decision depends on
  values computed inside the test.
- Convert expected failures to `withKnownIssue` only when the behavior is a
  known product/tooling issue rather than an ordinary assertion.
- Preserve intermittent-failure semantics explicitly; do not turn a flaky test
  into an unconditional known issue.

## Naming, Organization, And Traits

- Remove the `test` prefix when adding `@Test`.
- Use sentence-case raw identifiers for long multi-word test names that read
  better as prose.
- Avoid raw identifiers for simple one-word or compact names.
- Add tags, traits, parameterized tests, attachments, or custom display names
  only when the project already uses them, the user asks for them, or the local
  test structure clearly benefits.
- Convert repeated loops to `@Test(arguments:)` only when each argument should
  appear as an independently reported case and the toolchain supports it.

## Concurrency And Shared State

- XCTest's defaults differ from Swift Testing's concurrency model. Do not add
  blanket `@MainActor` or `.serialized`.
- Add `@MainActor` only when UI/main-run-loop behavior, main-actor-isolated
  APIs, or the original XCTest setup clearly depended on main-actor execution.
- Add serialization only for concrete shared-state dependencies that cannot be
  isolated cheaply.
- Prefer fresh fixtures, value-type suites, dependency injection, temporary
  directories, and explicit cleanup before serialization.

## Review Cues

Flag migrations that:

- silently convert UI, performance, Objective-C-only, or tooling-bound XCTest
  surfaces to Swift Testing
- remove `Foundation` while still using Foundation types
- change fixture lifetime or implicitly unwrapped optional behavior
- convert halting preconditions into non-halting expectations
- add blanket `@MainActor` or serialization without a concrete dependency
- introduce raw identifiers, attachments, tags, known issues, or parameterized
  tests without project style or toolchain support
- change product behavior, test intent, or coverage scope during a
  modernization pass
