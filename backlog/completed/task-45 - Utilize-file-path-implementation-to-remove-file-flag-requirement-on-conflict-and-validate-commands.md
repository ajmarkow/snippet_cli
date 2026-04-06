---
id: TASK-45
title: >-
  Utilize file path implementation to remove --file flag requirement on conflict
  and validate commands
status: Done
assignee: []
created_date: '2026-04-06 04:03'
updated_date: '2026-04-06 20:00'
labels: []
dependencies: []
---

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Made `--file` optional on both `validate` and `conflict` commands. When omitted, both commands now use `EspansoConfig.match_files` via the shared `WizardHelpers#pick_match_file` helper: auto-selects when only one match file exists, prompts via `Gum.filter` when multiple exist, and errors when none are found. A `--file` path passed explicitly continues to work as before. `WizardInterrupted` is now rescued in both commands. All 468 specs pass.
<!-- SECTION:FINAL_SUMMARY:END -->
