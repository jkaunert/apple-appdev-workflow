# Swift Concurrency Testing

Use this reference when concurrency-sensitive code needs validation.

## Test guidance
- prefer deterministic async tests over timing-based waits
- test cancellation behavior when long-running work or stored tasks are introduced
- validate actor and main-actor boundaries where behavior depends on them
- add regression coverage for data-race fixes, reentrancy fixes, and continuation or stream lifecycle fixes
- use Swift Testing for new unit and integration tests, with XCTest retained for UI automation only
