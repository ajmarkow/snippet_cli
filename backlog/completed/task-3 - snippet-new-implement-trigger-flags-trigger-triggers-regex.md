---
id: TASK-3
title: 'snippet new: implement trigger flags (--trigger, --triggers, --regex)'
status: Done
assignee: []
created_date: '2026-03-27 20:16'
updated_date: '2026-03-30 04:36'
labels:
  - feature
  - snippet-new
  - triggers
dependencies: []
references:
  - docs/plan-rev1.md
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement the three mutually exclusive trigger flags for the `snippet new` command. Exactly one of these must be provided per invocation.

- `--trigger STRING` — single trigger string
- `--triggers STRING` — comma-separated list of multiple triggers
- `--regex STRING` — regex trigger pattern

Output must be a valid Espanso match YAML entry printed to stdout. The trigger flag used determines the `trigger`, `triggers`, or `regex` key in the output YAML.

Validation: exactly one of the three flags must be present; raise a clear error if zero or more than one is supplied.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Running `snippet new --trigger :ty --replace "Thank you"` emits YAML with `trigger: :ty`
- [x] #2 Running `snippet new --triggers :ty,:thankyou --replace "Thank you"` emits YAML with a `triggers:` array
- [x] #3 Running `snippet new --regex '\bty\b' --replace "Thank you"` emits YAML with `regex:` key
- [x] #4 Providing two or more trigger flags exits with a non-zero status and descriptive error
<!-- AC:END -->
