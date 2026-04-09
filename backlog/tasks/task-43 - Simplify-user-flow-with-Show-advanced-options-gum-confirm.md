---
id: TASK-43
title: Simplify user flow with 'Show advanced options' gum confirm
status: To Do
assignee: []
created_date: '2026-04-06 03:01'
updated_date: '2026-04-09 20:19'
labels:
  - feature
  - ux
dependencies: []
priority: medium
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a `gum confirm "Show advanced options?"` prompt early in the `snippet new` flow. If the user declines, skip advanced fields like `depends_on`, `comment`, `label`, and other rarely-used options. This streamlines the default experience while keeping full functionality accessible.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A gum confirm prompt asks whether to show advanced options
- [ ] #2 Declining skips: depends_on, comment, label, and other advanced fields
- [ ] #3 Accepting shows the full current flow
- [ ] #4 The --simple flag continues to work and bypasses this prompt entirely
- [ ] #5 Specs cover both paths (advanced shown vs hidden)
<!-- AC:END -->
