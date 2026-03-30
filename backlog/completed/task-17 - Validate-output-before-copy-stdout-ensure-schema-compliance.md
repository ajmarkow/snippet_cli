---
id: TASK-17
title: Validate output before copy/stdout (ensure schema compliance)
status: Done
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-30 04:53'
labels:
  - validation
  - schema
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a validation step that checks the generated YAML against the Espanso match schema before copying to clipboard or printing to stdout. Reject invalid output with clear error messages.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 SnippetBuilder.build validates match hash against vendored Espanso JSON schema before generating YAML
- [x] #2 Invalid match data raises ValidationError with descriptive schema errors
- [x] #3 New command catches ValidationError, prints errors to stderr, exits non-zero
- [x] #4 23 validator specs pass covering valid matches, missing/exclusive triggers and replacements, var validation
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented pre-output schema validation using json_schemer gem against the vendored Espanso match JSON schema (draft-07). MatchValidator module validates the Ruby hash before YAML serialization in SnippetBuilder.build, raising ValidationError on failure. Removed dry-validation dependency. 148 tests pass.
<!-- SECTION:FINAL_SUMMARY:END -->
