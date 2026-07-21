# Accessibility Nutrition Labels

Use this reference when the task involves release readiness, App Store metadata, or an accessibility support claim.

## Rule
Recommend a label only when reviewed common tasks are fully supported for that accessibility feature. Partial support is not enough.

## Common task coverage
Evaluate the flows that matter for the app:
- launch and onboarding
- login or account access
- primary feature path
- settings or preferences
- purchase, upload, or other critical completion flows when applicable

## Recommendation format
```text
Accessibility Nutrition Label recommendation

App version evaluated: <version or current build>
Scope reviewed: <flows or screens reviewed>

You could claim:
- <label>

Why you could claim them:
- <label>: <reason tied to reviewed common-task coverage>

You should not claim:
- <label>

Why you should not claim them:
- <label>: <blocked task, missing evidence, or non-applicability>

Recommendation summary:
- Could claim: <labels>
- Should not claim: <labels>
```

## Guardrails
- Keep the output framed as a recommendation, not a guarantee.
- A single blocked common task means that label should not be recommended.
- If evidence is incomplete, say so explicitly instead of inferring support.
