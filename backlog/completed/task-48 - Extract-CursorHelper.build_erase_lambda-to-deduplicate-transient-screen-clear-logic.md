---
id: TASK-48
title: >-
  Extract CursorHelper.build_erase_lambda to deduplicate transient screen-clear
  logic
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:31'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Identical TTY cursor manipulation logic is duplicated in `ui.rb:51-59` and `var_builder.rb:118-129`. Extract `CursorHelper.build_erase_lambda(n)` and have both call it.
<!-- SECTION:DESCRIPTION:END -->
