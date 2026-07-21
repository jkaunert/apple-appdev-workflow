# Apple Testing Baselines

## Layered test model
- Unit tests: deterministic logic, mapping, and edge cases.
- Integration tests: service boundaries, persistence, navigation, and async coordination.
- UI or smoke tests: critical user journeys and release confidence.

## Baseline rules
- New feature work requires at least one logic-level test and one flow-level validation path.
- Tests should construct dependencies explicitly via mocks, fakes, or test containers.
- Avoid hidden shared mutable state in tests.
- Treat flaky tests as release risks and track owner plus follow-up.

## Framework policy
- Prefer Swift Testing for new unit and integration tests.
- Use XCTest for UI tests, legacy suites, and tooling gaps.
- When using XCTest for new non-UI tests, document why.

## Execution model
- Run the narrowest useful test first.
- Broaden only after focused checks pass.
- Tie test scope back to acceptance criteria and changed boundaries.
