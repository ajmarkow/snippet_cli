---
id: TASK-53
title: >-
  Split ReplacementCollector into ReplacementTextCollector and
  ReplacementValidator
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-10 22:02'
labels:
  - refactor
  - srp
dependencies: []
priority: high
ordinal: 7000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
ReplacementCollector violates SRP — it handles prompt strategy, alt-type validation, variable usage warnings, and transient error clearing all in one module. Split into `ReplacementTextCollector` (prompt strategies) and `ReplacementValidator` (alt-type and var compatibility checks), with orchestration moved to the `New` command.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Split `ReplacementCollector` into two focused modules:

- `ReplacementTextCollector` (`lib/snippet_cli/replacement_text_collector.rb`) — pure Gum prompt strategies: `collect_replace`, `collect_alt_value`, `prompt_alt_input`, `prompt_non_empty_replace`, `EMPTY_REPLACE_WARNING`
- `ReplacementValidator` (`lib/snippet_cli/replacement_validator.rb`) — var usage validation: `var_error_clear`

Orchestration (`collect_replacement`, `select_alt_type`, `collect_replace_with_check`, `collect_alt_with_check`) moved to `Commands::New` as private methods. `Commands::New` now includes both modules directly. `replacement_collector.rb` deleted.

Added `spec/replacement_text_collector_spec.rb` and `spec/replacement_validator_spec.rb`. All 672 examples pass.
<!-- SECTION:FINAL_SUMMARY:END -->
