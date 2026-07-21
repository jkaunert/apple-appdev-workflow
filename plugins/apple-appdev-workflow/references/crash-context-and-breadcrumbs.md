# Crash Context And Breadcrumbs

## Purpose
Make post-failure reconstruction possible without invasive logging.

## Add breadcrumbs for
- multi-step flows where the final crash hides earlier state changes
- async sequences with retries, cancellation, or task handoffs
- permission and lifecycle transitions
- persistence, sync, or migration operations
- launch or deep-link routing

## Good breadcrumb content
- flow step name
- feature state or mode
- high-level error category
- retry count or cancellation state
- correlation identifiers if needed

## Avoid
- raw user-entered text
- large payload dumps
- duplicate breadcrumbs for every trivial state change
