---
id: TASK-13
title: Implement `snippet conflict FILE` command
status: Done
assignee: []
created_date: '2026-03-27 21:15'
updated_date: '2026-03-29 00:01'
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
Add a `snippet conflict FILE` subcommand that reads an Espanso match file and identifies any triggers that would conflict with one another.

A conflict occurs when one trigger is a prefix of another (e.g. `:t` and `:ty`), when two triggers are identical, or when a regex pattern could match the same input as a literal trigger. Conflicts cause unpredictable expansion behavior in Espanso.

Output should list each conflicting pair with a clear explanation of why they conflict. Exit non-zero if any conflicts are found, exit 0 if the file is clean.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Running `snippet conflict file.yaml` exits 0 and prints a clean message when no conflicts exist
- [ ] #2 Identical triggers in the same file are reported as conflicts
- [ ] #3 A trigger that is a prefix of another trigger is reported as a conflict (e.g. `:t` vs `:ty`)
- [ ] #4 Each reported conflict names both triggers and explains the conflict type
- [ ] #5 File-not-found produces a clear error message and non-zero exit
- [ ] #6 Command appears in --help output
- [ ] #7 Exit code is non-zero when at least one conflict is found
<!-- AC:END -->
