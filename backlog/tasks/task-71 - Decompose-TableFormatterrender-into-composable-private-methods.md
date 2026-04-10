---
id: TASK-71
title: Decompose TableFormatter#render into composable private methods
status: Done
assignee: []
created_date: '2026-04-10 21:17'
updated_date: '2026-04-10 21:45'
labels:
  - refactor
  - oop
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`TableFormatter.render` disables complexity cops and carries multiple formatting responsibilities in one method.

**Evidence:**
- `lib/snippet_cli/table_formatter.rb:5-17` has rubocop complexity disables

**Plan:**
1. Break `render` into composable private methods: `compute_widths`, `build_border`, `build_rows`, `colorize`
2. Consider delegating to an existing table-rendering utility to reduce custom rendering surface
3. Remove the rubocop:disable comments once complexity is reduced
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 TableFormatter#render delegates to private helper methods
- [x] #2 No rubocop:disable complexity comments needed
- [x] #3 Table output unchanged (verified by tests)
- [x] #4 All existing tests pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Decomposed `TableFormatter.render` into four private helpers:
- `column_widths(rows, headers)` — max width per column
- `border_line(widths, left:, mid:, right:)` — builds top/divider/bottom lines from box-drawing chars
- `data_line(cells, widths)` — builds a `│ cell │` row
- `colorize(line)` — wraps in `\e[97m...\e[0m`

`render` is now a clean 7-line coordinator. All three rubocop:disable comments removed. No new tests needed — existing 5 output-level specs verify identical behaviour. 648 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
