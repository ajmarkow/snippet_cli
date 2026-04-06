---
id: TASK-44
title: Skip file selection via gum.filter if only base.yml is found
status: Done
assignee: []
created_date: '2026-04-06 04:03'
updated_date: '2026-04-06 04:35'
labels: []
dependencies: []
---

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Extracted `pick_match_file` into `WizardHelpers` so both `new` and `vars` commands share one implementation. When only one Espanso match file exists, it is auto-selected without prompting via `Gum.filter`. Commit: ae95cdb.
<!-- SECTION:FINAL_SUMMARY:END -->
