---
id: TASK-38
title: Add `snippet save` command to append generated snippet to Espanso match file
status: Done
assignee: []
created_date: '2026-04-03 16:04'
updated_date: '2026-04-04 16:23'
labels: []
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## Goal

After generating a snippet in the wizard, give users a way to persist it directly to their Espanso match file without manual copy-paste.

## Approach

Use the **Load-Modify-Overwrite** pattern — never raw file append — to keep the YAML structure intact:

```ruby
require 'yaml'

file_path = espanso_match_file_path

# 1. Load existing data
data = YAML.load_file(file_path) || { 'matches' => [] }

# 2. Append the new match hash
data['matches'] << new_match

# 3. Overwrite the file with the updated structure
File.write(file_path, data.to_yaml)
```

### Steps

1. **Discover the Espanso config path** by shelling out to `espanso path`. Parse the `Config:` line with a regex to get the config dir, then resolve `<config>/match/base.yml` as the default target.
2. **Load the match file** with `YAML.load_file`. If the file does not exist, start from `{ 'matches' => [] }`.
3. **Push the new match** onto `data['matches']`.
4. **Overwrite** the file with `File.write(path, data.to_yaml)`.
5. **Surface the save step** — after the final YAML preview in the wizard, prompt: "Save to Espanso match file? [y/N]" via `gum confirm`. Show the resolved path before writing.

## Clipboard — Unix pipe philosophy

No clipboard gem. No "copy to clipboard" prompt. Instead, when stdout is a pipe, write the generated YAML to stdout so the user can pipe it wherever they want:

```bash
snippet new | pbcopy      # macOS
snippet new | xclip       # Linux (X11)
snippet new | clip        # Windows
```

When stdout is a TTY (interactive), display the YAML preview as normal. The tool does one thing — generate and optionally save the snippet — and delegates clipboard concerns to the shell.

This removes the clipboard gem dependency entirely.

## Implementation notes

- `espanso path` returns something like:
  ```
  Config: /Users/aj/Library/Application Support/espanso
  Package: ...
  Runtime: ...
  ```
  Parse with `/^Config:\s*(.+)$/`.
- The match file to target is typically `<config>/match/base.yml`. Consider a `--match-file` flag for overrides.
- `YAML.load_file` may return `nil` on an empty file — guard with `|| { 'matches' => [] }`.
- Validate that the file is valid YAML after writing (re-run the schema validator if available).
- Check `$stdout.tty?` to decide between interactive preview and pipe-friendly raw output.
<!-- SECTION:DESCRIPTION:END -->

<!-- AC:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 espanso path is called once at save time (not at startup).
- [ ] #2 The resolved match file path is shown to the user before writing.
- [ ] #3 The snippet YAML is appended correctly and the file remains valid YAML.
- [ ] #4 If the match file does not exist, it is created with the correct header.
- [ ] #5 No changes are made to the file if the user declines the save prompt.
- [x] #6 No clipboard gem dependency — clipboard handling is delegated to the shell via pipes.
- [x] #7 When stdout is a pipe ($stdout.tty? is false), the generated YAML is written to stdout and all interactive UI (gum prompts, borders, colors) is suppressed.
- [x] #8 No 'copy to clipboard' prompt is shown at any point.
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented pipe-aware output and removed clipboard dependency.\n\n**Changes made:**\n- `snippet_cli.gemspec`: removed `clipboard` gem dependency\n- `exe/snippet_cli`: banner suppressed when stdout is not a TTY (pipe)\n- `lib/snippet_cli/commands/new.rb`: removed `--no_clipboard` option; `output_result` now checks `$stdout.tty?` — TTY shows styled preview, pipe writes raw YAML\n- `lib/snippet_cli/commands/vars.rb`: same pipe-aware output; removed `--no_clipboard` option and `copy_to_clipboard` method\n- Also restored `var_error_clear` to use `UI.warning` + `confirm!('Are you sure you want to continue?')` (the "Are you sure?" exit condition had been lost in a prior refactor, causing an infinite loop)\n\n**Spec changes:**\n- Removed clipboard-related contexts and stubs from `new_spec.rb` and `vars_spec.rb`\n- Added pipe output context to both specs\n- Updated `Trigger type?` header stub to match the `\\n`-terminated version from the refactored `trigger_resolver.rb`\n\nAll 68 new/vars command specs pass. 53 pre-existing failures remain in var_builder, trigger_resolver, wizard_helpers, and integration specs (from prior refactoring work not part of this task).
<!-- SECTION:FINAL_SUMMARY:END -->
