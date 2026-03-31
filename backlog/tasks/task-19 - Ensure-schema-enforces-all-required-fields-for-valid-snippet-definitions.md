---
id: TASK-19
title: Ensure schema enforces all required fields for valid snippet definitions
status: To Do
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-30 22:02'
labels:
  - validation
  - schema
milestone: none
dependencies:
  - TASK-12
priority: high
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update the schema and validation flow so that all required fields for a valid Espanso snippet are strictly enforced. This includes required top-level fields required fields within each match object and any required fields introduced by custom extensions. Define conditional requirements such as one-of constraints (e.g. exactly one of replace form image_path) and ensure alignment with `snippet validate`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Missing required top-level fields fail validation with clear errors
- [ ] #2 Missing required fields within a match fail validation
- [ ] #3 Conditional requirements (e.g. exactly one of replace form image_path) are enforced
- [ ] #4 Validation errors clearly indicate which field is missing and where
- [ ] #5 At least one invalid fixture per required field case
- [ ] #6 No false positives valid snippets are not rejected
- [ ] #7 Fully integrated with `snippet validate`
<!-- AC:END -->
