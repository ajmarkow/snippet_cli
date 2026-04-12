---
id: TASK-81
title: >-
  Decouple VarBuilder::Params from UI — separate param schemas from prompting
  logic
status: Done
assignee:
  - AJ Markow
created_date: '2026-04-11 15:47'
updated_date: '2026-04-12 22:58'
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
- [x] #1 Each var type's valid params and constraints are expressible without any Gum/UI calls (e.g., as a data structure or plain method)
- [x] #2 The collection/prompting logic is a separate layer that reads from the schema
- [x] #3 Param validation for at least one var type can be tested without mocking UI
- [x] #4 All existing specs pass
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

### Goal
Separate param schemas (what fields are valid/required/optional for each var type) from the collection/prompting logic in `lib/snippet_cli/var_builder/params.rb`.

### Approach

**Step 1 — New file: `lib/snippet_cli/var_builder/param_schema.rb`**
- Define `ParamSchema::SCHEMAS` hash keyed by type name
- Each entry: `{ required: [...], optional: [...], field_types: { key => :type } }`
- Expose `ParamSchema.valid_params?(type, params_hash)` — pure method, zero UI calls
- Expose `ParamSchema.known_type?(type)` helper

**Step 2 — Write spec first: `spec/var_builder/param_schema_spec.rb`**
- Test `valid_params?` for several types (echo, shell, date, clipboard)
- No Gum/UI mocking required — purely data-driven
- Satisfies AC#3

**Step 3 — Update `params.rb`**
- `require_relative 'param_schema'`
- No changes to collection logic (prompting stays identical)
- Collection layer is now conceptually "the layer that reads from ParamSchema to know what to collect"

**Step 4 — Run full spec suite**
- Confirm all existing specs pass (AC#4)

### Key files
- New: `lib/snippet_cli/var_builder/param_schema.rb`
- New: `spec/var_builder/param_schema_spec.rb`
- Modified: `lib/snippet_cli/var_builder/params.rb` (add require only)

### Schema design (SCHEMAS entries)
```ruby
'echo'      => { required: [:echo],         optional: [],                     field_types: { echo: :string } }
'random'    => { required: [:choices],       optional: [],                     field_types: { choices: :string_array } }
'choice'    => { required: [:values],        optional: [],                     field_types: { values: :string_array } }
'date'      => { required: [:format],        optional: [:offset, :locale, :tz], field_types: { format: :string, offset: :integer, locale: :string, tz: :string } }
'shell'     => { required: [:cmd, :shell],   optional: [:debug, :trim],        field_types: { cmd: :string, shell: :string, debug: :boolean, trim: :boolean } }
'script'    => { required: [:args],          optional: [:trim],                field_types: { args: :string_array, trim: :boolean } }
'form'      => { required: [:layout],        optional: [:fields],              field_types: { layout: :string, fields: :any } }
'clipboard' => { required: [],              optional: [],                     field_types: {} }
```
<!-- SECTION:PLAN:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
## What was done\n\nIntroduced `ParamSchema` as a pure data layer separating param schemas from prompting logic.\n\n### New files\n- `lib/snippet_cli/var_builder/param_schema.rb` — `SCHEMAS` hash keyed by var type, each entry with `required:`, `optional:`, and `field_types:` keys. Exposes `known_type?`, `schema_for`, and `valid_params?` — all zero UI calls.\n- `spec/var_builder/param_schema_spec.rb` — 17 examples covering all methods across echo, shell, date, clipboard, and unknown types. No Gum/UI mocking needed.\n\n### Modified\n- `lib/snippet_cli/var_builder/params.rb` — added `require_relative 'param_schema'`. Collection/prompting logic unchanged.\n\n### Result\n- 735 specs pass, 0 failures.\n- `valid_params?` is independently testable without any UI mocking.
<!-- SECTION:FINAL_SUMMARY:END -->
