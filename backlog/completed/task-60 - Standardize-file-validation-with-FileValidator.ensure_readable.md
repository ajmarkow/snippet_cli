---
id: TASK-60
title: Standardize file validation with FileValidator.ensure_readable!
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:26'
labels:
  - refactor
  - consistency
dependencies: []
priority: medium
ordinal: 11000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Three inconsistent patterns are used for file-not-found: delegating to YamlLoader, manual `File.exist?` + `UI.error`, and silent `return unless`. Standardize via `FileValidator.ensure_readable!(path)` that raises or exits consistently.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added FileHelper.ensure_readable!(path) — warns to stderr and exits 1 if file not found. Placed in FileHelper (not FileValidator) since it's a filesystem operation, not schema validation. Updated yaml_loader.rb to use it (replacing the inline unless/warn/exit). Updated conflict.rb to call FileHelper.ensure_readable! directly, removing the private validate_file! method and its UI.error call. Updated conflict_spec to check stderr via output().to_stderr instead of mocking UI.error. 541 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
