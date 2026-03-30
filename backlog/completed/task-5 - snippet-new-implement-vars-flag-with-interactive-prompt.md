---
id: TASK-5
title: 'snippet new: implement --vars flag with interactive prompt'
status: Done
assignee: []
created_date: '2026-03-27 20:16'
updated_date: '2026-03-30 04:12'
labels:
  - feature
  - snippet-new
  - vars
  - interactive
dependencies: []
references:
  - docs/plan-rev1.md
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a `--vars` flag to `snippet new` that launches an interactive prompt flow for defining variables. Rather than separate per-type flags, a single `--vars` flag signals that the user wants to attach one or more variables to the match, and the CLI guides them through the process interactively.

The interactive flow should ask the user to:
1. Choose a var type (shell, date, random, choice, script)
2. Provide the type-specific parameters (e.g. command string, date format, comma-separated values, script path)
3. Optionally add another var, repeating until done

Each defined var is emitted in the `vars:` array of the output YAML with the correct `type` and `params` structure per the Espanso match schema.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Running `snippet new --trigger :x --replace '{{out}}' --vars` launches an interactive prompt
- [ ] #2 User can select a var type from: shell, date, random, choice, script
- [ ] #3 Each type prompts for the appropriate parameters (command, format, values list, script path, etc.)
- [ ] #4 User is offered the option to add another var after completing each one
- [ ] #5 All defined vars appear as correctly structured entries in the output YAML `vars:` array
- [ ] #6 Output YAML is valid against the Espanso match schema
- [ ] #7 Omitting --vars produces output with no `vars:` key (non-interactive path unchanged)
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Decided not to implement. The interactive var flow is always available in the wizard; a separate --vars flag is unnecessary.
<!-- SECTION:FINAL_SUMMARY:END -->
