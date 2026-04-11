---
id: TASK-81
title: >-
  Decouple VarBuilder::Params from UI — separate param schemas from prompting
  logic
status: To Do
assignee: []
created_date: '2026-04-11 15:47'
labels:
  - architecture
  - refactor
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
In `lib/snippet_cli/var_builder/params.rb`, each `case` branch in `Params.collect` interleaves param validation/parsing with direct Gum prompt calls. There is no separation between "what params are valid for this var type" and "how do we ask the user for them." Adding a new var type requires knowing the full Gum API; testing param validation logic requires mocking UI calls.

The goal is to separate param schemas (what fields are valid, what defaults exist, what constraints apply) from the collection/prompting logic, so schemas are independently testable.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each var type's valid params and constraints are expressible without any Gum/UI calls (e.g., as a data structure or plain method)
- [ ] #2 The collection/prompting logic is a separate layer that reads from the schema
- [ ] #3 Param validation for at least one var type can be tested without mocking UI
- [ ] #4 All existing specs pass
<!-- AC:END -->
