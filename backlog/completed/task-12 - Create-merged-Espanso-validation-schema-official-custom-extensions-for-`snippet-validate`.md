---
id: TASK-12
title: >-
  Create merged Espanso validation schema (official + custom extensions) for
  `snippet validate`
status: Done
assignee:
  - claude
created_date: '2026-03-27 20:16'
updated_date: '2026-03-31 16:44'
labels:
  - feature
  - schema
  - validation
milestone: none
dependencies:
  - TASK-9
  - TASK-10
  - TASK-7
references:
  - docs/plan-rev1.md
  - >-
    https://raw.githubusercontent.com/espanso/espanso/refs/heads/dev/schemas/match.schema.json
  - >-
    https://raw.githubusercontent.com/ajmarkow/espanso-schema-json/refs/heads/master/schemas/Espanso_Match_Schema.json
priority: high
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Build a unified validation schema that combines the official Espanso match schema with custom extensions constraints and enhanced descriptions. This schema is the single source of truth used by `snippet validate`.

Clarify how conflicts between official and custom fields are handled whether custom rules extend or override official ones and the expected schema format.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Merged schema file is committed to the repo at a well-known path
- [x] #2 All properties from the official schema are present with correct types and constraints
- [x] #3 All properties have prose descriptions (from custom schema or newly written)
- [x] #4 All properties link to relevant espanso.org docs where available
- [x] #5 Schema validates a full matchfile (matches array + global_vars + imports) not just a single match object
- [x] #6 snippet validate uses this merged schema
- [x] #7 The merged schema passes JSON Schema meta-schema validation
- [x] #8 A suite of known-valid and known-invalid YAML fixtures passes/fails as expected
- [x] #9 Official Espanso schema is fully incorporated with no loss of coverage
- [x] #10 Custom fields and constraints are included and validated
- [x] #11 Schema supports all fields used by the CLI including extensions
- [x] #12 Conflicts between official and custom definitions are explicitly resolved
- [x] #13 Schema is consumable by `snippet validate` end-to-end
- [x] #14 Invalid inputs fail validation according to merged rules
- [x] #15 Schema structure is minimally documented for maintainability
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

### Conflict resolutions
- Trigger requirement: custom wins (require exactly one of trigger/triggers/regex)
- Replacement types: official wins (add html + markdown)
- Var validation: official wins (oneOf per-type, strict, correct)
- Descriptions: custom wins (rich prose with doc links)
- replace null: official wins (["string", "null"])
- locale/tz enums: official wins (full enum arrays)

### Steps
1. Write spec: `spec/file_validator_spec.rb` + new fixture files (TDD)
2. Write merged schema: `vendor/espanso-schema-json/schemas/Espanso_Merged_Matchfile_Schema.json`
3. Update `FileValidator#SCHEMA_PATH` to point to merged schema
4. Run tests to confirm green

### Schema path
`vendor/espanso-schema-json/schemas/Espanso_Merged_Matchfile_Schema.json`

### Schema structure
- Top-level: required [matches], additionalProperties: false
- Properties: $schema, matches, global_vars, imports, extra_includes, extra_excludes, anchors
- definitions: match, var (oneOf per type), anchor, form_field_definition, form_multiline_field, form_choice_or_list_field
<!-- SECTION:PLAN:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
## Implementation Summary

### Files changed
- **Created**: `vendor/espanso-schema-json/schemas/Espanso_Merged_Matchfile_Schema.json` (committed to submodule at `8069665`)
- **Updated**: `lib/snippet_cli/file_validator.rb` — `SCHEMA_PATH` now points to merged schema
- **Created**: `spec/file_validator_spec.rb` — 27 examples covering valid/invalid fixtures, trigger requirement, replacement requirement, all var types, error message format
- **Created**: 5 fixture files in `spec/fixtures/` — `valid_matchfile_full.yml`, `invalid_missing_trigger.yml`, `invalid_missing_replacement.yml`, `invalid_bad_var_type.yml`, `invalid_unknown_top_level_key.yml`

### Conflict resolutions (as planned)
- Trigger requirement: custom wins — exactly one of trigger/triggers/regex required
- Replacement types: official wins — html and markdown added as valid replacements
- Var validation: official wins — per-type oneOf branches replace fragile allOf + if/then
- Descriptions/doc links: custom wins — all properties have prose with espanso.org links
- `replace: null`: official wins — null is a valid replace value
- `locale`/`tz` enums: official wins — full BCP47 (~300 values) and IANA (~600 values) enums
- Shell enum: official wins — includes nu, pwsh, wsl2, zsh
- `inject_vars`: official wins — added to all applicable var types
- `match` var type: official wins — added as a new var type branch

### Test results
278 examples, 0 failures (full suite)
<!-- SECTION:FINAL_SUMMARY:END -->
