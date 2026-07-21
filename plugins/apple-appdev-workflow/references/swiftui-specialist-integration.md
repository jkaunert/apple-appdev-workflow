# SwiftUI Specialist Integration

Use this reference when a SwiftUI task needs official SwiftUI specialist
guidance beyond the bundle's ordinary UI pattern references.

This reference adapts the Xcode 27 exported SwiftUI specialist material into
this bundle's routed station model. Do not assume the raw exported folders are
present at runtime, and do not route around the bundle by invoking unmanaged
parallel skills. Use this file to decide which SwiftUI station owns the work,
which detailed local reference to load next, and which guardrails apply.

## Topic Routing

| Topic | Primary station | Load or pair with | Use when |
| --- | --- | --- | --- |
| View structure | `apple-swiftui-ui-patterns` or `apple-swiftui-view-refactor` | `swiftui-view-refactor.md`, `swiftui-performance-smells.md` when update cost matters | Multi-section views, oversized `body`, computed subview helpers, or root-tree stability are in scope. |
| Data flow and Observation | `apple-swiftui-ui-patterns` or `apple-swiftui-view-refactor` | `swiftui-mv-patterns.md`, `apple-swift-concurrency-foundations` when isolation matters | Inputs, `@State`, `@Binding`, `@Observable`, side effects, or binding shape drives the change. |
| Environment and focus values | `apple-swiftui-ui-patterns` | `swiftui-performance-smells.md` for invalidation fan-out | Custom `EnvironmentKey`, `EnvironmentValues`, `FocusedValue`, rapidly changing values, or action injection is involved. |
| Data-driven containers | `apple-swiftui-ui-patterns` or `apple-swiftui-performance-audit` | `swiftui-list-form-grid-patterns.md`, `swiftui-performance-smells.md` | `ForEach`, `List`, `Table`, `OutlineGroup`, `Picker`, row identity, sorting/filtering, or list performance is in scope. |
| Modifiers and conditional layout | `apple-swiftui-view-refactor` or `apple-design-system-ux` | `swiftui-design-principles.md` when visual treatment matters | Conditional modifier helpers, repeated modifier stacks, identity churn, or platform-specific styling is in scope. |
| Localization in SwiftUI | `apple-design-system-ux` plus `apple-interface-writing` when copy changes | `swiftui-design-principles.md` for layout effects | `Text`, `Button`, `Label`, navigation titles, toolbars, alerts, string resources, or RTL layout is in scope. |
| Animation and custom animatable values | `apple-design-system-ux` or `apple-swiftui-performance-audit` | `swiftui-performance-smells.md` when large animated trees are involved | Custom `Shape`, custom `View`, explicit animation data, or deployment-gated animation APIs are involved. |
| Soft deprecations | `apple-swiftui-view-refactor` for cleanup; `apple-swiftui-ui-patterns` for new code | `swiftui-sdk27-compatibility.md` when SDK 27 also matters | Generating, reviewing, modernizing, or cleaning up SwiftUI API usage. |
| SDK 27 source compatibility | `apple-swiftui-ui-patterns` or `apple-swiftui-view-refactor` | `swiftui-sdk27-compatibility.md` | Xcode 27, SDK 27, post-update compile errors, deprecations, toolbar/document/list/image/dialog/drag-drop changes, or `@State` macro diagnostics are in scope. |

## Official-Guidance Heuristics

- Treat a SwiftUI view as an invalidation boundary. For multi-section views,
  prefer separate `View` types with narrow inputs over computed subview
  properties when update cost or reuse matters.
- Pass value-type inputs at the narrowest useful shape. Avoid handing a view a
  large struct when it only reads one or two fields.
- Prefer `@State` for view-local state, `@Binding` for child edits to parent
  state, and model/service boundaries for business logic or external effects.
- For `@Observable` models, consider invalidation granularity: computed values,
  large shared models, and broad property reads can still fan out updates.
- Keep side effects isolated. Do not hide broad work in `body`; evaluate
  `.onChange`, `.task`, and async work for cancellation, idempotence, and
  invalidation side effects.
- Avoid custom environment or focus-value keys that store closures. Framework
  action types such as `DismissAction` and `OpenURLAction` are not the same
  anti-pattern.
- Give `ForEach` and related data-driven containers stable, unique identity
  that follows the element, not the element's position or rendered content.
- Do not sort or filter expensive collections inline inside `body` when the
  work can be precomputed or owned by the model layer.
- Avoid conditional modifier helpers that switch between `transform(self)` and
  `self`; they can reset identity, state, and animation continuity.
- Preserve localization semantics. In SwiftUI view initializers, literal text is
  localizable; runtime `String` values are not. Use interpolation instead of
  sentence concatenation, prefer leading/trailing over left/right, and use an
  explicit bundle for packages or frameworks.
- Do not introduce soft-deprecated SwiftUI APIs in new code. When feature work
  encounters a soft-deprecated API in the edited view, keep the requested diff
  scoped and offer migration as a separate step unless migration was requested.

## SDK 27 Compatibility Hooks

Load `swiftui-sdk27-compatibility.md` before answering or editing when any of
these appear:

- `@State` compile errors after an SDK update, especially initialization,
  redeclaration, or missing memberwise initializer diagnostics
- result-builder or `@ContentBuilder` ambiguity in `overlay`, `background`, or
  generic content types
- drag reorder, swipe actions outside basic `List`, item-bound alerts or
  confirmation dialogs, toolbar overflow/minimization, `AsyncImage` request or
  cache behavior, document-based app migration, or SDK 27 deprecations
- exact availability questions for new SwiftUI API

For exact API names, overloads, availability, and compiler-error fixes, verify
against the local SDK or current Apple documentation before editing.

## Workflow

1. Classify the request into one or more topics from the routing table.
2. Load only the station references needed for those topics.
3. Inspect the actual SwiftUI code before recommending a pattern or refactor.
4. Preserve behavior unless the user asked for redesign, API adoption, or
   modernization.
5. Keep architecture, accessibility, interface writing, performance, and
   Swift Testing stations involved when their guardrails materially affect the
   change.
6. Validate with the smallest build, source, or review gate that proves the
   SwiftUI change.

## Guardrails

- Do not default-load the full exported SwiftUI corpus.
- Do not create a new public SwiftUI specialist skill unless existing station
  ownership proves inadequate.
- Do not make broad unrelated SwiftUI modernization changes while fixing a
  narrow feature or compile error.
- Do not present SDK 27 beta or export-derived behavior as stable without local
  SDK evidence or current Apple documentation.
- Do not mention soft-deprecated APIs in code that is outside the user-approved
  edit or review scope.
