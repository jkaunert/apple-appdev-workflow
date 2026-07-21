# TestFlight Handoff

Use this reference when a release candidate is moving from internal validation toward broader tester distribution.

## Handoff checklist
- release candidate build is tied to a verified commit
- signing and bundle metadata are correct
- release notes are ready for the tester audience when needed
- rollout-sensitive risks are called out explicitly
- manual validation status is recorded
- post-upload monitoring expectations are named

## Questions to answer
- who is the intended tester audience?
- what changed materially in this build?
- what should testers focus on?
- what issue would block wider rollout?

## Anti-patterns
- uploading a build with no validation summary
- using TestFlight as a substitute for basic local or CI validation
- unclear tester instructions for risky changes
