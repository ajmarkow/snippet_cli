---
id: TASK-16
title: Show contextual regex syntax guidance for regex triggers via `UI.info`
status: Done
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-31 02:27'
labels:
  - validation
  - schema
milestone: none
dependencies: []
priority: medium
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
When the user selects or is working with a regex-based trigger display a non-persistent prompt note using UI.info. The note should clearly state that Espanso uses Rust Regex syntax and include a link to the official docs https://docs.rs/regex/1.1.8/regex/#syntax. The message should be informational only visually distinct and only shown in regex workflows.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Regex input flow displays a UI.info note before output is emitted
- [x] #2 The note text is: "Espanso uses Rust Regex Syntax, ensure this is a valid Rust regex."
- [x] #3 No programmatic regex validation is added as part of this task
- [x] #4 When regex trigger type is selected a UI.info message is displayed
- [x] #5 Message is non-persistent and does not affect stored snippet or output
- [x] #6 Message includes 'Espanso uses Rust Regex syntax' and link to docs
- [x] #7 Message is visually distinct (colored text)
- [x] #8 Message appears at the correct moment before or during regex input
- [x] #9 Message does not interrupt or block user input
- [x] #10 Message is not shown for non-regex trigger types
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added `UI.info` call in `collect_triggers` when type is `regex`, displaying Rust Regex syntax guidance with a link to the official docs before prompting for input. Constant `RUST_REGEX_GUIDANCE` defined in `TriggerResolver`. Three new specs added to `trigger_resolver_spec.rb` covering message content, doc link, and ordering relative to input prompt. All 181 tests pass.
<!-- SECTION:FINAL_SUMMARY:END -->
