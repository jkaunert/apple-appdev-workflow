# Staged Rollout And Rollback

## Use this when
- the change is high-risk
- there are operational unknowns
- the release changes a critical journey
- rollback decisions may need explicit triggers

## Minimum rollout plan
- rollout stage or audience
- signals to monitor
- threshold for pause or rollback
- owner for decision-making
- recovery or rollback path

## Rollback guidance
- define rollback triggers before ship
- separate reversible operational steps from irreversible user or data impact
- prefer concrete signals over vague discomfort

## Anti-patterns
- staged rollout with no monitored signals
- rollback plan that depends on rediscovering basic facts under pressure
- claiming rollback is easy without verifying artifact and config traceability
