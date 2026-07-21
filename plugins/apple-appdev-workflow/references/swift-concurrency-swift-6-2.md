# Swift Concurrency Swift 6.2

Use this reference only when project settings indicate Swift 6.2-era behavior matters.

## Setting-dependent behavior
- approachable concurrency and default actor isolation materially change how async code behaves
- async functions may stay on the caller's actor by default in these modes
- isolated conformances become an important remediation path

## Guidance
- confirm settings before suggesting Swift 6.2-specific fixes
- prefer minimal annotations in approachable-concurrency projects
- watch for performance issues if main-actor-by-default leaves CPU-heavy work on the main actor
- use `@concurrent` only when you intentionally want work to leave inherited isolation
