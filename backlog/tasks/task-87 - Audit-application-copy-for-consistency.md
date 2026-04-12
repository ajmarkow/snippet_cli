---
id: TASK-87
title: Audit application copy for consistency
status: To Do
assignee: []
created_date: '2026-04-11 21:21'
labels:
  - ui
  - copy
  - polish
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Review all user-facing text (prompts, descriptions, success/error messages, command descs, option descs) for consistent voice and style. Target: short, declarative phrasing with no trailing punctuation on prompts, imperative headers, and no mixed formal/informal tone.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 All Gum prompt strings use short declarative phrasing
- [ ] #2 Command desc strings are imperative and concise
- [ ] #3 Option desc strings follow the same pattern
- [ ] #4 No prompt ends with '?' that also has a period elsewhere in the same flow
- [ ] #5 Error and success messages are consistent in length and tone
<!-- AC:END -->
