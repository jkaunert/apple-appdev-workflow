---
name: apple-swift-testing-foundations
description: Swift Testing specialist skill for Apple projects. Use when writing, adding, fixing, reviewing, or modernizing unit or integration tests; migrating legacy non-UI XCTest suites to Swift Testing; converting XCTestCase classes, setUp/tearDown, XCTest assertions, XCTUnwrap, XCTestExpectation, XCTSkip, XCTExpectFailure, XCTAttachment, XCTFail, Issue.record, continueAfterFailure behavior, flaky shared-state tests, or organizing tests with traits, tags, parameterization, async waiting, fixtures, or test doubles.
metadata:
  role: specialist
  entrypoint: direct-or-routed
  routing_scope: focused
---

# Apple Swift Testing Foundations

## Required context
- Load `../../references/swift-testing-foundations.md`.
- Load `../../references/swift-testing-migration.md` when migrating from XCTest.
- Load `../../references/swift-testing-modernization.md` when modernizing an existing Swift Testing suite, converting XCTest, or reviewing a migration diff.
- Load `../../references/swift-testing-isolation-and-async.md` for async, flaky, or shared-state issues.
- Load `../../references/swift-testing-organization.md` for traits, tags, parameterization, or Xcode workflow questions.
- Load `../../references/swift-testing-doubles-and-fixtures.md` when test data or dependency isolation is needed.
- Load `../../references/swift-testing-latest-features.md` only when the toolchain can support newer Swift Testing features.
- Load `../../references/swift-testing-snapshots.md` only when snapshot testing is already present or explicitly requested.

## Responsibilities
- Own authoring and modernization guidance for Swift Testing unit and integration tests.
- Prefer Swift Testing for new unit and integration tests.
- Mention retained XCTest only when UI automation, performance metrics, Objective-C-only surfaces, or confirmed legacy/tooling gaps are actually present in the task or codebase.
- Guide incremental migration from XCTest without forcing all-at-once rewrites.
- Prioritize deterministic, parallel-safe tests before recommending serialization.
- Review tests for genuine Swift Testing issues without nitpicking unrelated code.
- Treat new feature work and changed behavior as requiring test additions or updates by default.

## Workflow
1. Identify whether the task is new tests, XCTest migration, Swift Testing modernization, flaky-test remediation, organization, or test review.
2. Confirm the test scope is unit or integration; if retained UI automation, performance tests, or legacy XCTest surfaces are actually in scope, keep XCTest guidance only for those affected surfaces.
3. Apply modern Swift Testing structure and assertion rules from `../../references/swift-testing-foundations.md`.
4. For modernization or migration asks, apply `../../references/swift-testing-modernization.md` before recommending newer features.
5. Add migration guidance, isolation guidance, or organization guidance only when the task needs it.
6. Treat latest Swift Testing features as opt-in recommendations gated by project toolchain support and existing style.
7. Keep snapshot guidance opt-in only.
8. Hand command execution and merge/release gating back to `apple-appdev-workflow:apple-testing-quality-gates`.

## Output contract
- Recommended Swift Testing structure and conventions for the task
- Migration or modernization guidance when relevant
- Retained XCTest surfaces and why they should stay retained when relevant
- Behavior-preservation notes for XCTest migration, including halting assertions, async waits, skips, known issues, attachments, and serialization when relevant
- Isolation and flake-risk notes when relevant
- Clear note about retained XCTest only when it is actually relevant
- Any toolchain-gated recommendations called out explicitly

## Guardrails
- Do not recommend Swift Testing for UI tests.
- Do not mention XCTest in final guidance unless the task or codebase actually contains retained XCTest surfaces.
- Do not restate build or release gate execution; that belongs to `apple-appdev-workflow:apple-testing-quality-gates`.
- Do not adopt raw identifiers, exit tests, attachments, or test scopes by surprise in projects that do not already use them.
- Do not convert XCTest UI automation, performance tests, Objective-C-only tests, or tooling-bound legacy tests unless local evidence shows Swift Testing support for that exact surface.
- Do not turn halting XCTest behavior into non-halting `#expect` checks when the rest of the test depends on the value.
- Do not solve flaky tests with blanket `.serialized` unless isolation-first remediation has been considered and documented.
- Do not modernize tests by changing product behavior or expanding coverage goals beyond the user's requested migration or test-structure task.
