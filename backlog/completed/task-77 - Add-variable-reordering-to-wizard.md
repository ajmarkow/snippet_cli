---
id: TASK-77
title: Add variable reordering to wizard
status: Done
assignee: []
created_date: '2026-04-11 14:35'
updated_date: '2026-04-13 16:07'
labels:
  - feature
  - ux
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Espanso evaluates vars in the order they appear in the YAML. When a shell or script var references another var's output, the referenced var must appear first. The wizard currently collects vars in the order the user adds them, with no way to reorder after the fact.

Provide a way for the user to reorder variables after collection (or during the add-another loop) so evaluation order can be corrected without starting over. `depends_on` is not the right mechanism here — it is a per-var field that Espanso uses internally; reordering the vars array is the correct approach.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 User can reorder collected vars before the snippet is built
- [x] #2 Reordering does not require re-entering any var's name/type/params
- [x] #3 The vars array in the output YAML reflects the user-chosen order
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added `reorder_vars!` private class method to `VarBuilder`. After the variable collection loop ends, if 2+ vars were collected, the user is asked via `gum.confirm` whether they want to reorder. If yes, a loop presents a numbered `gum.choose` list of vars plus a "Done" sentinel. The user picks a var to move, then picks a target position from a second `gum.choose` showing the remaining slots. The vars array is mutated in-place with `delete_at`/`insert`. `VarSummaryRenderer` requires no changes — it already respects array order via `flat_map`. 758/758 specs pass.
<!-- SECTION:FINAL_SUMMARY:END -->
