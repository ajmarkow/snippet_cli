---
id: TASK-7
title: Implement `snippet validate FILE` command
status: To Do
assignee: []
created_date: '2026-03-27 20:16'
labels:
  - feature
  - utility
  - validation
dependencies: []
references:
  - docs/plan-rev1.md
documentation:
  - >-
    https://raw.githubusercontent.com/espanso/espanso/refs/heads/dev/schemas/match.schema.json
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a `snippet validate FILE` subcommand that validates a YAML match file against the Espanso match schema.

Per the schema audit findings (2026-03-27), the official Espanso schema (`https://raw.githubusercontent.com/espanso/espanso/refs/heads/dev/schemas/match.schema.json`) should be used for validation until a merged schema is available. It validates a full `base.yaml`-style file (top-level `matches` array + optional `global_vars` and `imports`).

Exit 0 on success, non-zero on failure. Print clear, human-readable validation errors to stderr.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Running `snippet validate valid_file.yaml` exits 0 and prints a success message
- [ ] #2 Running `snippet validate invalid_file.yaml` exits non-zero and prints the specific validation errors
- [ ] #3 File-not-found produces a clear error message
- [ ] #4 Validates against the official Espanso schema (full matchfile scope, not per-item)
- [ ] #5 Command is registered in the CLI and appears in --help output
<!-- AC:END -->
