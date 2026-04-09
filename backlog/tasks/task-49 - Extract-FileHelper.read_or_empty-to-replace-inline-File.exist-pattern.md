---
id: TASK-49
title: Extract FileHelper.read_or_empty to replace inline File.exist? pattern
status: To Do
assignee: []
created_date: '2026-04-08 21:04'
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
