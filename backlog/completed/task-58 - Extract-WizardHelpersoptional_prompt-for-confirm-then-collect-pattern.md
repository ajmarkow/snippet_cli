---
id: TASK-58
title: Extract WizardHelpers#optional_prompt for confirm-then-collect pattern
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:18'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The pattern `confirm!('Add X?') ? prompt!(Gum.input(...)) : nil` is repeated across `commands/new.rb`, `var_builder/params.rb`, and `replacement_collector.rb`. Extract `WizardHelpers#optional_prompt(question, &collector)`.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added optional_prompt(question, &block) to WizardHelpers — calls confirm! and yields the block if confirmed, returns nil otherwise. Applied to commands/new.rb collect_advanced (label and comment). params.rb was not changed: the if-block pattern there conditionally sets hash keys, so assigning nil via optional_prompt would corrupt the params hash passed to YAML rendering. Added 4 new examples in wizard_helpers_spec. 538 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
