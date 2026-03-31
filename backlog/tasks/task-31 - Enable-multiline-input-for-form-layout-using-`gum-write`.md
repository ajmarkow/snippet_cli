---
id: TASK-31
title: Enable multiline input for form layout using `gum write`
status: To Do
assignee: []
created_date: '2026-03-30 21:41'
updated_date: '2026-03-30 22:01'
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
- [ ] #1 Form layout input uses `gum write` (multiline) instead of single-line input
- [ ] #2 Users can enter multi-line form definitions without errors
- [ ] #3 Line breaks are correctly preserved or transformed in output YAML
- [ ] #4 Generated `form:` output is valid and matches user input structure
- [ ] #5 Input experience is smooth with no broken controls or unexpected exits
- [ ] #6 At least one example of multi-line form input produces correct snippet output
<!-- AC:END -->
