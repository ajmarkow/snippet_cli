---
id: TASK-34
title: 'refine: UI review — colors, interaction polish, and visual streamlining'
status: To Do
assignee: []
created_date: '2026-04-01 22:23'
updated_date: '2026-04-01 22:25'
labels:
  - ux
  - polish
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Conduct a holistic review of the CLI's visual output and user interaction points. The goal is to audit every place where color, borders, and formatting are applied, identify inconsistencies or missed opportunities, and produce a more cohesive and polished experience — both functionally streamlined and visually appealing.

Areas to review:
- Color usage across `UI.info`, `UI.hint`, `UI.success`, `UI.error`, `UI.preview` (lib/snippet_cli/ui.rb)
- Gum prompts: headers, placeholders, filter/choose/input/write calls
- Warning and confirmation messages in the `snippet new` wizard flow
- YAML preview output (`UI.format_code`)
- Consistency between success/error states and neutral info messages
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 All Gum/UI call sites have been audited and documented with current color/style values
- [ ] #2 A decision is made on a coherent color palette and style guide for the CLI
- [ ] #3 Colors and borders are updated to reflect the agreed palette
- [ ] #4 Interaction points (prompts, confirmations, warnings) feel consistent and intentional
- [ ] #5 No regressions in existing specs
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Pre-audit observations

### Colors are inconsistent in meaning
- `info` has no color — plain white border. Currently used for *warnings* too (`"Warning: #{w}"` in the new command), which is misleading. Warnings deserve a distinct color (yellow/orange).
- `hint` uses 220 (yellow) but is barely used anywhere in the codebase.
- `success` (46, green) and `error` (196, red) are well-chosen and consistent.
- `preview` uses `--border=double` for visual weight but no color — blends with `info` at a glance.

### `info` is overloaded
Used for both neutral messages ("Snippet YAML below.") and warnings ("Warning: unused var"). These should be split into separate methods — `warning` (yellow, like `hint`) vs `info` (neutral). Current `hint` may be a candidate to repurpose or rename.

### Gum prompt inconsistencies
- Header capitalization is inconsistent: some are written properly (`'Replacement type'`, `'Variable type'`), others use `.capitalize` which only upcases the first character (`'Markdown'`, `'Html'`).
- `placeholder:` quality is mixed — some are descriptive (`'date format (e.g. %Y-%m-%d)'`), others are vague (`'Type expansion text...'`).

### No foreground color on text
Only borders are colored. Adding `--foreground` to warning/error output would make the message text itself stand out, not just the border.

## Suggested quick wins
1. Split `info` → `info` (neutral) + `warning` (yellow), update all call sites
2. Add `--foreground` color to `error` and `warning` text, not just borders
3. Standardize `Gum.write`/`Gum.filter` header capitalization across all call sites
<!-- SECTION:NOTES:END -->
