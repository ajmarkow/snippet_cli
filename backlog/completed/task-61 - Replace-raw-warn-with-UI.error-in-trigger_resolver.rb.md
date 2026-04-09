---
id: TASK-61
title: Replace raw warn with UI.error in trigger_resolver.rb
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-08 23:05'
labels:
  - refactor
  - consistency
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`trigger_resolver.rb:44` uses `warn` directly instead of `UI.error`. All error output should go through `UI` for consistency.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Replaced two raw `warn` calls in `trigger_resolver.rb` with `UI.error` for consistency with the rest of the codebase. Removed the "Error:" and "Warning:" prefixes from the messages since `UI.error` handles that presentation.
<!-- SECTION:FINAL_SUMMARY:END -->
