---
id: TASK-83
title: >-
  Eliminate pipe_output global — fold into WizardContext for consistent
  dependency injection
status: To Do
assignee: []
created_date: '2026-04-11 15:47'
labels:
  - architecture
  - refactor
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`SnippetCli.pipe_output` (`lib/snippet_cli.rb:27–33`) is a global class variable accessed directly by `UI.deliver()` (`lib/snippet_cli/ui.rb:62–71`). This is a service locator antipattern. The codebase already has `WizardContext` as the right pattern for explicit context passing, but `pipe_output` bypasses it. New context needs (logging level, output format) will likely follow the global pattern if this isn't fixed first.

The fix is to move `pipe_output` into `WizardContext` and have `UI.deliver` receive context explicitly rather than reading a global.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 SnippetCli.pipe_output global is removed
- [ ] #2 WizardContext carries the pipe_output flag (or equivalent)
- [ ] #3 UI.deliver receives context as a parameter rather than reading a global
- [ ] #4 Testing UI.deliver does not require setting global state
- [ ] #5 All existing specs pass
<!-- AC:END -->
