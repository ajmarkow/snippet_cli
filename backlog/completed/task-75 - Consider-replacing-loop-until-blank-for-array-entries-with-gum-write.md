---
id: TASK-75
title: Consider replacing loop-until-blank for array entries with gum write
status: Done
assignee: []
created_date: '2026-04-11 03:34'
updated_date: '2026-04-11 14:13'
labels:
  - ux
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Several places in the wizard collect arrays by looping until the user submits a blank input (e.g. choice values, random choices, search_terms). An alternative is to use `Gum.write` with a UI hint like "one entry per line", which lets the user enter all values at once and finish with a keypress.\n\nEvaluate the tradeoffs and decide whether to migrate some or all loop-until-blank collectors to a write-based approach.
<!-- SECTION:DESCRIPTION:END -->
