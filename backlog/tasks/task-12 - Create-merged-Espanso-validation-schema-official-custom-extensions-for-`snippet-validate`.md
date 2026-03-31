---
id: TASK-12
title: >-
  Create merged Espanso validation schema (official + custom extensions) for
  `snippet validate`
status: To Do
assignee: []
created_date: '2026-03-27 20:16'
updated_date: '2026-03-30 22:02'
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
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Build a unified validation schema that combines the official Espanso match schema with custom extensions constraints and enhanced descriptions. This schema is the single source of truth used by `snippet validate`.

Clarify how conflicts between official and custom fields are handled whether custom rules extend or override official ones and the expected schema format.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Merged schema file is committed to the repo at a well-known path
- [ ] #2 All properties from the official schema are present with correct types and constraints
- [ ] #3 All properties have prose descriptions (from custom schema or newly written)
- [ ] #4 All properties link to relevant espanso.org docs where available
- [ ] #5 Schema validates a full matchfile (matches array + global_vars + imports) not just a single match object
- [ ] #6 snippet validate uses this merged schema
- [ ] #7 The merged schema passes JSON Schema meta-schema validation
- [ ] #8 A suite of known-valid and known-invalid YAML fixtures passes/fails as expected
- [ ] #9 Official Espanso schema is fully incorporated with no loss of coverage
- [ ] #10 Custom fields and constraints are included and validated
- [ ] #11 Schema supports all fields used by the CLI including extensions
- [ ] #12 Conflicts between official and custom definitions are explicitly resolved
- [ ] #13 Schema is consumable by `snippet validate` end-to-end
- [ ] #14 Invalid inputs fail validation according to merged rules
- [ ] #15 Schema structure is minimally documented for maintainability
<!-- AC:END -->
