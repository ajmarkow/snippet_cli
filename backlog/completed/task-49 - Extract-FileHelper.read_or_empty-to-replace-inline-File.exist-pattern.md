---
id: TASK-49
title: Extract FileHelper.read_or_empty to replace inline File.exist? pattern
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:08'
labels:
  - refactor
  - dry
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The pattern `File.exist?(path) ? File.read(path) : ''` appears inline in `match_file_writer.rb:10` and `global_vars_writer.rb:13`. Extract to `FileHelper.read_or_empty(path)`.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Created FileHelper module at lib/snippet_cli/file_helper.rb with read_or_empty(path) method. Updated match_file_writer.rb and global_vars_writer.rb to require and use FileHelper.read_or_empty instead of the inline File.exist? ternary. Added spec/file_helper_spec.rb with 2 examples covering file-exists and file-missing cases. 527 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
