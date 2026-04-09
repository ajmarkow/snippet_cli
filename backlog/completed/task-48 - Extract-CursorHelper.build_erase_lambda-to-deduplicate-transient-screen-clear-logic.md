---
id: TASK-48
title: >-
  Extract CursorHelper.build_erase_lambda to deduplicate transient screen-clear
  logic
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:15'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Identical TTY cursor manipulation logic is duplicated in `ui.rb:51-59` and `var_builder.rb:118-129`. Extract `CursorHelper.build_erase_lambda(n)` and have both call it.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Created CursorHelper.build_erase_lambda(line_count) in lib/snippet_cli/cursor_helper.rb. Updated ui.rb to delegate its private erase_lambda method to CursorHelper and replaced the tty-cursor require with cursor_helper. Updated var_builder.rb to replace its duplicate build_summary_erase body with a CursorHelper call. Added spec/cursor_helper_spec.rb with 3 examples. 534 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
