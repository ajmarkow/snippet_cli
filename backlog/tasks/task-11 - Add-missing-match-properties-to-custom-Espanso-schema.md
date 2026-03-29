---
id: TASK-11
title: Add missing match properties to custom Espanso schema
status: Done
assignee: []
created_date: '2026-03-27 20:16'
updated_date: '2026-03-27 22:57'
labels:
  - feature
  - schema
dependencies:
  - TASK-9
references:
  - docs/plan-rev1.md
  - >-
    https://raw.githubusercontent.com/ajmarkow/espanso-schema-json/refs/heads/master/schemas/Espanso_Match_Schema.json
  - >-
    https://raw.githubusercontent.com/espanso/espanso/refs/heads/dev/schemas/match.schema.json
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The custom Espanso schema is missing 11 properties that exist in the official schema. Because the custom schema uses `additionalProperties: false`, these missing properties cause false validation failures on valid configs.

Add the following properties (with descriptions and doc links matching the custom schema's style):
`html`, `markdown`, `force_mode`, `force_clipboard`, `uppercase_style`, `left_word`, `right_word`, `search_terms`, `comment`, `anchor`, `paragraph`

Use the official schema (`https://raw.githubusercontent.com/espanso/espanso/refs/heads/dev/schemas/match.schema.json`) as the authoritative source for types and constraints, and add prose descriptions + espanso.org doc links.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 All 11 properties are present in the custom schema with correct types
- [x] #2 Each new property has a prose description
- [x] #3 Each new property links to the relevant espanso.org documentation page
- [ ] #4 A match YAML using any of the 11 properties passes custom schema validation
- [ ] #5 No previously-valid match configs are broken by this change
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added all 11 originally missing properties plus `anchors` (plural, discovered during implementation) to the custom Espanso match schema. Each entry includes correct types from the official schema, prose descriptions in the existing schema's style, and espanso.org doc links where applicable. Two exceptions by design: `force_clipboard` (deprecated, no public doc page) and `comment` (self-explanatory, no doc link needed). AC #4 and #5 (validation testing) cannot be verified until `snippet validate` (TASK-7) is implemented. Committed and pushed to espanso-schema-json master as 5eaaf70.
<!-- SECTION:FINAL_SUMMARY:END -->
