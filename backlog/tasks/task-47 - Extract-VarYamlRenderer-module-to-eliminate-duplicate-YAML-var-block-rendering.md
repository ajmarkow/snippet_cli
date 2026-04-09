---
id: TASK-47
title: Extract VarYamlRenderer module to eliminate duplicate YAML var block rendering
status: To Do
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:19'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
YAML var block rendering is implemented twice with different scalar-quoting strategies in `snippet_builder.rb:74-87` and `commands/vars.rb:50-74`. Extract a shared `VarYamlRenderer` module with a single `render_var()` method used by both.
<!-- SECTION:DESCRIPTION:END -->
