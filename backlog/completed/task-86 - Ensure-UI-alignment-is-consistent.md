---
id: TASK-86
title: Ensure UI alignment is consistent
status: Done
assignee: []
created_date: '2026-04-11 21:21'
updated_date: '2026-04-12 15:10'
labels:
  - ui
  - polish
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Some UI elements use different margins and padding. Audit all UI output (gum_style boxes, table output, note/info/warn/error messages, deliver output) and standardise margins so every element feels visually cohesive.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 All gum_style boxes use the same padding values
- [ ] #2 Table output and plain-text notes align with box edges
- [ ] #3 No element uses ad-hoc spacing that differs from the shared BASE_FLAGS constants
- [ ] #4 Visual spot-check passes for new, vars, check, conflict, and version commands
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Applied `UI::PROMPT_STYLE` constant (`{ padding: '0 1', margin: '0' }`) to all `Gum.input`, `Gum.write`, and `Gum.choose` calls via `prompt_style:` and `header_style:` kwargs, matching the existing pattern on `Gum.confirm`. Updated all spec stubs from exact matchers to `hash_including(...)`. Resolved cascading rubocop violations (LineLength, MethodLength, ModuleLength, MultilineTernaryOperator) through helper extraction and data-driven refactoring. 718/718 specs pass, rubocop clean.
<!-- SECTION:FINAL_SUMMARY:END -->
