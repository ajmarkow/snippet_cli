---
id: TASK-35
title: Validate variable names to block prohibited characters that can break mappings
status: Done
assignee: []
created_date: '2026-04-02 16:15'
updated_date: '2026-04-02 20:08'
labels:
  - validation
  - variables
  - bug
milestone: M1
dependencies: []
priority: high
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add variable name validation to prevent variables containing hyphens (`-`) or other prohibited characters from breaking variable-to-mapping resolution. Ensure the same rules are enforced across all entry points where variable names are introduced or modified, with clear user-facing error messages and test coverage.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Variable names with prohibited characters (including `-`) are rejected at create/edit time with a clear error message
- [x] #2 Validation is applied consistently wherever variables can be defined/renamed/imported (e.g., UI, API, config/schema) so invalid names cannot enter the system
- [x] #3 Existing mappings do not break: invalid variable names are either prevented from being saved or safely handled with a non-crashing fallback behavior
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added `PROHIBITED_CHARS = %w[-].freeze` and `prohibited_char?` validation to `VarBuilder#collect_one_var` (UI path). Added `"pattern": "^\\w+$"` to all 9 variable `name` fields in `Espanso_Merged_Matchfile_Schema.json` and 1 in `Espanso_Match_Schema.json` (schema path). Tests added to `spec/file_validator_spec.rb` covering hyphen rejection, empty name rejection, and valid name acceptance. 327 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
