---
id: TASK-67
title: 'Introduce NewWorkflow and WizardContext to untangle Commands::New'
status: Done
assignee: []
created_date: '2026-04-10 21:17'
updated_date: '2026-04-10 22:16'
labels:
  - refactor
  - srp
  - oop
dependencies:
  - TASK-53
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`Commands::New` orchestrates too many concerns through mixins and implicit instance-variable state.

**Evidence:**
- `lib/snippet_cli/commands/new.rb:18-93` mixes trigger resolution, replacement collection, wizard helpers, save flow, and output flow
- `@summary_clear` and `@global_var_names` set at `new.rb:58-59`, `new.rb:71-73`
- `ReplacementCollector` reaches into `@global_var_names` dynamically: `lib/snippet_cli/replacement_collector.rb:67-70`

**Plan:**
1. Introduce `NewWorkflow` that receives dependencies explicitly (`trigger_resolver`, `replacement_collector`, `var_builder`, `writers`, `ui`)
2. Replace implicit instance-variable communication with explicit `WizardContext` data object carrying `global_var_names`, `summary_clear`
3. Keep `Commands::New#call` as thin command adapter only
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 NewWorkflow class exists and receives all deps via constructor
- [x] #2 WizardContext value object carries shared state
- [x] #3 Commands::New#call is a thin adapter delegating to NewWorkflow
- [x] #4 No implicit @instance_variable sharing between command and collector
- [x] #5 All existing tests pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Introduced `NewWorkflow` and `WizardContext` to untangle `Commands::New`.

**Files created:**
- `lib/snippet_cli/wizard_context.rb` — `Data.define` value object carrying `global_var_names` and `save_path`
- `lib/snippet_cli/new_workflow.rb` — owns all wizard orchestration (trigger resolution, replacement collection, save flow, output); includes the four mixins directly
- `spec/wizard_context_spec.rb` — unit tests for the value object
- `spec/new_workflow_spec.rb` — unit tests for `NewWorkflow#run`

**Files modified:**
- `lib/snippet_cli/replacement_validator.rb` — `var_error_clear` now accepts explicit `global_var_names:` keyword (default `[]`), removing the `defined?(@global_var_names)` instance-variable snoop
- `lib/snippet_cli/commands/new.rb` — reduced to a thin Dry::CLI adapter; `#call` delegates entirely to `NewWorkflow.new.run(opts)`
- `spec/replacement_validator_spec.rb` — added tests for the new explicit keyword

All 683 examples pass; line coverage 99.69%.
<!-- SECTION:FINAL_SUMMARY:END -->
