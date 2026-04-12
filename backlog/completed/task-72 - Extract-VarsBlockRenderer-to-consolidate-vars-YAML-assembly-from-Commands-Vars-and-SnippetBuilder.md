---
id: TASK-72
title: >-
  Extract VarsBlockRenderer to consolidate vars YAML assembly from
  Commands::Vars and SnippetBuilder
status: Done
assignee: []
created_date: '2026-04-10 21:17'
updated_date: '2026-04-10 21:32'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Vars YAML block assembly is duplicated across the command and builder paths, risking drift.

**Evidence:**
- `lib/snippet_cli/commands/vars.rb:47-53` constructs lines manually
- `lib/snippet_cli/snippet_builder.rb:70-74` also owns vars block assembly

**Plan:**
1. Extract `VarsBlockRenderer.render(vars, indent:)`
2. Reuse from both `Commands::Vars` and `SnippetBuilder`
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 VarsBlockRenderer.render(vars, indent:) exists
- [x] #2 Commands::Vars and SnippetBuilder both delegate vars assembly to it
- [x] #3 Output format identical to current (verified by tests)
- [x] #4 All existing tests pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Extracted `SnippetCli::VarsBlockRenderer` to `lib/snippet_cli/vars_block_renderer.rb`. It exposes `render(vars, indent: '')` which returns an array of YAML lines — `["#{indent}vars:", ...var entries...]`. VarYamlRenderer continues to own per-entry indentation.

Both call sites updated:
- `Commands::Vars#vars_yaml` — replaced manual `lines = ['vars:']; vars.each { ... }` with `VarsBlockRenderer.render(vars).join("\n")`. Removed `var_lines` helper and `require_relative 'var_yaml_renderer'`.
- `SnippetBuilder.vars_lines` — replaced 3-line manual build with `VarsBlockRenderer.render(vars, indent: '  ')`. Removed `require_relative 'var_yaml_renderer'`.

Added `spec/vars_block_renderer_spec.rb` with 9 tests covering both indent modes and the empty-vars edge case. All 640 examples pass.
<!-- SECTION:FINAL_SUMMARY:END -->
