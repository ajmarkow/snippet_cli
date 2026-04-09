---
id: TASK-52
title: Extract TransientValidatedPrompt helper for loop-until-valid prompt pattern
status: To Do
assignee: []
created_date: '2026-04-08 21:04'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The "loop until valid with transient feedback" prompt pattern is written 3 times: `replacement_collector.rb:35-53`, `trigger_resolver.rb:93-101`, `var_builder/name_collector.rb:23-34`. Extract a reusable `TransientValidatedPrompt` helper.
<!-- SECTION:DESCRIPTION:END -->
