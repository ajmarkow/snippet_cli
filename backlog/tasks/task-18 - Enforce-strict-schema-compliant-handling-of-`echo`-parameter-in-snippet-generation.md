---
id: TASK-18
title: >-
  Enforce strict schema-compliant handling of `echo` parameter in snippet
  generation
status: To Do
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-30 22:02'
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
- [ ] #1 CLI correctly collects echo input from user where applicable
- [ ] #2 Internal representation of echo matches schema expectations
- [ ] #3 Output YAML includes echo in the correct location and format
- [ ] #4 Generated snippets with echo pass schema validation via `snippet validate`
- [ ] #5 Invalid or malformed echo input is prevented or corrected before output
- [ ] #6 At least one end-to-end test covers input to YAML to validation
- [ ] #7 No regressions for snippets that do not use echo
<!-- AC:END -->
