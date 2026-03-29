---
id: TASK-9
title: Implement `snippet version` command
status: Done
assignee: []
created_date: '2026-03-27 20:16'
updated_date: '2026-03-28 02:20'
labels:
  - feature
  - utility
dependencies: []
references:
  - docs/plan-rev1.md
priority: low
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a `snippet version` subcommand that prints the current gem version to stdout.

Should read from the gem's version constant (e.g. `SnippetCli::VERSION`) so it stays in sync automatically as the gem is released.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Running `snippet version` prints the version string (e.g. `0.1.0`) to stdout
- [x] #2 Version string matches the gem's VERSION constant
- [x] #3 Command appears in --help output
- [x] #4 Exit 0 on success
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Already fully implemented: `lib/snippet_cli/commands/version.rb` prints `SnippetCli::VERSION` via dry-cli, spec passes. No changes needed.
<!-- SECTION:FINAL_SUMMARY:END -->
