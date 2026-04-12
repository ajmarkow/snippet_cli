---
id: TASK-68
title: >-
  Extract shared SchemaValidator to eliminate duplication between MatchValidator
  and FileValidator
status: Done
assignee: []
created_date: '2026-04-10 21:17'
updated_date: '2026-04-10 21:27'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Schema path constant, schemer memoization, and error mapping are duplicated between `MatchValidator` and `FileValidator`.

**Evidence:**
- Repeated schema path + schemer memoization: `lib/snippet_cli/match_validator.rb:13-15`, `:38-40`; `lib/snippet_cli/file_validator.rb:11-13`, `:30-32`
- Similar `HashUtils.stringify_keys_deep` + error mapping flow in both validators

**Plan:**
1. Create shared `SchemaValidator` base/service that loads schemer once and formats errors
2. Keep entry-specific behavior (e.g., `wrap` for single-match validation) in tiny adapters that delegate to it
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Single SchemaValidator loads the schema file once
- [x] #2 MatchValidator and FileValidator delegate to SchemaValidator
- [x] #3 Error formatting is defined in one place
- [x] #4 All existing validation tests pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Extracted `SnippetCli::SchemaValidator` to `lib/snippet_cli/schema_validator.rb`. It owns `SCHEMA_PATH`, the memoized `schemer` instance, and exposes `valid?(data)` and `validate(data)`.

Both adapters simplified:
- `MatchValidator` — dropped `SCHEMA_PATH`, `schemer`, `require 'json_schemer'`; delegates to `SchemaValidator.valid?` / `SchemaValidator.validate`
- `FileValidator` — same removals; delegates likewise

Error formatting stays in each adapter (pointer context in `FileValidator`, plain message in `MatchValidator`).

Added `spec/schema_validator_spec.rb` with 6 tests covering valid/invalid paths and memoization. All 632 examples pass.
<!-- SECTION:FINAL_SUMMARY:END -->
