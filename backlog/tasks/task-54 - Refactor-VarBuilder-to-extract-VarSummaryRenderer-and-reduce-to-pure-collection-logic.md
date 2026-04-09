---
id: TASK-54
title: >-
  Refactor VarBuilder to extract VarSummaryRenderer and reduce to pure
  collection logic
status: To Do
assignee: []
created_date: '2026-04-08 21:04'
labels:
  - refactor
  - srp
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
VarBuilder mixes interactive flow orchestration, summary display formatting, TTY cursor manipulation, and platform shell detection. Extract `VarSummaryRenderer` for display/formatting logic and reduce `VarBuilder` to pure variable collection.
<!-- SECTION:DESCRIPTION:END -->
