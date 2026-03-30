---
id: TASK-21
title: Display variables in a table (name + type)
status: Done
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-30 04:57'
labels:
  - vars
  - ux
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
After collecting variables, display them in a formatted table showing each variable's name and type for user review before proceeding.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Variables displayed in a Gum table with Name and Type columns after each var is added
- [x] #2 Replaces the old flat-string summary format
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Replaced show_summary in VarBuilder from UI.success flat string to Gum.table with Name/Type columns. Updated spec to verify Gum.table is called with correct rows and columns.
<!-- SECTION:FINAL_SUMMARY:END -->
