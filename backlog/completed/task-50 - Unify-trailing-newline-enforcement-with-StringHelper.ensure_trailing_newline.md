---
id: TASK-50
title: Unify trailing-newline enforcement with StringHelper.ensure_trailing_newline
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:12'
labels:
  - refactor
  - dry
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`match_file_writer.rb:16` uses inline mutation while `global_vars_writer.rb:78-81` has an extracted method — two approaches to the same concern. Create a shared `StringHelper.ensure_trailing_newline(str)` used by both.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Created StringHelper.ensure_trailing_newline(str) in lib/snippet_cli/string_helper.rb. Updated match_file_writer.rb to replace two inline `content << "\n" unless ...end_with?` mutations with StringHelper calls. Updated global_vars_writer.rb to replace the private ensure_newline method (and its callers) with StringHelper.ensure_trailing_newline, removing the now-redundant private method. Added spec/string_helper_spec.rb with 4 examples. 531 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
