---
id: TASK-69
title: >-
  Extract FormFieldParser to consolidate duplicated [[field]] regex across
  modules
status: Done
assignee: []
created_date: '2026-04-10 21:17'
updated_date: '2026-04-10 21:24'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The same `[[field]]` parsing pattern is duplicated across multiple modules, creating drift risk.

**Evidence:**
- `lib/snippet_cli/var_builder/form_fields.rb:18`
- `lib/snippet_cli/var_usage_checker.rb:8`, `:34`
- `lib/snippet_cli/var_summary_renderer.rb:35-37`

**Plan:**
1. Extract `FormFieldParser.extract(layout)` helper
2. Replace all duplicated scans with parser calls
3. Add focused unit tests for parser edge cases
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 FormFieldParser module/class exists with extract method
- [x] #2 All 3+ call sites replaced with FormFieldParser.extract
- [x] #3 Unit tests cover edge cases (empty, nested brackets, no fields)
- [x] #4 All existing tests pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Extracted `SnippetCli::FormFieldParser` module to `lib/snippet_cli/form_field_parser.rb` with a single `extract(layout)` method. Replaced all 3 duplicated `[[field]]` regex scan call sites:

- `lib/snippet_cli/var_builder/form_fields.rb:18` → `FormFieldParser.extract(layout)`
- `lib/snippet_cli/var_usage_checker.rb` → removed `FORM_FIELD_PATTERN` constant, uses `FormFieldParser.extract(layout)`
- `lib/snippet_cli/var_summary_renderer.rb:36` → `FormFieldParser.extract(layout)`

Added `spec/form_field_parser_spec.rb` with 8 edge-case tests (nil, empty, whitespace, no fields, single field, multi-field, duplicate names, non-matching `{{}}` refs). All 626 examples pass.
<!-- SECTION:FINAL_SUMMARY:END -->
