# Snippet CLI — Plan Rev 1

## Overview

A single `snippet new` command with option flags, plus a set of utility commands.
Output is a valid Espanso match entry (YAML), either appended to a file or printed to stdout.

---

## `snippet new`

### Trigger flags (one required)

| Flag | Type | Description |
|---|---|---|
| `--trigger` | String | Single trigger string |
| `--triggers` | String (comma-separated) | Multiple triggers |
| `--regex` | String | Regex trigger |

### Replacement flags (one required)

| Flag | Type | Description |
|---|---|---|
| `--replace` | String | Static text replacement |
| `--form` | String | Form layout string with `[[field]]` syntax |
| `--image` | String (path) | Path to image file |

### Var flags (optional — attach a variable to the match)

| Flag | Type | Description |
|---|---|---|
| `--shell` | String (cmd) | Shell extension var; reference with `{{var}}` in `--replace` |
| `--date` | String (format) | Date extension var (e.g. `"%Y-%m-%d"`) |
| `--random` | String (comma-separated) | Random extension var; Espanso picks one at expansion time |
| `--choice` | String (comma-separated) | Choice extension var; user picks at expansion time |
| `--script` | String String (lang path) | Script extension var |

### Optional match flags

| Flag | Type | Description |
|---|---|---|
| `--label` | String | Search label override |
| `--word` | Boolean | Word-boundary trigger mode |
| `--propagate-case` | Boolean | Case propagation |
| `--file` | String (path) | Append output to this YAML file (default: stdout) |

### Example invocations

```bash
# Static
snippet new --trigger :ty --replace "Thank you"

# Multiple triggers
snippet new --triggers :ty,:thankyou --replace "Thank you"

# Date var
snippet new --triggers :now,:date --replace "Today is {{date_var}}" --date "%Y-%m-%d"

# Form
snippet new --trigger :addr --form "Street: [[street]], City: [[city]]"

# Shell var
snippet new --trigger :sh --replace "{{out}}" --shell "whoami"

# Append to file
snippet new --trigger :ty --replace "Thank you" --file ~/.config/espanso/match/base.yml
```

---

## Utility Commands

| Command | Description |
|---|---|
| `snippet validate FILE` | Validate a YAML match file against the Espanso schema |
| `snippet list FILE` | List all triggers defined in a match file |
| `snippet version` | Print the current gem version |
