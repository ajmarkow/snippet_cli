---
id: TASK-20
title: >-
  Detect variable usage in snippets with optional bypass and unused variable
  warnings
status: Done
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-04-01 21:42'
labels:
  - vars
  - ux
milestone: none
dependencies: []
priority: medium
ordinal: 4000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Analyze snippet definitions to detect variables that are declared but never used and variables that are used but not declared. Provide warnings for unused variables and an option to bypass or suppress these checks (e.g. via CLI flag or config). Clarify whether this runs during snippet new validate or both and define which cases are warnings vs errors.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Declared but unused variables are detected and surfaced as warnings
- [x] #2 Used but undeclared variables are detected with defined behavior (warn or error)
- [x] #3 Users can bypass or suppress warnings via a defined mechanism
- [x] #4 Warnings are clearly formatted and actionable
- [x] #5 At least one example each for unused variable valid usage and bypassed warning
- [x] #6 Integrated into appropriate flow (snippet new validate or both)
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Implementation Plan

### Scope
- Only `snippet new` — no changes to `snippet validate`
- VarUsageChecker scans replace/html/markdown/image_path for {{name}} refs
- After collecting replacement value: if warnings exist, display them + Gum.confirm('Are you sure you want to continue?')
  - YES → proceed
  - NO → re-ask same value input only (not the type gate)
- global_vars are not checked (only per-match vars array)

### Files
1. spec/var_usage_checker_spec.rb (new) — unit tests first
2. lib/snippet_cli/var_usage_checker.rb (new)
3. spec/commands/new_spec.rb — add contexts for warning+confirm loop
4. lib/snippet_cli/commands/new.rb — loop in resolve_replacement after value collection

### VarUsageChecker interface
VarUsageChecker.match_warnings(vars, replacement_hash)
- vars: array of {name:, type:, params:} hashes (symbol or string keyed)
- replacement_hash: {replace: ...} or {html: ...} or {markdown: ...} or {image_path: ...}
- Returns array of warning strings

### snippet new loop
In resolve_replacement, after collecting the value:
  loop do
    value = collect value via Gum
    warnings = VarUsageChecker.match_warnings(vars, {type => value})
    break if warnings.empty?
    display warnings
    break if confirm!('Are you sure you want to continue?')
  end
<!-- SECTION:PLAN:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented VarUsageChecker module and integrated into `snippet new` wizard flow.

**New files:**
- `lib/snippet_cli/var_usage_checker.rb` — detects declared-but-unused and used-but-undeclared vars across replace/html/markdown/image_path fields
- `spec/var_usage_checker_spec.rb` — 14 unit tests

**Changes to `lib/snippet_cli/commands/new.rb`:**
- `resolve_replacement` split into `collect_replace_with_check` and `collect_alt_with_check` — both loop until var warnings are cleared or user confirms to proceed
- `collect_alt_value` extracts just the value prompt (not the type gate) so re-prompts skip the gate
- `var_warnings_cleared?` shows warnings via UI.info + Gum.confirm('Are you sure you want to continue?')

**Key design notes:**
- image_path + vars combination fails Espanso schema validation; test for image_path loop uses undeclared ref (vars=[]) to avoid schema rejection
- All 306 unit specs pass (integration excluded)
<!-- SECTION:FINAL_SUMMARY:END -->
