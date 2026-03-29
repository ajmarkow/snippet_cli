---
id: TASK-6
title: >-
  snippet new: implement optional match flags (--label, --word,
  --propagate-case)
status: To Do
assignee: []
created_date: '2026-03-27 20:16'
labels:
  - feature
  - snippet-new
  - match-flags
dependencies: []
references:
  - docs/plan-rev1.md
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Implement optional match-level flags for the `snippet new` command:

- `--label STRING` — overrides the search label shown in Espanso's search UI; emits `search_terms:` or `label:` per schema
- `--word` — boolean flag; enables word-boundary trigger mode; emits `word: true`
- `--propagate-case` — boolean flag; enables case propagation; emits `propagate_case: true`

All three are optional and may be combined freely with any trigger/replacement combination.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 --label "My Label" emits the correct label key in output YAML
- [ ] #2 --word emits `word: true` in output YAML
- [ ] #3 --propagate-case emits `propagate_case: true` in output YAML
- [ ] #4 Omitting all three flags produces valid output with no extra keys
- [ ] #5 All three flags can be combined in a single invocation
<!-- AC:END -->
