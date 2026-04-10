---
id: TASK-52
title: Extract TransientValidatedPrompt helper for loop-until-valid prompt pattern
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-10 22:49'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
ordinal: 6000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The "loop until valid with transient feedback" prompt pattern is written 3 times: `replacement_collector.rb:35-53`, `trigger_resolver.rb:93-101`, `var_builder/name_collector.rb:23-34`. Extract a reusable `TransientValidatedPrompt` helper.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 prompt_until_valid added to WizardHelpers as the general loop-until-valid primitive
- [x] #2 prompt_non_empty delegates to prompt_until_valid
- [x] #3 NameCollector#collect uses prompt_until_valid; checkpoint_warning removed
- [x] #4 All existing tests pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added `prompt_until_valid` to `WizardHelpers` as the general loop-until-valid primitive. Block yields `[value, error_or_nil]`; the helper handles clearing the previous transient warning and calling `UI.transient_warning` on each error.

Refactored `prompt_non_empty` to delegate to `prompt_until_valid` (block wraps the caller's prompt block and injects the empty-check error).

Refactored `NameCollector#collect` to use `prompt_until_valid`: extracted `name_validation_error` from the old `invalid_name_clear`, removed `checkpoint_warning` and `accepted_name` helpers (now redundant). Duplicate detection remains a post-loop check since it exits via `warn`+nil rather than re-prompting.

Added specs for both `prompt_until_valid` and `prompt_non_empty` in `wizard_helpers_spec.rb`. 690 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
