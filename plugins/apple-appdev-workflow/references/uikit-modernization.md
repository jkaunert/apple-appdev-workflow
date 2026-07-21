# UIKit Modernization

Use this reference behind `apple-appdev-workflow:apple-uikit-modernization` for
existing UIKit or mixed UIKit apps that need scene, window, trait, orientation,
or safe-area aware modernization.

This reference adapts the Xcode 27 exported UIKit app-modernization material
into this bundle's routed station model. Do not assume the raw exported folders
are present at runtime, and do not default-load their full reference corpus.
Use this file to choose the active modernization task, preserve file coverage,
and keep mutations scoped.

## Modernization Targets

| Target | Detect | Preferred local replacement shape | Ask or defer when |
| --- | --- | --- | --- |
| `UIScreen.main` / `mainScreen` | `UIScreen.main.*`, `UIScreen.mainScreen.*`, `UIScreenBrightnessDidChangeNotification` with main screen object, nil-screen fallbacks | Prefer the nearest local context: `traitCollection.displayScale` in `UIView`/`UIViewController`, `windowScene.screen` or `window.screen` when a window/scene is already available, `UIWindow(windowScene:)` when a `UIWindowScene` is in scope, SwiftUI `@Environment(\.displayScale)` or `GeometryReader` only in SwiftUI views. | Non-view helpers, static APIs, public APIs, cached `dispatch_once`/static values, notification subscriptions, native scale, or no local window/trait source. Use deprecate-and-forward or an explicit TODO/ask path. |
| Orientation for layout | `interfaceOrientation`, `statusBarOrientation`, `UIDevice.current.orientation`, `UIInterfaceOrientation*` in layout decisions | For layout, use size classes or the relevant view/window bounds. | Camera, motion, video, analytics, left-vs-right orientation, rotation transforms, orientation locking, or any non-layout semantic use. |
| Scene lifecycle | Missing `UIApplicationSceneManifest`, missing `UIWindowSceneDelegate`, AppDelegate-only lifecycle methods, `UIWindow(frame: UIScreen.main.bounds)` root setup | Add scene manifest, `SceneDelegate`, scene-owned window creation, and move lifecycle methods only when the migration shape is unambiguous and authorized. | Partial migrations, URL/user-activity/notification ownership, storyboard-vs-programmatic ambiguity, Info.plist vs dynamic configuration choice, or project-file membership risk. |
| Safe areas and layout margins | `topLayoutGuide`, `bottomLayoutGuide`, hard-coded bar/home-indicator offsets, symmetric safe-area assumptions, `layoutMargins` where RTL matters, `viewRespectsSystemMinimumLayoutMargins = false` without rationale | Use `safeAreaLayoutGuide`, per-edge `safeAreaInsets`, `directionalLayoutMargins`, and `contentInsetAdjustmentBehavior` where appropriate. Preserve intentional edge-to-edge backgrounds or media. | Literal values that may be unrelated to bars, custom full-bleed design, manual frame math with unclear visual intent, or changes requiring visual QA. |

## File Coverage Discipline

- Before editing, enumerate every file containing the active target pattern.
- A detected file must end as one of:
  - changed by a scoped modernization diff
  - skipped with a concrete reason
  - blocked by an explicit user decision
- Do not silently drop large files, Objective-C files, macro-heavy files, helper
  files, generated-looking files, or files in a different project group.
- Process broad file sets in small batches so the tail of the list is not lost
  to context pressure.
- Treat an empty diff for a file containing the active target API as a failure
  unless the target appears only in dead code such as `#if 0`.

## Mutation Rules

- Use the closest consumer. Prefer a view, view controller, trait collection,
  window, scene, or method parameter already in scope over global shared state.
- Do not use `UIApplication.shared`, `UIDevice.current`, `UIScreen.main`, or
  connected-scene scans as a replacement for local context.
- Preserve control flow and defensive wrappers. Availability checks, nil guards,
  selector checks, fallback branches, and `catch` blocks usually exist for
  reasons unrelated to the modernization.
- Keep task boundaries strict. A `UIScreen` modernization must not also fix an
  orientation or safe-area issue nearby unless the user requested a combined
  pass or the changes are explicitly atomic.
- Make multi-part patterns atomic. If a replacement requires a new overload,
  deprecation wrapper, forwarding bridge, caller update, and trait-change
  observation, apply all required parts or stop with a reason.
- Never delete an old method just because a new overload is added. Keep the old
  method as the deprecated wrapper unless the user explicitly authorized an API
  break.
- Avoid opportunistic formatting or cleanup. Only change lines and nearby
  declarations needed for the active modernization target.

## TODO Standard

Use TODOs only when a safe replacement is not available inside the current
scope. Every TODO must be on its own line above the unchanged code and state:

- why the old API is incorrect for modern multi-window or safe-area behavior
- what the replacement shape should be
- what lifecycle, threading, scene, or caller-context concern blocks the edit

Do not add redundant TODOs when an existing annotation already explains the
migration.

## Validation

Choose the narrowest proof that matches the mutation:

- Swift/Objective-C source edits: compile, SwiftSyntax changed-files check when
  applicable, or the narrowest target build available.
- Info.plist edits: structured plist parse or `plutil -lint`.
- `.pbxproj` or project membership edits: XcodeBuildMCP build settings/project
  discovery, `xcodebuild -list`, or a target build.
- Scene lifecycle migration: launch/build evidence when possible; otherwise
  clearly report manual validation still needed.
- Safe-area or orientation layout changes: simulator/manual visual validation
  is often needed; call out skipped runtime validation explicitly.

## Output Expectations

For audits, return prioritized findings with the target pattern, file, risk,
and replacement shape.

For implementation, report files changed, files skipped with reasons, user
decisions still needed, validation run, and residual risk. Do not claim full
app modernization unless every selected target pattern was searched, processed,
and validated.
