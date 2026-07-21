# Analytics Event Quality

## Rule
Only add analytics when the event supports a real product, UX, reliability, or rollout decision.

## Event design
- choose one clear verb-oriented event name
- keep parameters minimal and stable
- prefer enumerated values over free-form text
- make event timing explicit

## Good analytics questions
- where do users abandon the flow?
- which path is used most often?
- does the new onboarding step reduce setup failure?
- does the release increase error-rate on a key journey?

## Bad analytics patterns
- vanity events with no consumer
- event spam at every screen repaint
- fields that encode raw user content
- parameters that change schema every release
