---
id: TASK-19
title: Ensure schema enforces all required fields for valid snippet definitions
status: Done
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-04-02 20:31'
labels:
  - validation
  - schema
milestone: none
dependencies:
  - TASK-12
priority: high
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update the schema and validation flow so that all required fields for a valid Espanso snippet are strictly enforced. This includes required top-level fields required fields within each match object and any required fields introduced by custom extensions. Define conditional requirements such as one-of constraints (e.g. exactly one of replace form image_path) and ensure alignment with `snippet validate`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Missing required top-level fields fail validation with clear errors
- [x] #2 Missing required fields within a match fail validation
- [x] #3 Conditional requirements (e.g. exactly one of replace form image_path) are enforced
- [x] #4 Validation errors clearly indicate which field is missing and where
- [x] #5 At least one invalid fixture per required field case
- [x] #6 No false positives valid snippets are not rejected
- [x] #7 Fully integrated with `snippet validate`
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
All schema enforcement was already in place (from TASK-12). Added explicit test coverage for the untested cases: var required fields (name, type) via new fixture files `invalid_var_missing_name.yml` / `invalid_var_missing_type.yml`; conditional replacement requirements (both replace+form, replace+image_path, html+markdown all rejected); JSON pointer path test for var-level errors. All 7 ACs verified. 334 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
