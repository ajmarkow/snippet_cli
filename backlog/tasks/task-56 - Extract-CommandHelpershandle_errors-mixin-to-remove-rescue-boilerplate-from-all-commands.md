---
id: TASK-56
title: >-
  Extract CommandHelpers#handle_errors mixin to remove rescue boilerplate from
  all commands
status: To Do
assignee: []
created_date: '2026-04-08 21:04'
labels:
  - refactor
  - dry
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The same `rescue ValidationError / EspansoConfigError / WizardInterrupted` block with `UI.error + exit 1` is repeated verbatim in every command. Extract a `CommandHelpers#handle_errors { yield }` mixin and use it in all commands.
<!-- SECTION:DESCRIPTION:END -->
