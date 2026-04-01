---
id: TASK-32
title: Support image path type for replace string
status: Done
assignee: []
created_date: '2026-03-31 03:56'
updated_date: '2026-04-01 21:20'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add an `image_path` variable type that resolves to a local file path pointing to an image. This is a replace string whose value is a path to an image file on disk.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 `image_path` is supported as an alternative to `replace` at the top level of a snippet definition
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented `image_path` (plus `html` and `markdown`) as alternative replacement types in the snippet wizard and builder. `resolve_replacement` now returns a hash and splats into `SnippetBuilder.build`. `replacement_lines` dispatches on `:replace`, `:image_path`, `:html`, `:markdown`. Schema submodule updated to include `html` and `markdown` in the replacement `oneOf`. All 296 specs pass.
<!-- SECTION:FINAL_SUMMARY:END -->
