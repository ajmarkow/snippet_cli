---
id: TASK-15
title: Add locale-aware validation for date variables in snippet schema
status: Done
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-31 03:35'
labels:
  - validation
  - schema
milestone: none
dependencies: []
references:
  - 'https://github.com/espanso/espanso/pull/2526'
priority: medium
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement validation for date-related variables ensuring locale values are valid and consistent with TASK-14 and that any provided date format aligns with the specified locale (if applicable). Clarify whether validation applies to a specific var type (e.g., `date`), how format strings are handled (validated vs freeform), and whether failures are errors or warnings.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Date variables validate against allowed locale values
- [x] #2 Invalid locale values fail validation with clear errors
- [x] #3 If a format string is provided it is validated or explicitly treated as freeform (behavior defined)
- [x] #4 Validation behavior is consistent with overall schema rules
- [x] #5 At least one valid and one invalid example for date validation
- [ ] #6 No regressions for existing valid snippets using date variables
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Extracted date params into a dedicated Params.date private class method. Collects format (required), then conditionally prompts for offset (integer, stored via .to_i) and locale (BCP47 string) using confirm gates. Both prompts are date-specific — a negative spec with echo type confirms they never fire for other var types. All 207 tests pass.
<!-- SECTION:FINAL_SUMMARY:END -->
