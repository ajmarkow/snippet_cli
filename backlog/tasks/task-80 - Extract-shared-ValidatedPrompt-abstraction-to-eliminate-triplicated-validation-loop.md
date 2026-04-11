---
id: TASK-80
title: >-
  Extract shared ValidatedPrompt abstraction to eliminate triplicated validation
  loop
status: Done
assignee: []
created_date: '2026-04-11 15:47'
updated_date: '2026-04-11 20:18'
labels:
  - architecture
  - refactor
  - dry
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The pattern "prompt user → validate → display transient error → retry" is implemented three separate times:
- `NewWorkflow#collect_with_check` (`new_workflow.rb:102–109`)
- `WizardHelpers#prompt_until_valid` and `#prompt_non_empty` (`wizard_helpers.rb:80–98`)
- `VarBuilder::NameCollector` (`var_builder/name_collector.rb:25–27`)

Each implementation diverges slightly in error display and retry behavior, making bug fixes and UX improvements require multiple edits. The missing abstraction is a single `validated_prompt` primitive: prompt, yield value to a validator block, show transient error, retry until valid.

Depends on the WizardHelpers decomposition task if that lands first.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A single validated-prompt primitive exists (method or small class) that accepts a prompt block and a validation block
- [x] #2 All three call sites are replaced with the shared primitive
- [x] #3 Transient error display and retry behavior are consistent across all former call sites
- [x] #4 All existing specs pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Extended `ValidationLoop#prompt_until_valid` to handle both String errors (shows via `UI.transient_warning`) and Callable errors (uses directly as clear lambda). This lets `NewWorkflow#collect_with_check` delegate to `prompt_until_valid` instead of maintaining its own loop. `collect_with_check` reduced from 7 lines to 3. All three call sites now share the same primitive. 701 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
