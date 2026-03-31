---
id: TASK-27
title: Add per-variable-type parameter validation in MatchContract
status: To Do
assignee: []
created_date: '2026-03-30 04:42'
updated_date: '2026-03-30 22:02'
labels:
  - validation
  - vars
  - dry-validation
milestone: none
dependencies:
  - TASK-12
  - TASK-18
priority: high
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement validation logic in MatchContract that enforces allowed parameters based on each variable type. Each var type (e.g. date shell etc.) should only accept valid parameters reject unsupported or incorrectly typed parameters and align with Espanso behavior and the merged schema. This acts as the generalized validation system that specific fixes like echo must comply with.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 All required params collected
- [ ] #2 All required params at correct location
- [ ] #3 Each variable type has a defined set of allowed parameters
- [ ] #4 Invalid parameters for a given var type are rejected with clear errors
- [ ] #5 Missing required parameters (if any) are detected
- [ ] #6 Parameter types (string bool etc.) are validated correctly
- [ ] #7 Behavior aligns with merged schema used by `snippet validate`
- [ ] #8 At least one valid and one invalid example per var type or representative subset
- [ ] #9 No regressions for existing valid variable configurations
<!-- AC:END -->
