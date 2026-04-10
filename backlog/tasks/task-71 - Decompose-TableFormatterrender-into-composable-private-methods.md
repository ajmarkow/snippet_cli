---
id: TASK-71
title: Decompose TableFormatter#render into composable private methods
status: To Do
assignee: []
created_date: '2026-04-10 21:17'
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
- [ ] #1 TableFormatter#render delegates to private helper methods
- [ ] #2 No rubocop:disable complexity comments needed
- [ ] #3 Table output unchanged (verified by tests)
- [ ] #4 All existing tests pass
<!-- AC:END -->
