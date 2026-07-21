# Swift Testing Doubles and Fixtures

Use this reference when tests need explicit data setup or dependency isolation.

## Verification preference
- Prefer state verification over behavior verification when both are viable.
- Use the smallest test double that satisfies the behavior under test.

## Double selection
- Dummy: fill parameters only
- Fake: lightweight working implementation
- Stub: returns pre-configured values
- Spy: records calls for later verification
- Spying stub: most common mix of stub and spy behavior
- Mock: only when exact interaction verification is truly required

## Placement guidance
- Keep fixtures close to models when the project already supports that pattern.
- Keep doubles close to interfaces or canonical test-support modules rather than scattering ad-hoc helpers.
- Reuse existing factories, doubles, and fixtures before creating new ones.

## Quality rules
- Make test data deterministic.
- Avoid hidden coupling inside helper factories.
- Keep test doubles explicit about captured calls, configured returns, and thrown errors.
