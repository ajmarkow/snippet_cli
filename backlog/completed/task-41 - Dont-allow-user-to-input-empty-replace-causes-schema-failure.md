---
id: TASK-41
title: Don't allow user to input empty replace (causes schema failure)
status: Done
assignee: []
created_date: '2026-04-04 16:08'
updated_date: '2026-04-04 21:10'
labels:
  - bug
  - validation
  - schema
milestone: .
dependencies: []
priority: medium
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Prevent schema failures caused by allowing users to submit an empty “replace” value. Add input validation (client-side and/or server-side as applicable) so empty or whitespace-only replace values are rejected early with a clear error, and ensure schema generation/validation handles this case safely.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 If the replace/replaceWith input is empty or whitespace-only, the UI/API rejects it with a clear validation message and does not attempt schema generation/validation.
- [x] #2 Schema generation/validation no longer fails when the user submits an empty replace value; the system handles this path gracefully.
- [x] #3 Validation is covered by automated tests (unit/integration as appropriate) for empty string and whitespace-only inputs.
- [x] #4 Update any relevant documentation/help text to indicate replace values cannot be empty (if user-facing).
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added empty-replacement validation to the wizard UI via `UI.transient_warning` in a new `ReplacementCollector` module extracted from `Commands::New`. Both plaintext (`collect_replace`) and alternative types (`collect_alt_value` — image_path, html, markdown) now reject empty/whitespace-only input with a transient warning that clears on valid re-entry. Covered by 10 new specs across 4 contexts. Version bumped to 0.3.1, merged to master.
<!-- SECTION:FINAL_SUMMARY:END -->
