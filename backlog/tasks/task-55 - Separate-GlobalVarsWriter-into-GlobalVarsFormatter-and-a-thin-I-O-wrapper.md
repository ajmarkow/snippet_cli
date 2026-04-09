---
id: TASK-55
title: Separate GlobalVarsWriter into GlobalVarsFormatter and a thin I/O wrapper
status: To Do
assignee: []
created_date: '2026-04-08 21:04'
labels:
  - refactor
  - srp
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
GlobalVarsWriter mixes content formatting logic (`build_content` and private helpers) with file I/O (`append`, `read_names`). Separate into `GlobalVarsFormatter` (pure, testable logic) and a thin `GlobalVarsWriter` I/O wrapper.
<!-- SECTION:DESCRIPTION:END -->
