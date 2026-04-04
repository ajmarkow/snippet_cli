---
id: TASK-7
title: Add `snippet validate <file>` command to verify snippet schema and structure
status: Done
assignee: []
created_date: '2026-03-27 20:16'
updated_date: '2026-03-31 03:42'
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
- [x] #1 Running `snippet validate valid_file.yaml` exits 0 and prints a success message
- [x] #2 Running `snippet validate invalid_file.yaml` exits non-zero and prints the specific validation errors
- [x] #3 File-not-found produces a clear error message
- [x] #4 Validates against the official Espanso schema (full matchfile scope, not per-item)
- [x] #5 Command is registered in the CLI and appears in --help output
- [x] #6 Command `snippet validate <file>` executes without crashing
- [x] #7 Valid snippet files return a success message and exit code 0
- [x] #8 Invalid files return clear error messages with field-level feedback and non-zero exit code
- [x] #9 Validation covers required fields field types allowed values and schema constraints including custom extensions
- [x] #10 CLI output is structured and readable
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented `snippet validate <file>` command backed by a new `FileValidator` module.

- `lib/snippet_cli/file_validator.rb` — validates a full Espanso matchfile (matches array + imports) against the vendored `Espanso_Matches_File_Schema.json` using json_schemer; returns field-level error strings with JSON pointer paths
- `lib/snippet_cli/commands/validate.rb` — dry-cli command accepting a positional `file` argument; exits 0 with success message on valid input, exits 1 printing each `error: <pointer>: <message>` line on invalid input; handles missing file and YAML parse errors
- Registered in `lib/snippet_cli.rb` as `validate` with alias `vl`
- Added fixtures: `spec/fixtures/valid_matchfile.yml` and `spec/fixtures/invalid_matchfile.yml`
- 7 new specs in `spec/commands/validate_spec.rb`, all passing; full suite 225 examples, 0 failures
<!-- SECTION:FINAL_SUMMARY:END -->
