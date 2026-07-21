# App Bootstrap Adopt Mode

## Purpose
Adopt an existing Xcode project or Swift package into the Apple bundle workflow without regenerating sources or imposing external build-system changes.

## Required Behavior
- detect `.xcodeproj`, `.xcworkspace`, or `Package.swift`
- do not rewrite existing source trees
- do not assume XcodeGen is installed
- do not introduce external task-management helpers or alternate shell-first build helpers
- keep adoption aligned to the Apple bundle's native MCP-first workflow
- treat package-native MCP workflows as first-class support rather than fallback-only behavior

## Immediate Handoff
After adopt validation:
- fill the core development context
- run `apple-appdev-workflow:apple-discovery-first`
- if an Xcode project or workspace exists, use `XcodeBuildMCP` to discover schemes and verify a clean baseline build
- if the artifact is package-native, use `swift package describe` plus the MCP `swift_package_*` workflows to verify the baseline
- report current git root, branch, cleanliness, applied repository policy, forge provider, and the first topic-branch step before implementation
- route architecture, testing, persistence, accessibility, and release work through the existing Apple bundle skills
- recommend a host app or workspace only when the requested next phase needs app-specific runtime, UI automation, signing, or release workflows

## Phase 2 Expectations
- produce a useful adopt report, not just a shape check
- report support status honestly when UIKit/AppKit is present
- report support status honestly when the artifact is package-native instead of project-backed
- surface missing tests or package usage as follow-up signals, not silent assumptions
- preserve branch and forge handoff semantics without creating branches, remotes,
  protected branches, CI, or release automation
