---
id: TASK-59
title: Replace trigger resolver 3-tuple return with TriggerResolution struct
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 19:53'
labels:
  - refactor
  - architecture
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`trigger_resolver.rb:36` returns an unnamed 3-tuple `[list, is_regex, false]` — callers must know positional meaning. Replace with a `TriggerResolution` Struct with named fields (`list:`, `is_regex:`, `single_trigger:`).
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Defined `TriggerResolution = Struct.new(:list, :is_regex, :single_trigger)` inside `TriggerResolver`. Updated both return sites (`resolve_triggers_from_flags` and `resolve_triggers_interactively`) to return the struct instead of a 3-tuple. Updated the sole caller in `commands/new.rb` to use `resolution.list`, `resolution.is_regex`, `resolution.single_trigger`. Added 10 new RSpec examples covering struct existence, named field access, and both resolution paths — all pass (21/21).
<!-- SECTION:FINAL_SUMMARY:END -->
