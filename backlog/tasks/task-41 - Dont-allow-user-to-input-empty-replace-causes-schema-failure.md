---
id: TASK-41
title: Don't allow user to input empty replace (causes schema failure)
status: To Do
assignee: []
created_date: '2026-04-04 16:08'
updated_date: '2026-04-04 16:09'
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
- [ ] #1 If the replace/replaceWith input is empty or whitespace-only, the UI/API rejects it with a clear validation message and does not attempt schema generation/validation.
- [ ] #2 Schema generation/validation no longer fails when the user submits an empty replace value; the system handles this path gracefully.
- [ ] #3 Validation is covered by automated tests (unit/integration as appropriate) for empty string and whitespace-only inputs.
- [ ] #4 Update any relevant documentation/help text to indicate replace values cannot be empty (if user-facing).
<!-- AC:END -->
