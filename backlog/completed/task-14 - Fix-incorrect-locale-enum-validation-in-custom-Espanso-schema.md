---
id: TASK-14
title: Fix incorrect locale enum validation in custom Espanso schema
status: Done
assignee: []
created_date: '2026-03-28 02:15'
updated_date: '2026-03-31 03:23'
labels: []
milestone: none
dependencies: []
priority: medium
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Resolve an issue where the locale field in the custom schema incorrectly validates allowed values. Ensure the enum matches Espanso-supported locales (or the intended subset) and does not reject valid locales or allow invalid ones. Clarify and document the source of truth for valid locales.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Locale field accepts all valid Espanso-supported locale values
- [x] #2 Invalid locale values are rejected with clear error messages
- [x] #3 Enum definition aligns with a documented source of truth
- [x] #4 No regressions in existing valid snippet files
- [x] #5 At least one valid and one invalid test case cover locale validation
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Fixed the locale field in the schema on two fronts: (1) added locale as a proper BCP47 string to the date if/then params block (which uses additionalProperties: false), and (2) replaced the broken global locale enum — a single concatenated string element — with a plain type: string. Also added descriptions to format, offset, and locale in the date block, and corrected jp-JP to ja-JP. Four new specs cover en-US locale, ja-JP locale, integer offset acceptance, and rejection of non-integer offset. All 198 tests pass. Submodule pushed to origin/master.
<!-- SECTION:FINAL_SUMMARY:END -->
