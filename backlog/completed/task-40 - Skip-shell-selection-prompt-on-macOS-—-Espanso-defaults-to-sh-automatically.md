---
id: TASK-40
title: Skip shell selection prompt on macOS — Espanso defaults to sh automatically
status: Done
assignee: []
created_date: '2026-04-03 16:21'
updated_date: '2026-04-04 21:13'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## Problem

`Params.shell` always prompts the user to pick a shell via `Gum.filter`. On macOS, Espanso automatically uses `sh` when no `shell` param is provided, so the prompt is unnecessary noise and the `shell` key should simply be omitted from the params hash.

## Fix

In `lib/snippet_cli/var_builder/params.rb`, update `Params.shell` to skip the shell prompt on macOS:

```ruby
def self.shell(builder)
  params = { cmd: builder.prompt!(Gum.input(placeholder: 'shell command')) }
  unless RUBY_PLATFORM.match?(/darwin/)
    sh = builder.prompt!(Gum.filter(*builder.platform_shells, limit: 1, header: 'Select shell'))
    params[:shell] = sh
  end
  debug_trim(builder, **params)
end
```

On Linux/Windows the prompt still appears since multiple shells are meaningful choices.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 On macOS (`RUBY_PLATFORM =~ /darwin/`), the shell prompt is skipped and no `shell` key is included in the params hash.
- [x] #2 On Linux/Windows, the shell prompt still appears as before.
- [x] #3 Specs for `Params.shell` cover the macOS (no shell key) and non-macOS (shell key present) cases.
<!-- SECTION:DESCRIPTION:END -->

<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Closed as unnecessary — Espanso's default shell behavior on macOS makes this change not needed.
<!-- SECTION:FINAL_SUMMARY:END -->
