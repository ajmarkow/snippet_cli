---
id: TASK-12
title: >-
  Produce merged Espanso schema (official coverage + custom descriptions) for
  snippet validate
status: To Do
assignee: []
created_date: '2026-03-27 20:16'
labels:
  - feature
  - schema
  - validation
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
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a merged schema that combines the best of both evaluated schemas:
- **Property coverage, types, and constraints** from the official Espanso schema (authoritative, maintained by Espanso team)
- **Prose descriptions and espanso.org doc links** from the custom schema

This merged schema should validate a full `base.yaml`-style matchfile (top-level `matches` array + optional `global_vars` + `imports`). It is intended as the permanent schema backing `snippet validate`.

Pre-requisites: the custom schema bug fixes (TASK-9) and missing properties (TASK-10) should be completed first, as those outputs feed into this merge.

The merged schema should live in the repo (e.g. `schemas/espanso_match.schema.json`) and be bundled with the gem.
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
<!-- AC:END -->
