# Snippet CLI — Plan Rev 1

## Overview

A single `snippet new` command with option flags, plus a set of utility commands.
Output is a valid Espanso match entry (YAML) printed to stdout. The user pipes or redirects as needed.

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

```

---

## Utility Commands

| Command | Description |
|---|---|
| `snippet validate FILE` | Validate a YAML match file against the Espanso schema |
| `snippet list FILE` | List all triggers defined in a match file |
| `snippet version` | Print the current gem version |

---

## Schema Audit Findings (2026-03-27)

Two schemas were evaluated for use in `snippet validate`:

- **Custom schema**: https://raw.githubusercontent.com/ajmarkow/espanso-schema-json/refs/heads/master/schemas/Espanso_Match_Schema.json
- **Official schema**: https://raw.githubusercontent.com/espanso/espanso/refs/heads/dev/schemas/match.schema.json

### Key finding: scope difference

The official schema validates a full `base.yaml` file (top-level `matches` array + `global_vars` + `imports`). The custom schema validates a single match object at root level — better suited for per-item IDE validation.

### Official schema — pros/cons

**Pros**
- Maintained by the Espanso team; tracks new features automatically
- Complete property coverage: `html`, `markdown`, `force_mode`, `force_clipboard`, `uppercase_style`, `left_word`, `right_word`, `search_terms`, `comment`, `anchor`, `paragraph`
- Correct IANA timezone (~600 values) and BCP47 locale (~300 values) enums
- No type mismatches on boolean defaults

**Cons**
- 12 of 22 match properties have zero description
- Only 1 doc link in the entire schema
- Requires pointing at `definitions/match` for per-item IDE validation

### Custom schema — pros/cons

**Pros**
- ~40+ properties with substantive prose descriptions
- Nearly every property links to a specific espanso.org docs page
- Per-item design works naturally for IDE hover/autocomplete
- Correctly enforces that exactly one of `trigger`/`triggers`/`regex` is required

**Cons — 5 correctness bugs**
1. `locale` enum is a single comma-joined string instead of individual values — will reject every valid locale
2. Boolean fields (`passive_only`, `multiline`, `trim_string_values`) have string defaults (`"false"`) instead of boolean defaults (`false`)
3. `globalvarItems` is not a valid JSON Schema keyword — the constraint is silently ignored by validators
4. `script` args capped at `maxItems: 2` — incorrectly rejects scripts with 3+ arguments
5. `form_fields.type` includes `"form"` — not a valid form control type

**Cons — coverage gaps**
Missing 11 properties: `html`, `markdown`, `force_mode`, `force_clipboard`, `uppercase_style`, `left_word`, `right_word`, `search_terms`, `comment`, `anchor`, `paragraph`

### Recommendation

Do not use the custom schema as-is for validation — the broken `locale` enum and missing properties under `additionalProperties: false` will produce false failures on valid configs.

**Recommended path:** merge the two schemas. Use the official schema as the authoritative source of property coverage, types, and constraints, then layer the custom schema's descriptions and doc links on top. This would produce a schema superior to either individually.

Until that merged schema exists, use the official schema for `snippet validate` correctness, and reference the custom schema for documentation context.
