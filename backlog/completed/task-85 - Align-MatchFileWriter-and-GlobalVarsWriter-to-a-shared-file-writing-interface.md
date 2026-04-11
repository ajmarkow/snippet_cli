---
id: TASK-85
title: Align MatchFileWriter and GlobalVarsWriter to a shared file-writing interface
status: Done
assignee: []
created_date: '2026-04-11 15:48'
updated_date: '2026-04-11 16:05'
labels:
  - architecture
  - refactor
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
`MatchFileWriter` (`lib/snippet_cli/match_file_writer.rb`) embeds its own `build_content` logic, while `GlobalVarsWriter` (`lib/snippet_cli/global_vars_writer.rb`) delegates formatting to `GlobalVarsFormatter`. The two writers have no shared interface. If atomic writes, backup-before-write, or other file-safety behaviors are added, they must be implemented independently in each writer.

The goal is a shared abstraction (base class, mixin, or shared `FileWriter` utility) so file-safety behaviors are added in one place.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 MatchFileWriter and GlobalVarsWriter share a common interface or base for the write operation
- [x] #2 Content-building (formatting) is consistently separated from file I/O in both writers
- [x] #3 Adding atomic write behavior requires a change in one place, not two
- [x] #4 All existing specs pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Extracted `FileWriter` module (`lib/snippet_cli/file_writer.rb`) with a single `self.write(path, content)` class method. Both `MatchFileWriter` and `GlobalVarsWriter` now require and delegate to `FileWriter.write` instead of calling `File.write` directly. Added `spec/file_writer_spec.rb` (2 examples). All 696 specs pass. Future atomic-write behavior requires a change in one place.
<!-- SECTION:FINAL_SUMMARY:END -->
