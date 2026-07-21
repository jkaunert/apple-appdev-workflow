# Apple Logging Policy

## Goal
Use logs to reconstruct failures and state transitions without leaking sensitive data.

## Good logging shape
- stable event name
- small set of typed fields
- explicit success or failure state
- correlation identifiers when needed
- no secrets or raw personal content

## Good candidates
- feature entry and exit for critical flows
- recoverable failures with error category
- retry exhaustion
- persistence save or sync failure
- unexpected state transitions

## Avoid
- noisy per-frame or per-render logs
- duplicated log lines for the same event
- raw server payloads unless explicitly redacted
- logs that exist only for debugging a temporary local issue
