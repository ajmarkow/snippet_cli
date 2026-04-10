---
id: TASK-67
title: 'Introduce NewWorkflow and WizardContext to untangle Commands::New'
status: To Do
assignee: []
created_date: '2026-04-10 21:17'
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
- [ ] #1 NewWorkflow class exists and receives all deps via constructor
- [ ] #2 WizardContext value object carries shared state
- [ ] #3 Commands::New#call is a thin adapter delegating to NewWorkflow
- [ ] #4 No implicit @instance_variable sharing between command and collector
- [ ] #5 All existing tests pass
<!-- AC:END -->
