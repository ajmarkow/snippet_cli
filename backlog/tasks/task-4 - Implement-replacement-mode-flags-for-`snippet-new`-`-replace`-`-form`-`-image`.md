---
id: TASK-4
title: >-
  Implement replacement mode flags for `snippet new` (`--replace`, `--form`,
  `--image`)
status: To Do
assignee: []
created_date: '2026-03-27 20:16'
updated_date: '2026-03-30 21:48'
labels:
  - feature
  - snippet-new
  - replacement
milestone: none
dependencies: []
references:
  - docs/plan-rev1.md
priority: high
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement replacement mode flags for the `snippet new` command. Exactly one mode must be provided per invocation and determines how the snippet content is created.

- `--replace STRING` — static text replacement; emits `replace:` key
- `--form STRING` — form layout string using `[[field]]` syntax; emits `form:` key
- `--image STRING` — path to an image file; emits `image_path:` key

Output is a valid Espanso match YAML entry printed to stdout.

Validation: exactly one replacement flag must be present; raise a clear error otherwise. Document behavior in CLI help with examples.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 --replace "Thank you" emits `replace: Thank you` in the output YAML
- [ ] #2 --form "Street: [[street]], City: [[city]]" emits a valid `form:` entry
- [ ] #3 --image /path/to/img.png emits `image_path: /path/to/img.png`
- [ ] #4 Providing none of the three replacement flags exits with a non-zero status and descriptive error
- [ ] #5 Providing two or more replacement flags exits with a non-zero status and descriptive error
- [ ] #6 CLI help text documents --replace --form and --image with examples
- [ ] #7 Default behavior when no flag is provided is explicitly defined or errors as designed
<!-- AC:END -->
