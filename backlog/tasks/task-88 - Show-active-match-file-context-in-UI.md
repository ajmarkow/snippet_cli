---
id: TASK-88
title: Show active match file context in UI
status: To Do
assignee: []
created_date: '2026-04-11 21:30'
labels:
  - ui
  - ux
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Users have no visibility into which match file is being targeted during a command. Add a UI hint that communicates the file resolution behaviour before the wizard or output begins:

- Single match file found → auto-selected, show filename as a note (e.g. "Using base.yml")
- Multiple match files found → interactive picker, no extra hint needed (picker is self-explanatory)
- `--file` flag provided → show filename as a note to confirm the explicit path was accepted

Applies to any command that targets a match file: `new`, `vars --save`, `check`, `conflict`.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Single match file: a UI note showing the filename is printed before wizard/output begins
- [ ] #2 Multiple match files: no extra hint (picker is sufficient)
- [ ] #3 --file provided: a UI note confirms the explicit path
- [ ] #4 Note uses existing UI.note or equivalent — no new styling introduced
- [ ] #5 Behaviour is consistent across new, vars --save, check, and conflict
<!-- AC:END -->
