# Apple Development Baseline

This document is the Apple-platform baseline for Codex-driven iOS/macOS work.

## Critical development mandate
- Run discovery before implementation.
- Assume needed utilities/patterns may already exist.
- Reuse established architecture and testing helpers.
- Avoid creating new abstractions until reuse options are ruled out.

## Mandatory discovery checklist
1. Search for exact symbols and existing implementations.
2. Inspect adjacent/similar files for canonical patterns.
3. Check shared utilities, factories, and DI containers.
4. Confirm test helpers and mocks before adding new ones.
5. Document findings and selected minimal-change path.

## Core development context (required)
Define this for each Apple app and keep it current:
- Product domain and target users
- Supported platforms and OS/version floor
- Feature/module structure
- Architecture and state model
- Dependency injection and service boundaries
- Data persistence/sync model
- Error/loading/empty-state patterns
- Navigation/routing model
- Design system and token strategy
- Testing strategy and quality gates
- Build/release constraints
- Privacy/security requirements

## Implementation standards
- Prefer Swift 6-safe and concurrency-safe patterns.
- Keep dependencies explicit and testable.
- Use design tokens/components, not one-off styling.
- Handle loading/error/empty states explicitly.
- Keep behavior observable (logs/telemetry where appropriate).

## Testing and quality
- Start with focused tests for changed area.
- Expand to integration and critical journey tests.
- Gate merges/releases using explicit pass criteria.

## Review and hardening focus
- Concurrency safety and race risks
- Privacy/security handling of data paths
- Performance regressions and memory impact
- Reliability under partial failures/retries
- App-store/release readiness constraints

## Environment readiness checklist
- SDK/toolchain versions pinned and validated
- Required signing/entitlements available
- CI build matrix defined
- Monitoring/alerting path for release enabled
