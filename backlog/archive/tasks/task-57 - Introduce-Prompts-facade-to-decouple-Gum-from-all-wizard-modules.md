---
id: TASK-57
title: Introduce Prompts facade to decouple Gum from all wizard modules
status: To Do
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:19'
labels:
  - refactor
  - architecture
dependencies: []
priority: high
ordinal: 8750
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gum is called directly in 9+ files, tightly coupling the project to the gem. Introduce a `Prompts` facade (`Prompts.choose`, `Prompts.input`, etc.) and replace all `Gum.*` calls with `Prompts.*`. This makes the UI layer swappable and easier to test.
<!-- SECTION:DESCRIPTION:END -->
