---
id: TASK-73
title: Implement clipboard var type in VarBuilder
status: Done
assignee: []
created_date: '2026-04-11 02:19'
updated_date: '2026-04-11 02:31'
labels:
  - feature
  - schema
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The schema defines `clipboard` as a valid var type (alongside echo, choice, date, form, global, random, script, shell), but it is absent from `VAR_TYPES` in `var_builder.rb` and has no params collector in `var_builder/params.rb`.

The clipboard extension inserts the current clipboard contents into a snippet. It takes no required params — only the optional `trim` and `debug` booleans.

## What to do
- Add `"clipboard"` to `VAR_TYPES` in `lib/snippet_cli/var_builder.rb`
- Add a `clipboard` collector in `Params::COLLECTORS` (or the `case` block) that offers `trim` and `debug` via `debug_trim`
- Add specs covering the new type
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 clipboard appears as a selectable var type in the interactive wizard
- [x] #2 collector offers trim and debug options
- [x] #3 generated YAML passes schema validation
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added `clipboard` as a supported var type.\n\n- Added `\"clipboard\"` to `VAR_TYPES` in `var_builder.rb`\n- Added `clipboard` private method in `Params` that delegates to `debug_trim`, offering optional `debug` and `trim` prompts\n- Added `when 'clipboard'` branch in `Params.collect`\n- Added 5 specs covering: empty params, debug: true, trim: true, and each omitted when false\n- Full suite passes: 695 examples, 0 failures
<!-- SECTION:FINAL_SUMMARY:END -->
