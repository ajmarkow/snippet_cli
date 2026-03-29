---
id: TASK-4
title: 'snippet new: implement replacement flags (--replace, --form, --image)'
status: To Do
assignee: []
created_date: '2026-03-27 20:16'
labels:
  - feature
  - snippet-new
  - replacement
dependencies: []
references:
  - docs/plan-rev1.md
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement the three mutually exclusive replacement flags for the `snippet new` command. Exactly one of these must be provided per invocation.

- `--replace STRING` — static text replacement; emits `replace:` key
- `--form STRING` — form layout string using `[[field]]` syntax; emits `form:` key
- `--image STRING` — path to an image file; emits `image_path:` key

Output is a valid Espanso match YAML entry printed to stdout.

Validation: exactly one replacement flag must be present; raise a clear error otherwise.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 --replace "Thank you" emits `replace: Thank you` in the output YAML
- [ ] #2 --form "Street: [[street]], City: [[city]]" emits a valid `form:` entry
- [ ] #3 --image /path/to/img.png emits `image_path: /path/to/img.png`
- [ ] #4 Providing none of the three replacement flags exits with a non-zero status and descriptive error
- [ ] #5 Providing two or more replacement flags exits with a non-zero status and descriptive error
<!-- AC:END -->
