---
id: TASK-39
title: Add trim specs for shell and script vars in match_contract_spec.rb
status: Done
assignee: []
created_date: '2026-04-03 16:15'
updated_date: '2026-04-03 19:11'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## Context

`MatchValidator` now uses `Espanso_Merged_Matchfile_Schema.json`, which already correctly includes `trim` for both shell and script var params. `var_builder/params.rb` already prompts for `trim` via `debug_trim` for both types.

The only gap is missing spec coverage.

## Fix

In `spec/match_contract_spec.rb`, under the `shell` context add:
- accepts shell var with `trim: true`
- accepts shell var with `trim: false`
- rejects shell var with non-boolean trim (e.g. `trim: 'yes'`)

Under the `script` context, add equivalent tests.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `MatchValidator.valid?` returns true for a shell var with `trim: true`.
- [ ] #2 `MatchValidator.valid?` returns true for a script var with `trim: true`.
- [ ] #3 `MatchValidator.valid?` still rejects a shell var with `trim: 'yes'` (non-boolean).
- [ ] #4 New specs cover all three cases for each var type.
- [ ] #5 `additionalProperties: false` is preserved on both params blocks (unknown keys still rejected).
<!-- SECTION:DESCRIPTION:END -->

<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Switched MatchValidator to use Espanso_Merged_Matchfile_Schema.json. Since the merged schema validates a full matchfile (requires `matches:` at root), added a `wrap` helper that envelopes each entry as `{ "matches" => [entry] }` before validation.\n\nAlso fixed four gaps in the merged schema exposed by the existing test suite:\n- Added `\"params\"` to `required` for shell, script, date, echo, choice, form, random, match var branches\n- Fixed date `offset` type from `[\"number\", \"string\"]` to `\"integer\"`\n- Added optional `params` property to clipboard branch\n- Added a `global` var branch\n\nAdded 6 new trim specs (shell + script × accept true/false/reject non-boolean). All 368 examples pass.
<!-- SECTION:FINAL_SUMMARY:END -->
