---
id: TASK-60
title: Standardize file validation with FileValidator.ensure_readable!
status: To Do
assignee: []
created_date: '2026-04-08 21:04'
labels:
  - refactor
  - consistency
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Three inconsistent patterns are used for file-not-found: delegating to YamlLoader, manual `File.exist?` + `UI.error`, and silent `return unless`. Standardize via `FileValidator.ensure_readable!(path)` that raises or exits consistently.
<!-- SECTION:DESCRIPTION:END -->
