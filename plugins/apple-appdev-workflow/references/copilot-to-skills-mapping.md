# Copilot Instructions -> Apple Skills Mapping

## Core mapping
- Greenfield app setup and non-destructive project adoption -> `apple-appdev-workflow:apple-bootstrap-orchestrator` + `apple-appdev-workflow:apple-app-bootstrap` + `references/app-bootstrap-supported-matrix.md` + `references/app-bootstrap-workflow.md`
- Discovery-first mandate -> `apple-appdev-workflow:apple-discovery-first` + `references/memory-derived-best-practices.md`
- Core development context -> `apple-appdev-workflow:apple-app-orchestrator` + `apple-appdev-workflow:apple-architecture-design` + `references/core-development-context-template.md`
- Environment/protocol DI and service-based architecture -> `apple-appdev-workflow:apple-architecture-design` + `apple-appdev-workflow:apple-feature-implementation` + `references/apple-architecture-baselines.md`
- Swift concurrency compliance, isolation, and migration -> `apple-appdev-workflow:apple-swift-concurrency-foundations` + `apple-appdev-workflow:apple-swift-concurrency-review` + `references/swift-concurrency-foundations.md`
- Navigation coordinator/service -> `apple-appdev-workflow:apple-architecture-design` + `references/apple-architecture-baselines.md`
- Strict UI decoupling -> `apple-appdev-workflow:apple-feature-implementation` + `references/ui-decoupling-baseline.md`
- Native-feeling visual hierarchy and design-system discipline -> `apple-appdev-workflow:apple-design-system-ux` + `references/swiftui-design-principles.md`
- SwiftUI shell and component composition patterns -> `apple-appdev-workflow:apple-swiftui-ui-patterns`
- SwiftUI structural cleanup and MV-style refactoring -> `apple-appdev-workflow:apple-swiftui-view-refactor` + `references/swiftui-view-refactor.md`
- End-user interface wording and UX copy -> `apple-appdev-workflow:apple-interface-writing` + `references/interface-writing-patterns.md`
- Liquid Glass adoption and review -> `apple-appdev-workflow:apple-liquid-glass` + `references/liquid-glass.md`
- SwiftData persistence design, migration, history, and sync -> `apple-appdev-workflow:apple-swiftdata-foundations`
- SwiftData correctness review and tactical remediation -> `apple-appdev-workflow:apple-swiftdata-review`
- Existing Core Data stacks and SwiftData/Core Data coexistence -> `apple-appdev-workflow:apple-core-data-expert`
- App Store metadata, screenshot strategy, and storefront positioning -> `apple-appdev-workflow:apple-app-store-aso`
- App Store “What’s New” release communication -> `apple-appdev-workflow:apple-app-store-release-notes`
- Critical challenge-review for important decisions -> `apple-appdev-workflow:apple-decision-stress-test`
- Structured logging, analytics quality, crash breadcrumbs, and rollout monitoring -> `apple-appdev-workflow:apple-observability-diagnostics`
- Manual device validation and release-doctor signoff -> `apple-appdev-workflow:apple-manual-validation`
- Broad release-readiness, final-validation, and ship/no-ship orchestration -> `apple-appdev-workflow:apple-release-orchestrator`
- Broad runtime debugging, reproduction, and likely-cause diagnosis -> `apple-appdev-workflow:apple-debug-orchestrator` + `apple-appdev-workflow:apple-runtime-debugger-ios` + `apple-appdev-workflow:apple-runtime-debugger-macos`
- Runtime debugging and reproduction -> `apple-appdev-workflow:apple-runtime-debugger-ios` + `apple-appdev-workflow:apple-runtime-debugger-macos`
- SwiftUI runtime performance diagnosis -> `apple-appdev-workflow:apple-swiftui-performance-audit`
- Modern Swift Testing preference -> `apple-appdev-workflow:apple-swift-testing-foundations` + `apple-appdev-workflow:apple-testing-quality-gates` + `references/swift-testing-baseline.md`
- Build/release policies, CI gates, release candidates, and TestFlight handoff -> `apple-appdev-workflow:apple-build-release-ops`
- Hardening/review criteria -> `apple-appdev-workflow:apple-review-hardening`

## Copilot section parity checklist
- Production/discovery warnings: covered
- Core development context: covered
- DI/service architecture: covered with explicit baseline
- Swift concurrency boundaries and migration: covered
- Navigation strategy: covered with coordinator baseline
- Decoupled UI constraints: covered
- UI composition, refactor, and interface-writing workflow: covered
- Persistence workflow across SwiftData and Core Data: covered
- App Store listing and release-note workflow: covered
- High-impact decision stress-testing: covered
- Manual validation and ship-readiness evidence: covered
- Release brigade sequencing and evidence aggregation: covered
- Debug brigade sequencing and likely-cause reporting: covered
- Runtime debugging and performance workflow: covered
- Swift Testing preference and criteria: covered
- Release/readiness criteria: covered
