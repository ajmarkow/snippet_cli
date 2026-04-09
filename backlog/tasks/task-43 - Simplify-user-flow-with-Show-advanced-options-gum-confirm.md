---
id: TASK-43
title: Simplify user flow with 'Show advanced options' gum confirm
status: To Do
assignee: []
created_date: '2026-04-06 03:01'
updated_date: '2026-04-09 20:46'
labels:
  - feature
  - ux
dependencies: []
priority: medium
ordinal: 2000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a `gum confirm "Show advanced options?"` prompt after the initial input phase in the `snippet new` flow. If the user declines, skip advanced fields like `comment`, `label`, `depends_on`, and debug/rarely-used options. Accepting shows the full current flow. This reduces noise in the primary wizard path while keeping full functionality accessible.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A gum confirm prompt asks whether to show advanced options after initial input is collected
- [ ] #2 Declining skips: comment, label, depends_on, and other advanced/debug fields
- [ ] #3 Accepting shows the full current flow unchanged
- [ ] #4 The --simple flag continues to work and bypasses this prompt entirely
- [ ] #5 Specs cover both paths (advanced shown vs hidden)
<!-- AC:END -->
