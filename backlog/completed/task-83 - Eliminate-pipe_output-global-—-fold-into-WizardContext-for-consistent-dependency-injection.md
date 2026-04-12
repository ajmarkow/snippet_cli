---
id: TASK-83
title: >-
  Eliminate pipe_output global — fold into WizardContext for consistent
  dependency injection
status: Done
assignee: []
created_date: '2026-04-11 15:47'
updated_date: '2026-04-12 14:20'
labels:
  - architecture
  - refactor
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`SnippetCli.pipe_output` (`lib/snippet_cli.rb:27–33`) is a global class variable accessed directly by `UI.deliver()` (`lib/snippet_cli/ui.rb:62–71`). This is a service locator antipattern. The codebase already has `WizardContext` as the right pattern for explicit context passing, but `pipe_output` bypasses it. New context needs (logging level, output format) will likely follow the global pattern if this isn't fixed first.

The fix is to move `pipe_output` into `WizardContext` and have `UI.deliver` receive context explicitly rather than reading a global.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 SnippetCli.pipe_output global is removed
- [x] #2 WizardContext carries the pipe_output flag (or equivalent)
- [x] #3 UI.deliver receives context as a parameter rather than reading a global
- [x] #4 Testing UI.deliver does not require setting global state
- [x] #5 All existing specs pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
## Changes

- `WizardContext` (`lib/snippet_cli/wizard_context.rb`): Added `pipe_output: nil` field to `Data.define`.
- `UI.deliver` (`lib/snippet_cli/ui.rb`): Signature changed to `deliver(yaml, label:, context: nil)`. Reads `context&.pipe_output` instead of the global `SnippetCli.pipe_output`.
- `NewWorkflow` (`lib/snippet_cli/new_workflow.rb`): `prepare_context` captures `SnippetCli.pipe_output` once and stores it in the context. `deliver_snippet` now receives the full context (not just `save_path`) and passes it to `UI.deliver`.
- `Commands::Vars` (`lib/snippet_cli/commands/vars.rb`): Now requires `wizard_context`, creates a `WizardContext.new(pipe_output: SnippetCli.pipe_output)` at the start of `call`, and passes context to `UI.deliver` via `deliver_vars`.
- Specs updated: `SnippetCli.pipe_output = pipe_io` + `after` cleanup replaced with `allow(SnippetCli).to receive(:pipe_output).and_return(pipe_io)` in both `new_spec.rb` and `vars_spec.rb`. `wizard_context_spec.rb` extended with `pipe_output` default and explicit-value tests.

All 718 examples pass.
<!-- SECTION:FINAL_SUMMARY:END -->
