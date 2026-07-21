# Memory-Derived Best Practices (Apple)

Derived from prior workspace memory artifacts and normalized for reuse.

## Discovery-first implementation
- Search imported packages for existing extensions before adding methods.
- Resolve method ambiguity at source when possible (platform-conditional extensions).

## SwiftUI layout pitfalls
- Frame modifier order can change layout outcomes; validate on-device/simulator.
- Use adaptive grid patterns deliberately and verify with dynamic widths.

## Image pipeline correctness
- Apply orientation transforms early (ImageIO thumbnail with transform).
- Keep crop/resize stages explicit; verify orientation and aspect in tests.

## Cross-platform API design
- Add platform-specific helpers only where APIs are missing (e.g., AppKit-only extensions).
- Avoid UIKit extensions that duplicate native methods and create ambiguity.

## Camera and media capture reliability
- Retain camera capture delegates (example: `AVCapturePhotoCaptureDelegate`) until capture callbacks complete.
- Treat simulator media limitations as a first-class test and UX path; surface camera-unavailable or session errors clearly in UI.
- Ensure preview or image overlay layers do not block user input; disable hit-testing where appropriate.

## Top Critical Memory Observations
1. [HIGH] Delegate lifecycle failures can silently break capture completion when delegates are deallocated early.
2. [HIGH] Untested simulator media constraints can block user workflows if session failure states are not surfaced.
3. [MEDIUM] Full-screen visual overlays can capture touches and make controls appear unresponsive.
