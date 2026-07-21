# App Bootstrap Adopt Checklist

## Purpose
Use adopt mode to assess an existing Xcode project or Swift package without regenerating sources.

## Required Adopt Checks
- confirm the target path contains a `.xcodeproj`, `.xcworkspace`, or `Package.swift`
- report whether tests are present or appear to be missing
- report whether Swift packages are already in use
- report whether SwiftUI, UIKit, or AppKit appear in the codebase
- report whether the artifact is project-backed or package-native
- report whether the artifact is fully supported, partially supported, or supported only for guidance in the requested lane
- report git root, current branch, and cleanliness when a git repo exists
- report the applied repository policy, forge provider, and next topic-branch step

## Output Expectations
The adopt report should include:
- support status
- project or package shape summary
- immediate next steps
- repository policy and forge handoff
- handoff into discovery, architecture, testing, and validation
- whether app-host creation is unnecessary, optional, or required for the user's stated goal

## Guardrails
- do not rewrite project files
- do not assume a generator backend is relevant
- do not create branches, remotes, protected branches, CI, or release automation
- do not imply greenfield starter support for UIKit/AppKit
- do not treat absence of `.xcodeproj` or `.xcworkspace` as unsupported when `Package.swift` is present
- prefer honest partial-support reporting over overly confident automation
