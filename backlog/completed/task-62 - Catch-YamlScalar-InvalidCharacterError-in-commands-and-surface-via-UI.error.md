---
id: TASK-62
title: 'Catch YamlScalar::InvalidCharacterError in commands and surface via UI.error'
status: Done
assignee: []
created_date: '2026-04-08 21:05'
updated_date: '2026-04-08 23:07'
labels:
  - bug
  - error-handling
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`YamlScalar::InvalidCharacterError` is raised in `yaml_scalar.rb:36` but never rescued anywhere, causing an unformatted crash. Catch it in the relevant commands and display a user-friendly message via `UI.error`.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added `YamlScalar::InvalidCharacterError` to the rescue clause in `commands/new.rb` alongside `ValidationError` and `EspansoConfigError`. The error message is surfaced via `UI.error` and exits with code 1. No change needed in other commands — only `new.rb` calls through `SnippetBuilder` which invokes `YamlScalar.quote`.
<!-- SECTION:FINAL_SUMMARY:END -->
