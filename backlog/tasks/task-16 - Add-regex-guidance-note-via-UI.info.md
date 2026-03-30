---
id: TASK-16
title: Add regex guidance note via UI.info
status: To Do
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-30 05:18'
labels:
  - validation
  - schema
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Instead of validating regex trigger patterns programmatically, show an informational note in the CLI using UI.info: "Espanso uses Rust Regex Syntax, ensure this is a valid Rust regex." This guidance should appear in the relevant regex input flow before YAML output is emitted.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Regex input flow displays a UI.info note before output is emitted
- [ ] #2 The note text is: "Espanso uses Rust Regex Syntax, ensure this is a valid Rust regex."
- [ ] #3 No programmatic regex validation is added as part of this task
<!-- AC:END -->
