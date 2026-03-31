---
id: TASK-22
title: Refine form-based snippet creation flow for clarity and usability
status: To Do
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-30 21:59'
labels:
  - ux
  - wizard
milestone: none
dependencies: []
priority: medium
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Improve the UX of the form wizard used in `snippet new --form` to make the process more intuitive efficient and less error-prone. Focus on step clarity reducing friction improving layout and readability and ensuring alignment between user input and generated output. Identify current pain points and address them via flow or prompt improvements.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each step in the form flow has a clear and specific prompt
- [ ] #2 User can complete the flow without confusion or backtracking
- [ ] #3 Input fields map cleanly to generated form output (`form:` syntax)
- [ ] #4 Preview or output is accurate and easy to understand
- [ ] #5 No redundant or unnecessary steps in the flow
- [ ] #6 Flow handles multiple variables cleanly and scales beyond a few inputs
- [ ] #7 At least one end-to-end example from input to generated snippet
<!-- AC:END -->
