---
id: TASK-27
title: Add per-variable-type parameter validation in MatchContract
status: Done
assignee: []
created_date: '2026-03-30 04:42'
updated_date: '2026-03-31 03:50'
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
- [x] #1 All required params collected
- [x] #2 All required params at correct location
- [x] #3 Each variable type has a defined set of allowed parameters
- [x] #4 Invalid parameters for a given var type are rejected with clear errors
- [x] #5 Missing required parameters (if any) are detected
- [x] #6 Parameter types (string bool etc.) are validated correctly
- [x] #7 Behavior aligns with merged schema used by `snippet validate`
- [x] #8 At least one valid and one invalid example per var type or representative subset
- [x] #9 No regressions for existing valid variable configurations
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added per-type parameter validation tests to `spec/match_contract_spec.rb` under a new `per-type parameter validation (TASK-27)` context.

The schema already enforces per-type params via `if/then/additionalProperties: false` for all var types (echo, date, shell, script, random, choice, form). Tests now explicitly verify for each type:
- Missing required param fails (e.g., missing `echo`, `format`, `cmd`, `args`, `choices`, `values`, `layout`)
- Wrong param type fails (e.g., non-string `echo`, non-integer `offset`, non-array `args`, non-string `format`)
- Unknown/extra params fail (additionalProperties enforcement)

21 new examples added, all passing. Full suite: 246 examples, 0 failures. No schema or implementation changes were required — the schema was already correct; test coverage was the gap.
<!-- SECTION:FINAL_SUMMARY:END -->
