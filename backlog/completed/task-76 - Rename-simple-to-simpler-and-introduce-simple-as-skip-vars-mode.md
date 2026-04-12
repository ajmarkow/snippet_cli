---
id: TASK-76
title: Rename --simple to --simpler and introduce --simple as skip-vars mode
status: Done
assignee: []
created_date: '2026-04-11 04:50'
updated_date: '2026-04-11 04:56'
labels:
  - feature
  - ux
dependencies: []
priority: medium
ordinal: 2500
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Rename the existing `--simple` flag to `--simpler` and repurpose `--simple` as the new middle-ground mode that skips variable collection but retains full replacement type options.

## Flag semantics after this change

- `--simpler`: current `--simple` behavior — skips vars AND forces plain single-line replace only. Fastest path.
- `--simple`: skips VarBuilder but allows alt replacement types (markdown, html, image_path) and multiline. No var type prompts. Advanced options gate still appears.
- _(no flag)_: full wizard — VarBuilder, all replacement types, advanced options.

## Implementation notes

- Rename `:simple` option key to `:simpler` throughout `Commands::New`, `NewWorkflow`, and specs.
- Add `:simple` option key in `Commands::New` dry-cli flag definition.
- In `resolve_replacement` in `new_workflow.rb`, add an early return for `simple:` that bypasses `VarBuilder.run` but still calls `collect_replacement` and `collect_advanced` with `vars: []`.
- `vars: []` is passed to SnippetBuilder — no vars block in output.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 --simpler flag has the exact behavior of the current --simple (skip vars, plain single-line replace only)
- [x] #2 --simple flag skips VarBuilder but allows alt replacement types and multiline
- [x] #3 Trigger collection works normally for both flags (regular, multi-trigger, regex)
- [x] #4 Show advanced options? gate still appears for --simple
- [x] #5 vars: [] is passed to SnippetBuilder for both flags — no vars block in output
- [x] #6 Specs cover --simple and --simpler paths, full wizard path unaffected
- [x] #7 All existing --simple specs updated to --simpler
<!-- AC:END -->
