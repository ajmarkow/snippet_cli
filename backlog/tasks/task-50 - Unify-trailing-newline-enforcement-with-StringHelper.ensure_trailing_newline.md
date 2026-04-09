---
id: TASK-50
title: Unify trailing-newline enforcement with StringHelper.ensure_trailing_newline
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
`match_file_writer.rb:16` uses inline mutation while `global_vars_writer.rb:78-81` has an extracted method — two approaches to the same concern. Create a shared `StringHelper.ensure_trailing_newline(str)` used by both.
<!-- SECTION:DESCRIPTION:END -->
