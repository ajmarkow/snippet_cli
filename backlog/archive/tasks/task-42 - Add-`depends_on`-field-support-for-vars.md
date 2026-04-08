---
id: TASK-42
title: Add `depends_on` field support for vars
status: To Do
assignee: []
created_date: '2026-04-06 03:01'
updated_date: '2026-04-06 03:03'
labels:
  - feature
  - vars
dependencies: []
references:
  - vendor/espanso-schema-json/schemas/Espanso_Match_Schema.json
  - vendor/espanso-schema-json/schemas/Espanso_Merged_Matchfile_Schema.json
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The Espanso schema supports a `depends_on` field for variables, but our CLI does not implement it yet. Add support for `depends_on` in the var builders and match contract so users can specify variable dependencies when creating snippets.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 VarBuilder supports `depends_on` field
- [ ] #2 Match contract validates `depends_on` against the Espanso JSON schema
- [ ] #3 Generated YAML output includes `depends_on` when specified
- [ ] #4 Specs cover `depends_on` for all relevant var types
- [ ] #5 Ensure depends_on variable reference of dependency is valid
<!-- AC:END -->
