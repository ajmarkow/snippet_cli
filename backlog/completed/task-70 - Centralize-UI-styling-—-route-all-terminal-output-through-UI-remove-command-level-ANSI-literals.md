---
id: TASK-70
title: >-
  Centralize UI styling — route all terminal output through UI, remove
  command-level ANSI literals
status: Done
assignee: []
created_date: '2026-04-10 21:17'
updated_date: '2026-04-10 21:40'
labels:
  - refactor
  - dry
  - ui
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Output styling and terminal rendering concerns are duplicated and inconsistent across `UI` and command modules.

**Evidence:**
- `UI` has multiple near-identical style wrappers: `lib/snippet_cli/ui.rb:12-30`
- Raw ANSI output outside `UI` in conflict command: `lib/snippet_cli/commands/conflict.rb:46`, `:62`

**Plan:**
1. Define UI style presets (`:info`, `:warning`, `:error`, etc.) in one map
2. Route all human-facing terminal output through `UI` only
3. Remove command-level ANSI literals
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 UI style presets defined in a single map/constant
- [x] #2 No raw ANSI escape codes outside of UI module
- [x] #3 Commands::Conflict routes output through UI
- [x] #4 All existing tests pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Centralised UI styling in `lib/snippet_cli/ui.rb`:
- Added `BASE_FLAGS = ['--border=rounded', '--padding=0 4'].freeze` — shared base for all gum style calls
- Added `STYLE_FLAGS` map keyed by preset (`:info`, `:hint`, `:success`, `:warning`, `:error`, `:preview`) holding variant flags only
- All six named style methods collapsed to one-liners: `def self.info(text) = gum_style(text, *STYLE_FLAGS[:info])`
- `gum_style` now spreads `*BASE_FLAGS, *extra_flags` — base flags defined once

Removed raw ANSI literals from `lib/snippet_cli/commands/conflict.rb` (lines 46 and 62): both `puts "\e[38;5;231m...\e[0m"` replaced with `UI.note(...)`.

Added tests: `STYLE_FLAGS`/`BASE_FLAGS` constant shape in `ui_spec.rb`; `UI.note` delegation assertion in `conflict_spec.rb`. All 648 examples pass.
<!-- SECTION:FINAL_SUMMARY:END -->
