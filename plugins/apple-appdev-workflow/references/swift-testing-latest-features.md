# Swift Testing Latest Features

Use this reference only when the project toolchain can support these features and the existing test style will not be disrupted.

## Adoption policy
- Treat these as optional recommendations, not baseline defaults.
- Confirm the project toolchain and surrounding code style before using them.

## Toolchain-gated features
- Raw identifier test names
- Range-based confirmations
- Test scopes and scoping traits
- Exit tests
- Attachments

## Usage rules
- Suggest raw identifiers only when the project already uses them or the user asks for them.
- Use range-based confirmations when callback counts are intentionally bounded ranges.
- Use test scopes only when shared configuration cannot be expressed cleanly with simpler suite setup.
- Use exit tests only when testing deliberate process-fatal behavior.
- Use attachments when failing diagnostics materially benefit from attached artifacts.
