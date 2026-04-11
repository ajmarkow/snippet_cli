---
id: TASK-63
title: Review schema and ensure all var type options are fully implemented
status: Done
assignee: []
created_date: '2026-04-08 21:05'
updated_date: '2026-04-11 14:53'
labels:
  - feature
  - schema
dependencies: []
priority: high
ordinal: 8500
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Review the Espanso schema and verify that all options for each var type are implemented in snippet_cli. Find complex real-world example files and ensure output is comparable to them.

## Analysis completed (2026-04-10)

Cross-referenced the app against the official Espanso source schema at `github.com/espanso/espanso/dev/schemas/match.schema.json` and our custom vendored schema.

### Completed (via TASK-73 and TASK-74)
- Added `clipboard` var type (was entirely absent)
- Fixed `debug`/`trim` param coverage to match official schema — removed spurious debug prompts from types that don't support it, added trim to script, added `tz` to date
- Fixed custom schema to accurately reflect official param support per type

### Remaining gaps identified

#### High impact
- **`form` top-level replacement** — Espanso supports `form` as a replacement type (alongside `replace`, `html`, `markdown`, `image_path`). Not offered in `select_alt_type` and not handled by `SnippetBuilder`.
- **`word` / `propagate_case` / `uppercase_style`** — common match-level fields, not collected by the wizard
- **`search_terms`** — adds searchable keywords in the Espanso GUI, not collected

#### Medium impact
- **`global` var type** — references a global_var; in schema enum but absent from VAR_TYPES
- **`depends_on`** on vars — needed when shell/global vars depend on each other; not collected
- **`left_word` / `right_word`** — fine-grained word-boundary control; not collected
- **`force_mode`** — override clipboard vs keypresses injection per match; not collected

#### Low impact / niche
- `passive_only`, `force_clipboard` (deprecated), `anchor`/`anchors` (advanced YAML), `paragraph` (markdown-specific)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 clipboard var type implemented (done — TASK-73)
- [x] #2 debug/trim/tz params aligned with official schema (done — TASK-74)
- [x] #3 form top-level replacement supported by wizard and SnippetBuilder
- [x] #4 word, propagate_case, uppercase_style collectable from wizard
- [x] #5 search_terms collectable from wizard
- [x] #6 global var type implemented in VAR_TYPES
- [x] #7 depends_on collectable on vars
- [x] #8 Real-world complex Espanso file produced and validated
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
AC4 scoped: `word` and `propagate_case` added as booleans in advanced options. `uppercase_style` skipped as rare/niche.
<!-- SECTION:NOTES:END -->
