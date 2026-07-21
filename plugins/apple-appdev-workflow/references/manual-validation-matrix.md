# Manual Validation Matrix

## Purpose
Pick the smallest device and OS matrix that still gives credible manual release evidence.

## Baseline Rules
- Cover at least one current supported OS and one minimum supported OS when behavior is version-sensitive.
- Expand the matrix when layout, interaction, permissions, or hardware behavior differs materially by device class.
- Prefer explicit rationale for each chosen device rather than a long unfocused matrix.

## iPhone-first apps
- Minimum:
  - one current iPhone on the latest supported OS
  - one iPhone on the minimum supported OS when compatibility risk exists
- Add a second iPhone size when layout or camera/file flows are sensitive to size class or presentation differences.

## iPhone and iPad apps
- Validate at least:
  - one iPhone
  - one iPad
- Add more coverage when split view, multitasking, keyboard, drag and drop, or popover behavior matters.

## macOS apps
- Validate at least:
  - one current macOS version used by target users
  - one older supported version when release behavior or permissions differ materially
- Include windowing, menu, file access, and lifecycle checks where relevant.

## Selection guidance
- One device is enough only when:
  - the changed journey is narrow
  - no hardware-dependent behavior changed
  - no layout or OS-sensitive behavior changed
- Otherwise call out the missing matrix coverage explicitly.
