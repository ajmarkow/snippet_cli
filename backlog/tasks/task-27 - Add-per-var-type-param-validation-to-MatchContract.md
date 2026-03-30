---
id: TASK-27
title: Add per-var-type param validation to MatchContract
status: To Do
assignee: []
created_date: '2026-03-30 04:42'
updated_date: '2026-03-30 05:15'
labels:
  - validation
  - vars
  - dry-validation
dependencies:
  - TASK-17
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The vendored Espanso JSON schema already includes if/then conditionals that enforce per-var-type required params (e.g., shell requires cmd, date requires format). Review whether the existing schema coverage is sufficient, and add any missing type-specific param validations to the schema if needed. No Ruby code changes needed — validation is handled by json_schemer against the vendored schema.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 All required params collected
- [ ] #2 All required params at correct location
<!-- AC:END -->
