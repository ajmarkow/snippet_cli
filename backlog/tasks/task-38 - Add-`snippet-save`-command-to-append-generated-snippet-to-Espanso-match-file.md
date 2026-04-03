---
id: TASK-38
title: Add `snippet save` command to append generated snippet to Espanso match file
status: To Do
assignee: []
created_date: '2026-04-03 16:04'
updated_date: '2026-04-03 16:09'
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

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 `espanso path` is called once at save time (not at startup).
- [ ] #2 The resolved match file path is shown to the user before writing.
- [ ] #3 The snippet YAML is appended correctly and the file remains valid YAML.
- [ ] #4 If the match file does not exist, it is created with the correct header.
- [ ] #5 No changes are made to the file if the user declines the save prompt.
<!-- SECTION:DESCRIPTION:END -->
<!-- AC:END -->
