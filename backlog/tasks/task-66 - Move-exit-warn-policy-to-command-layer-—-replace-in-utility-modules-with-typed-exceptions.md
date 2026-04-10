---
id: TASK-66
title: >-
  Move exit/warn policy to command layer — replace in utility modules with typed
  exceptions
status: To Do
assignee: []
created_date: '2026-04-10 21:17'
labels:
  - refactor
  - srp
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Low-level helpers and utility modules directly call `warn`/`exit`, which couples process lifecycle to business logic and reduces testability.

**Evidence:**
- `lib/snippet_cli/file_helper.rb:7-12`
- `lib/snippet_cli/yaml_loader.rb:11-17`
- `lib/snippet_cli/trigger_resolver.rb:41-47`, `:105-115`
- `lib/snippet_cli/wizard_helpers.rb:55-57`, `:68-73`

**Plan:**
1. Replace `warn/exit` in non-command modules with typed exceptions (`InvalidFlagsError`, `FileMissingError`, etc.)
2. Handle process exit in command layer only (`Commands::*#call`)
3. Standardize a single error presenter for consistent UX
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 No warn/exit calls in lib/ outside of Commands::* modules
- [ ] #2 Typed exception classes defined for each error condition
- [ ] #3 Command layer rescues and presents errors via single error presenter
- [ ] #4 All existing tests pass
<!-- AC:END -->
