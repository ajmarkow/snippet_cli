---
id: TASK-84
title: >-
  Refactor select_alt_type control flow — replace infinite loop + next with
  explicit state
status: Done
assignee: []
created_date: '2026-04-11 15:48'
updated_date: '2026-04-11 15:56'
labels:
  - architecture
  - refactor
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`NewWorkflow#select_alt_type` (`new_workflow.rb:85–96`) uses an infinite loop with `next unless` and nested conditional business rules (image_path cannot have vars), mixing user prompting, domain validation, and error recovery in a single opaque flow. Intent is only recoverable after careful reading; adding new replacement types will deepen the nesting.

The fix is to replace the loop with explicit guard clauses and early returns, or model the selection as a small state machine with named states.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 select_alt_type (or its replacement) contains no infinite loop construct
- [ ] #2 The image_path/vars constraint is expressed as a named guard or validation, not an inline conditional inside a loop
- [ ] #3 Adding a new replacement type constraint does not require modifying existing loop logic
- [ ] #4 All existing specs pass
<!-- AC:END -->
