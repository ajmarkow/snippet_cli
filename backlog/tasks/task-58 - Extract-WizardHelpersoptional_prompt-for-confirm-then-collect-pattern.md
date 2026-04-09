---
id: TASK-58
title: Extract WizardHelpers#optional_prompt for confirm-then-collect pattern
status: To Do
assignee: []
created_date: '2026-04-08 21:04'
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
