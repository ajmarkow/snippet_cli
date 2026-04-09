---
id: TASK-55
title: Separate GlobalVarsWriter into GlobalVarsFormatter and a thin I/O wrapper
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:29'
labels:
  - refactor
  - srp
dependencies: []
priority: medium
ordinal: 9000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
GlobalVarsWriter mixes content formatting logic (`build_content` and private helpers) with file I/O (`append`, `read_names`). Separate into `GlobalVarsFormatter` (pure, testable logic) and a thin `GlobalVarsWriter` I/O wrapper.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Created GlobalVarsFormatter with all pure logic (build_content + 4 private helpers). GlobalVarsWriter reduced to 2 I/O methods (append, read_names) that delegate formatting to GlobalVarsFormatter. Added spec/global_vars_formatter_spec.rb with 8 examples covering all 4 content-building branches directly without file I/O. 549 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
