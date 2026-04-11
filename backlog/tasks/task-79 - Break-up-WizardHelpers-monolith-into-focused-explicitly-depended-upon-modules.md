---
id: TASK-79
title: 'Break up WizardHelpers monolith into focused, explicitly-depended-upon modules'
status: To Do
assignee: []
created_date: '2026-04-11 15:47'
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
- [ ] #1 WizardHelpers is split into at minimum: a prompt primitives module, a validation loop abstraction, and a file-selection helper
- [ ] #2 No module includes more helpers than it actually uses
- [ ] #3 The broad rescue in handle_errors is narrowed to specific exception types or removed in favor of the typed exception pattern from TASK-66
- [ ] #4 All existing specs pass
<!-- AC:END -->
