---
id: TASK-8
title: Implement `snippet list FILE` command
status: To Do
assignee: []
created_date: '2026-03-27 20:16'
labels:
  - feature
  - utility
dependencies: []
references:
  - docs/plan-rev1.md
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a `snippet list FILE` subcommand that reads a YAML match file and prints all triggers defined in it, one per line.

Should handle all trigger forms: single `trigger:`, arrays under `triggers:`, and `regex:` patterns. Output should be human-readable and suitable for piping.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Running `snippet list file.yaml` prints each trigger string on its own line
- [ ] #2 Handles files with single `trigger:` entries
- [ ] #3 Handles files with `triggers:` arrays (prints each element)
- [ ] #4 Handles `regex:` entries (prints the pattern, clearly marked as regex)
- [ ] #5 File-not-found produces a clear error message
- [ ] #6 Command appears in --help output
<!-- AC:END -->
