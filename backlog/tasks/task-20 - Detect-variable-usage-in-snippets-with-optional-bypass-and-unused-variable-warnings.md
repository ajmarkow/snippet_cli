---
id: TASK-20
title: >-
  Detect variable usage in snippets with optional bypass and unused variable
  warnings
status: To Do
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-30 21:59'
labels:
  - vars
  - ux
milestone: none
dependencies: []
priority: medium
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Analyze snippet definitions to detect variables that are declared but never used and variables that are used but not declared. Provide warnings for unused variables and an option to bypass or suppress these checks (e.g. via CLI flag or config). Clarify whether this runs during snippet new validate or both and define which cases are warnings vs errors.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Declared but unused variables are detected and surfaced as warnings
- [ ] #2 Used but undeclared variables are detected with defined behavior (warn or error)
- [ ] #3 Users can bypass or suppress warnings via a defined mechanism
- [ ] #4 Warnings are clearly formatted and actionable
- [ ] #5 At least one example each for unused variable valid usage and bypassed warning
- [ ] #6 Integrated into appropriate flow (snippet new validate or both)
<!-- AC:END -->
