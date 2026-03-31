---
id: TASK-31
title: Enable multiline input for form layout using `gum write`
status: Done
assignee: []
created_date: '2026-03-30 21:41'
updated_date: '2026-03-31 03:11'
labels: []
milestone: none
dependencies: []
priority: low
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update the form creation flow to use multiline input via `gum write` instead of single-line input when defining form layouts. This enables more complex and readable form structures and better visualization of multi-field layouts. Clarify how line breaks are handled in the final `form:` output.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Form layout input uses `gum write` (multiline) instead of single-line input
- [x] #2 Users can enter multi-line form definitions without errors
- [x] #3 Line breaks are correctly preserved or transformed in output YAML
- [x] #4 Generated `form:` output is valid and matches user input structure
- [x] #5 Input experience is smooth with no broken controls or unexpected exits
- [ ] #6 At least one example of multi-line form input produces correct snippet output
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Replaced `Gum.input` with `Gum.write` for form layout collection in `VarBuilder::Params`. Header prompts with `[[field_name]]` syntax hint. Multiline input is preserved as-is in `params[:layout]`. Three new specs added covering gum write usage, multiline storage, and absence of the old gum input call. All 194 tests pass.
<!-- SECTION:FINAL_SUMMARY:END -->
