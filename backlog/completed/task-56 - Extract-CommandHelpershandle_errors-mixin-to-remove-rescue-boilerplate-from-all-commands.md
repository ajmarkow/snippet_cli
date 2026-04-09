---
id: TASK-56
title: >-
  Extract CommandHelpers#handle_errors mixin to remove rescue boilerplate from
  all commands
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:05'
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

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added `handle_errors(*error_classes) { yield }` to WizardHelpers. It rescues any specified error classes (calling UI.error + exit 1) and always rescues WizardInterrupted (puts + UI.error). Updated all four commands: new.rb, vars.rb, validate.rb, conflict.rb. conflict.rb retains its own `rescue Psych::SyntaxError` outside the block (it uses warn to stderr, not UI.error). Added 9 new RSpec examples in wizard_helpers_spec covering block execution, WizardInterrupted, specified error classes, multiple error classes, and unspecified error propagation. 525 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
