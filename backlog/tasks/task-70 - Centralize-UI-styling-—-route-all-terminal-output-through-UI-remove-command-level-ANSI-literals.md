---
id: TASK-70
title: >-
  Centralize UI styling — route all terminal output through UI, remove
  command-level ANSI literals
status: In Progress
assignee: []
created_date: '2026-04-10 21:17'
updated_date: '2026-04-10 21:35'
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
- [ ] #1 UI style presets defined in a single map/constant
- [ ] #2 No raw ANSI escape codes outside of UI module
- [ ] #3 Commands::Conflict routes output through UI
- [ ] #4 All existing tests pass
<!-- AC:END -->
