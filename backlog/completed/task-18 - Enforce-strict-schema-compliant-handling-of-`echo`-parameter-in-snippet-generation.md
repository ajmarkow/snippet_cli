---
id: TASK-18
title: >-
  Enforce strict schema-compliant handling of `echo` parameter in snippet
  generation
status: Done
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-31 03:52'
labels:
  - validation
  - schema
milestone: none
dependencies:
  - TASK-27
priority: high
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ensure the CLI (UI and business logic) correctly collects structures and outputs the `echo` parameter in a way that is fully compliant with the Espanso schema. Fix the data flow from user input to internal representation to final YAML output so it aligns with schema expectations. Define valid contexts for echo expected structure and type and ensure alignment with the merged schema used by `snippet validate`. This is strict enforcement and invalid structure should not be produced.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 CLI correctly collects echo input from user where applicable
- [x] #2 Internal representation of echo matches schema expectations
- [x] #3 Output YAML includes echo in the correct location and format
- [x] #4 Generated snippets with echo pass schema validation via `snippet validate`
- [x] #5 Invalid or malformed echo input is prevented or corrected before output
- [x] #6 At least one end-to-end test covers input to YAML to validation
- [x] #7 No regressions for snippets that do not use echo
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Completed remaining ACs (#4, #5, #6) via tests in `spec/snippet_builder_spec.rb`.

**AC #5** — `SnippetBuilder.build` already calls `validate!` via `MatchValidator` before emitting YAML. New tests confirm it raises `ValidationError` for: missing `echo` key in params, non-string `echo` value, and unknown params — all caught before any output.

**AC #4 + #6** — End-to-end test: calls `SnippetBuilder.build` with a valid echo var, parses the emitted YAML back with `YAML.safe_load`, wraps it in `{ matches: [...] }`, and asserts `FileValidator.errors` returns empty. This proves the full pipeline (input → YAML → schema validation via `snippet validate`) is clean.

5 new echo-specific examples added to `spec/snippet_builder_spec.rb`. Full suite: 251 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
