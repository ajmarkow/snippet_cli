---
id: TASK-7
title: Add `snippet validate <file>` command to verify snippet schema and structure
status: To Do
assignee: []
created_date: '2026-03-27 20:16'
updated_date: '2026-03-30 21:48'
labels:
  - feature
  - utility
  - validation
milestone: none
dependencies: []
references:
  - docs/plan-rev1.md
documentation:
  - >-
    https://raw.githubusercontent.com/espanso/espanso/refs/heads/dev/schemas/match.schema.json
priority: high
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a CLI command that validates a snippet file against the Espanso schema including custom extensions. The command should detect structural issues missing required fields invalid values and provide actionable feedback. Clarify whether validation includes semantic checks such as unused variables or invalid references.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Running `snippet validate valid_file.yaml` exits 0 and prints a success message
- [ ] #2 Running `snippet validate invalid_file.yaml` exits non-zero and prints the specific validation errors
- [ ] #3 File-not-found produces a clear error message
- [ ] #4 Validates against the official Espanso schema (full matchfile scope, not per-item)
- [ ] #5 Command is registered in the CLI and appears in --help output
- [ ] #6 Command `snippet validate <file>` executes without crashing
- [ ] #7 Valid snippet files return a success message and exit code 0
- [ ] #8 Invalid files return clear error messages with field-level feedback and non-zero exit code
- [ ] #9 Validation covers required fields field types allowed values and schema constraints including custom extensions
- [ ] #10 CLI output is structured and readable
<!-- AC:END -->
