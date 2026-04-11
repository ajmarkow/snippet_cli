---
id: TASK-77
title: Add variable reordering to wizard
status: To Do
assignee: []
created_date: '2026-04-11 14:35'
labels:
  - feature
  - ux
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Espanso evaluates vars in the order they appear in the YAML. When a shell or script var references another var's output, the referenced var must appear first. The wizard currently collects vars in the order the user adds them, with no way to reorder after the fact.

Provide a way for the user to reorder variables after collection (or during the add-another loop) so evaluation order can be corrected without starting over. `depends_on` is not the right mechanism here — it is a per-var field that Espanso uses internally; reordering the vars array is the correct approach.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 User can reorder collected vars before the snippet is built
- [ ] #2 Reordering does not require re-entering any var's name/type/params
- [ ] #3 The vars array in the output YAML reflects the user-chosen order
<!-- AC:END -->
