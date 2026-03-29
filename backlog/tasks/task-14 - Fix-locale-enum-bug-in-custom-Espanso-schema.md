---
id: TASK-14
title: Fix locale enum bug in custom Espanso schema
status: To Do
assignee: []
created_date: '2026-03-28 02:15'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The `locale` field in the custom schema has its BCP47 enum defined as a single comma-joined string instead of an array of individual values. This causes every valid locale to be rejected by validators.

Fix: split the single string into a proper JSON Schema enum array of individual BCP47 locale strings (e.g. `"en-US"`, `"fr-FR"`, etc.).
<!-- SECTION:DESCRIPTION:END -->
