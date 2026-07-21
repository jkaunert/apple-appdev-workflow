# App Bootstrap Supported Matrix

## Phase 1
### Greenfield
- iOS + SwiftUI: supported
- macOS + SwiftUI: supported

### Adopt Existing Project
- iOS Xcode project: supported
- macOS Xcode project: supported
- pure Swift package: supported for package-native adoption and validation
- UIKit/AppKit projects: supported for adopt guidance only, not template regeneration

### Layout Modes
- single target: supported
- app + minimal local SPM packages: supported

### Explicitly Out Of Scope
- greenfield UIKit starter
- greenfield AppKit starter
- makefile toolkit install
- task CLI install

## Phase 2
### Implemented In Phase 2
- stronger UIKit/AppKit adopt flows
- richer SPM package guidance and generated docs
- retrofit-style adopt reporting and baseline checks for existing repos
- package-native adopt reporting and MCP package-validation handoff

## Phase 3
### Implemented Phase 3A Pilot
- explicit `--backend tuist` single-target iOS/macOS SwiftUI scaffold pilot
- Tuist availability and version preflight
- compound release-intent handoff for TestFlight-aware plus App Store-aware
  scaffolds
- generated handoff docs with backend evidence and downstream release owner
  lanes

### Implemented Phase 3B
- explicit `--backend tuist --layout-mode app-plus-packages` support for
  bootstrap-generated local Swift packages
- Tuist `Project.swift` local package references while preserving
  `Packages/<Name>/Package.swift`
- no `tuist install`, external dependencies, release automation, or backend
  fallback

### Conditional Expansion Only
- greenfield UIKit starter
- greenfield AppKit starter
- broader starter-variant matrix

## Backend Policy
- default greenfield generation remains XcodeGen
- Tuist is explicit opt-in only and supports SwiftUI single-target plus selected
  local package layouts
- adopt mode must not require XcodeGen
- post-bootstrap validation uses the Apple bundle's existing validation flow
- package-native adoption should prefer MCP `swift_package_*` workflows rather than requiring a project container

## Trigger Mapping
Use `apple-appdev-workflow:apple-app-bootstrap` for:
- create a new iOS app
- create a new macOS app
- scaffold a SwiftUI app
- bootstrap an Apple app
- adopt this existing Xcode project
- adopt this existing Swift package
- start a new Apple app with optional packages

Do not use `apple-appdev-workflow:apple-app-bootstrap` for:
- adding a feature to an existing app
- routine build/test work
- release prep
- task planning workflows
