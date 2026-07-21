# Rollout Monitoring

## Use this when
- the release changes a critical user journey
- the change is operationally risky
- staged rollout, feature flags, or rollback decisions are in scope

## Minimum monitoring questions
- what error rate or failure signal should we watch?
- what user journey must stay healthy after release?
- what signal would trigger pause or rollback?
- who can interpret the signal and act on it?

## Expected outputs
- list of post-release signals to monitor
- threshold or symptom that would trigger deeper investigation
- explicit linkage between rollout risk and observability surface

## Anti-patterns
- shipping a risky change with no post-release signal
- using only anecdotal user reports as monitoring
- monitoring too many weak signals with no action threshold
