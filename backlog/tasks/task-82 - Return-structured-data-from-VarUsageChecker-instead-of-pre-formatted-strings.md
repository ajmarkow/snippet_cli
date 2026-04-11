---
id: TASK-82
title: Return structured data from VarUsageChecker instead of pre-formatted strings
status: To Do
assignee: []
created_date: '2026-04-11 15:47'
labels:
  - architecture
  - refactor
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`VarUsageChecker` (`lib/snippet_cli/var_usage_checker.rb:46–57`) is a domain module that detects declared-vs-used variable mismatches, but it returns human-readable English warning strings rather than structured data. Callers pass these strings to `UI.warning()`, coupling the domain module to a specific message format. Changing warning wording, adding i18n, or reusing the checker in a non-UI context (e.g., batch validation) all require modifying the domain module.

The fix is to return structured mismatch data (e.g., `{unused: [...], undeclared: [...]}`) and move string formatting to the caller.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 VarUsageChecker returns a structured value (hash or value object) describing mismatches, not strings
- [ ] #2 All callers format the structured result into display strings at the presentation layer
- [ ] #3 VarUsageChecker specs test the structure of returned data, not string content
- [ ] #4 All existing specs pass
<!-- AC:END -->
