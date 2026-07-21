# SwiftUI App Wiring

Use when wiring the root shell or major feature containers.

## Baseline
- Root shell owns tabs, per-tab navigation state, and centralized sheet routing.
- Composition root installs shared services and environment dependencies once.
- Feature views pull only what they need; feature-specific state stays local.

## Preferred structure
- `TabView` at the shell when tabs are required.
- Per-tab `NavigationStack` or platform-appropriate equivalent.
- Enum-driven sheet routing instead of scattered booleans.
- Shared dependency-graph modifier or equivalent composition root.

## Guardrails
- Keep global wiring slim; long-running work belongs in services.
- Do not duplicate dependency installation across tabs or sheets.
- Keep router and navigation state explicit and testable.
