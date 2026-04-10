---
id: TASK-53
title: >-
  Split ReplacementCollector into ReplacementTextCollector and
  ReplacementValidator
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-10 22:06'
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
Split ReplacementCollector into ReplacementTextCollector (prompt strategies) and ReplacementValidator (var-usage validation). Moved orchestration methods (collect_replacement, select_alt_type, collect_replace_with_check, collect_alt_with_check, collect_with_check) into Commands::New. Extracted collect_with_check to DRY up identical retry loops. Deleted replacement_collector.rb. All 672 examples pass, RuboCop clean.
<!-- SECTION:FINAL_SUMMARY:END -->
