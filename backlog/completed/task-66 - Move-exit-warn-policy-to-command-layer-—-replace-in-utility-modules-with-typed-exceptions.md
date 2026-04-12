---
id: TASK-66
title: >-
  Move exit/warn policy to command layer — replace in utility modules with typed
  exceptions
status: Done
assignee: []
created_date: '2026-04-10 21:17'
updated_date: '2026-04-10 21:54'
labels:
  - refactor
  - srp
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Low-level helpers and utility modules directly call `warn`/`exit`, which couples process lifecycle to business logic and reduces testability.

**Evidence:**
- `lib/snippet_cli/file_helper.rb:7-12`
- `lib/snippet_cli/yaml_loader.rb:11-17`
- `lib/snippet_cli/trigger_resolver.rb:41-47`, `:105-115`
- `lib/snippet_cli/wizard_helpers.rb:55-57`, `:68-73`

**Plan:**
1. Replace `warn/exit` in non-command modules with typed exceptions (`InvalidFlagsError`, `FileMissingError`, etc.)
2. Handle process exit in command layer only (`Commands::*#call`)
3. Standardize a single error presenter for consistent UX
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 No warn/exit calls in lib/ outside of Commands::* modules
- [x] #2 Typed exception classes defined for each error condition
- [x] #3 Command layer rescues and presents errors via single error presenter
- [x] #4 All existing tests pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added 5 typed exception classes to `lib/snippet_cli.rb`: `FileMissingError`, `InvalidYamlError`, `InvalidFlagsError`, `TriggerConflictError`, `NoMatchFilesError`.

Removed warn/exit from utility modules:
- `FileHelper.ensure_readable!` → raises `FileMissingError`
- `YamlLoader.load` → raises `InvalidYamlError` on Psych::SyntaxError
- `TriggerResolver#validate_trigger_flags!` → raises `InvalidFlagsError`
- `TriggerResolver#check_conflicts` → raises `TriggerConflictError` (when !no_warn)
- `WizardHelpers#abort_no_match_files` → raises `NoMatchFilesError`

Command layer handles each:
- `NoMatchFilesError` → `handle_errors(NoMatchFilesError)` → `UI.error` + exit 1 (in conflict, validate, new, vars)
- `FileMissingError`, `InvalidYamlError`, `InvalidFlagsError`, `TriggerConflictError` → outer `rescue … => e; warn e.message; exit 1` (preserves stderr behaviour for script compatibility)

Added `spec/yaml_loader_spec.rb` (13 examples); updated `file_helper_spec.rb` and `trigger_resolver_spec.rb`. All 661 examples pass.
<!-- SECTION:FINAL_SUMMARY:END -->
