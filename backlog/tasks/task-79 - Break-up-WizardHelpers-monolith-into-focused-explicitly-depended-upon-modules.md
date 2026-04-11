---
id: TASK-79
title: 'Break up WizardHelpers monolith into focused, explicitly-depended-upon modules'
status: Done
assignee: []
created_date: '2026-04-11 15:47'
updated_date: '2026-04-11 20:01'
labels:
  - architecture
  - refactor
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
WizardHelpers (`lib/snippet_cli/wizard_helpers.rb`) is a mixed-concern module that any class can `include` to get: error handling (`handle_errors`), prompt coordination (`prompt!`, `list_confirm!`, `optional_prompt`), file selection (`pick_match_file`), validation loops (`prompt_until_valid`), and search-term collection (`collect_search_terms`). Includers get all helpers regardless of which they need, creating implicit dependencies. The broad `rescue` in the error handler (lines 67–75) additionally obscures control flow.

The goal is to split this into focused modules or classes so that dependencies are explicit and each concern can evolve independently.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 WizardHelpers is split into at minimum: a prompt primitives module, a validation loop abstraction, and a file-selection helper
- [x] #2 No module includes more helpers than it actually uses
- [x] #3 The broad rescue in handle_errors is narrowed to specific exception types or removed in favor of the typed exception pattern from TASK-66
- [x] #4 All existing specs pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Split `WizardHelpers` monolith into four focused sub-modules under `lib/snippet_cli/wizard_helpers/`:\n\n- `PromptHelpers` — `prompt!`, `confirm!`, `list_confirm!`, `optional_prompt`\n- `ValidationLoop` — `prompt_until_valid`, `prompt_non_empty`\n- `MatchFileSelector` — `pick_match_file`, `abort_no_match_files` (includes `PromptHelpers`)\n- `ErrorHandler` — `handle_errors`\n\n`wizard_helpers.rb` is now a convenience require-only file. All 8 includers updated to `include` only the specific modules they need. `collect_search_terms` inlined into `NewWorkflow` (sole caller). Specs split into `spec/wizard_helpers/` with one file per module. 698 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
