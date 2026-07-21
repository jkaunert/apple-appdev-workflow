# App Bootstrap Package Layouts

## Purpose
Describe when the optional local package layout is justified in bootstrap.

## Default
Use `single-target` unless the user explicitly wants modest initial modular separation.

## Optional Packages
- `AppCore`: pure domain types, business rules, shared policies
- `AppServices`: infrastructure adapters, clients, persistence, protocol-backed service implementations
- `AppDesignSystem`: reusable visual tokens and shared components
- `AppTestSupport`: shared fixtures, mocks, fakes, and test helpers

## Guardrails
- packages are opt-in, not default
- do not create packages without a stated need
- do not create every package automatically
- package boundaries should support ownership clarity, not fashionable modularization
- in Phase 1 bootstrap, `linked package` means package presence, project linkage, manifest alignment, and at most minimal placeholder targets needed for a clean scaffold
- do not treat package requests as permission to invent concrete package internals, token systems, component hierarchies, app-to-package UI wiring, or package-focused tests during bootstrap
- do not create or edit files under `Packages/*/Tests` during bootstrap; running package tests for validation is allowed, but package test sources must remain scaffold-owned
