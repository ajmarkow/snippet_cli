---
id: TASK-10
title: Fix correctness bugs in custom Espanso schema (non-locale)
status: Done
assignee: []
created_date: '2026-03-27 20:16'
updated_date: '2026-03-28 02:17'
labels:
  - bug
  - schema
dependencies: []
references:
  - docs/plan-rev1.md
  - >-
    https://raw.githubusercontent.com/ajmarkow/espanso-schema-json/refs/heads/master/schemas/Espanso_Match_Schema.json
  - >-
    https://raw.githubusercontent.com/espanso/espanso/refs/heads/dev/schemas/match.schema.json
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The custom Espanso match schema has 4 correctness bugs to fix (locale is tracked separately in TASK-14):

1. Boolean fields (`passive_only`, `multiline`, `trim_string_values`) have string defaults (`"false"`) instead of boolean defaults (`false`). Fix: change to boolean type defaults.
2. `globalvarItems` is not a valid JSON Schema keyword — the constraint is silently ignored. Fix: use the correct JSON Schema keyword.
3. `script` args are capped at `maxItems: 2` — incorrectly rejects scripts with 3+ arguments. Fix: remove or raise the cap.
4. `form_fields.type` includes `"form"` — not a valid form control type. Fix: remove `"form"` from the enum.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 passive_only, multiline, and trim_string_values accept boolean false as default without error
- [x] #2 Script vars with 3 or more arguments pass validation
- [x] #3 form_fields.type rejects 'form' as a value
- [x] #4 globalvarItems is replaced with the correct JSON Schema keyword
- [x] #5 Existing valid Espanso match configs still pass validation after fixes
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Fixed all 4 non-locale bugs in the custom schema. Boolean defaults corrected (passive_only, multiline, trim_string_values), globalvarItems replaced with valid `items` keyword and correct $ref path, maxItems: 2 cap removed from script args, and "form" removed from form_fields.type enum. Committed and pushed to espanso-schema-json master as 91ca403.
<!-- SECTION:FINAL_SUMMARY:END -->
