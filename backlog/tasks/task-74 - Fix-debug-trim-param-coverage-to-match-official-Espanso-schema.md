---
id: TASK-74
title: Fix debug/trim param coverage to match official Espanso schema
status: Done
assignee: []
created_date: '2026-04-11 02:25'
updated_date: '2026-04-11 03:14'
labels:
  - feature
  - schema
  - bug
dependencies: []
references:
  - >-
    https://raw.githubusercontent.com/espanso/espanso/dev/schemas/match.schema.json
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The official Espanso match schema (https://raw.githubusercontent.com/espanso/espanso/dev/schemas/match.schema.json) shows that `debug` and `trim` are only supported for specific extension types — our custom schema and the app diverge from this in several ways.

## Official support (from Espanso source schema)

| Type      | debug | trim |
|-----------|-------|------|
| shell     | ✓     | ✓    |
| script    | ✗     | ✓    |
| date      | ✗     | ✗    |
| echo      | ✗     | ✗    |
| clipboard | ✗     | ✗    |
| choice    | ✗     | ✗    |
| random    | ✗     | ✗    |
| form var  | ✗     | ✗    |

## Problems to fix

### 1. Custom schema incorrectly grants debug to unsupported types
Our schema's type-specific `allOf` blocks add `debug` to `echo`, `random`, `choice`, `date`, and `form` var params. These should be removed.

### 2. script type-specific block is missing trim
The `script` allOf block only lists `args` with `additionalProperties: false`, so adding `trim` (which Espanso does support) would currently fail schema validation. Add `trim` to the script block.

### 3. date is missing the tz param
The official schema includes a `tz` (timezone) param for `date` that is absent from our schema and uncollected by the app. Add it to the schema and prompt for it in `Params#date` (alongside offset and locale).

### 4. clipboard type-specific block is missing
`clipboard` has no type-specific allOf block. Since the official schema defines no params for it, add a block with `additionalProperties: false` and no required properties, but allowing `trim` and `debug` if Espanso actually supports them (verify first).

## What to do
- Update `vendor/espanso-schema-json/schemas/Espanso_Match_Schema.json` to reflect official param support per type
- Remove `debug` from echo, random, choice, date, form var type-specific blocks
- Add `trim` to the script type-specific block
- Add `tz` to the date type-specific block and prompt for it in `Params#date`
- Add a clipboard type-specific block
- Update app param collectors to match: remove any debug/trim prompts for types that don't support them
- Add/update specs accordingly
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Schema type-specific blocks for echo, random, choice, date, and form var no longer include debug
- [x] #2 Script type-specific block includes trim
- [x] #3 Date type-specific block includes tz; app prompts for it alongside offset and locale
- [x] #4 Clipboard has a type-specific block consistent with official support
- [x] #5 No param offered by the app for any type causes an additionalProperties schema validation failure
- [x] #6 All specs pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Aligned debug/trim param coverage with the official Espanso schema.\n\n**Schema changes** (`Espanso_Match_Schema.json`):\n- Removed `debug` from echo, random, choice, form var, and date type-specific allOf blocks\n- Removed `trim` from echo type-specific block\n- Added `trim` to script and shell type-specific blocks\n- Added `tz` to date type-specific block (and generic params reference section)\n- Added clipboard type-specific block with `additionalProperties: false` and no properties\n\n**App changes** (`var_builder/params.rb`):\n- `script`: replaced `debug_trim` call with trim-only prompt; no longer offers debug\n- `clipboard`: returns `{}` directly with no prompts\n- `date`: added `Add a timezone?` prompt storing `tz` in params\n\n**Spec changes** (`var_builder_spec.rb`):\n- script: removed debug test, added trim test, added \"does not prompt for debug\" assertion\n- clipboard: replaced debug/trim context blocks with \"returns empty params\" + \"does not prompt for debug/trim\"\n- date: added timezone prompt tests and tz storage test; added timezone stub to all date-using contexts\n\n697 examples, 0 failures.
<!-- SECTION:FINAL_SUMMARY:END -->
