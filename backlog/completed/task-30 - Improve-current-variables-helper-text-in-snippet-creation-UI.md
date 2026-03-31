---
id: TASK-30
title: Improve "current variables" helper text in snippet creation UI
status: Done
assignee: []
created_date: '2026-03-30 21:31'
updated_date: '2026-03-31 02:30'
labels: []
milestone: none
dependencies: []
priority: low
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update the helper text shown during snippet creation that lists current variables. Improve clarity on how to reference variables in replacements using {{var}} syntax and format the message across multiple lines for readability. Include examples like {{a}} and {{b}} and ensure it appears at the correct point in the flow.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Helper text clearly communicates how to reference variables using {{var}} syntax
- [x] #2 Text is split across multiple lines for readability
- [x] #3 Example variables such as {{a}} and {{b}} are included
- [x] #4 Renders correctly in CLI without formatting issues
- [x] #5 Appears when variables are relevant in the flow
- [x] #6 No regressions in surrounding UI formatting
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated `show_summary` in `var_builder.rb` to use a multiline `UI.info` message: "Reference your variables in the replacement using {{var}} syntax:\n{{name1}}, {{name2}}". This explains the syntax on line 1 and shows the actual variable names on line 2. Three new specs added to `var_builder_spec.rb` covering {{var}} syntax explanation, actual variable names in braces, and multiline format. All 184 tests pass.
<!-- SECTION:FINAL_SUMMARY:END -->
