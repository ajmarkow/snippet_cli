---
id: TASK-14
title: Fix incorrect locale enum validation in custom Espanso schema
status: To Do
assignee: []
created_date: '2026-03-28 02:15'
updated_date: '2026-03-30 21:50'
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
- [ ] #1 Locale field accepts all valid Espanso-supported locale values
- [ ] #2 Invalid locale values are rejected with clear error messages
- [ ] #3 Enum definition aligns with a documented source of truth
- [ ] #4 No regressions in existing valid snippet files
- [ ] #5 At least one valid and one invalid test case cover locale validation
<!-- AC:END -->
