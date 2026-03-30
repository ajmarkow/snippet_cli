---
id: TASK-15
title: Add date locale validation
status: To Do
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-30 05:32'
labels:
  - validation
  - schema
dependencies: []
references:
  - 'https://github.com/espanso/espanso/pull/2526'
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add validation for date locale values in Espanso match entries. Ensure locale strings are valid and conform to expected formats.

Context: Espanso PR https://github.com/espanso/espanso/pull/2526 (adds `tz` to the date extension) documents existing `locale` behavior: if `locale` is provided it’s used; otherwise Espanso uses the system locale, and if system locale detection fails it defaults to `en-US`. If an invalid/unknown locale string is provided, Espanso falls back to `en-US` rather than erroring. Locale validation should reflect this behavior (decide whether to warn vs hard-fail) and the current supported-locale list used by Espanso’s locale mapping / schema enum.
<!-- SECTION:DESCRIPTION:END -->
