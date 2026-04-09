---
id: TASK-53
title: >-
  Split ReplacementCollector into ReplacementTextCollector and
  ReplacementValidator
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
ReplacementCollector violates SRP — it handles prompt strategy, alt-type validation, variable usage warnings, and transient error clearing all in one module. Split into `ReplacementTextCollector` (prompt strategies) and `ReplacementValidator` (alt-type and var compatibility checks), with orchestration moved to the `New` command.
<!-- SECTION:DESCRIPTION:END -->
