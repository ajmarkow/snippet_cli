---
id: TASK-1
title: Update figlet
status: Done
assignee: []
created_date: '2026-03-27 19:03'
updated_date: '2026-03-28 02:59'
labels: []
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Old verison had a nice figlet text when launching. Develop new version. Prefer no external dependencies, just write a simple.rb that .puts the design
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added ASCII banner to `lib/snippet_cli/banner.rb` as `SnippetCli::BANNER` and wired it into `exe/snippet_cli` to print on every invocation. Integration test added first (TDD) confirming the banner appears in output. All 3 integration tests pass.
<!-- SECTION:FINAL_SUMMARY:END -->
