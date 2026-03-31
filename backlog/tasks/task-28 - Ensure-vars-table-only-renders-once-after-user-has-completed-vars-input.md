---
id: TASK-28
title: 'Ensure vars table only renders once, after user has completed vars input'
status: Done
assignee: []
created_date: '2026-03-30 05:08'
updated_date: '2026-03-30 21:45'
labels: []
milestone: none
dependencies: []
priority: medium
ordinal: 0
---

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 show_summary method is called after completing var_builder loop, meaning it is only rendered once, instead of each time
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Prompt now contains table formatter that rewrites each loop, and one final table is written to stdout at end of var_builder loop
<!-- SECTION:NOTES:END -->
