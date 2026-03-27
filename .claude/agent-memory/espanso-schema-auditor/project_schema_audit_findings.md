---
name: Espanso Schema Audit Structural Findings
description: Key structural differences between official Espanso match schema and AJ's custom schema, discovered during 2026-03-26 audit
type: project
---

## Official Schema Structure
- Uses `definitions` with `$ref` for: match, var, anchor, form_field_definition, form_multiline_field, form_choice_or_list_field
- Top-level is a **file-level schema** (properties: $schema, imports, anchors, matches, global_vars)
- Var types use `oneOf` with per-type objects (each has own `additionalProperties: false`)
- 9 var types: shell, script, date, echo, clipboard, choice, form, random, match
- Match has 5 action oneOf: replace, form, html, image_path, markdown

## Custom Schema Structure
- Top-level is a **single match schema** (not file-level), no imports/anchors/matches wrapper
- Var types use `allOf` with `if/then` conditional branches (looser validation)
- 9 var type enum values but includes `global` instead of `match`
- Match has 3 action oneOf: replace, image_path, form (missing html, markdown)
- Form fields include `form` as a type enum value (not in official)

## Key Gaps in Custom
- Missing match properties: comment, force_clipboard, force_mode, html, markdown, left_word, right_word, search_terms, uppercase_style, paragraph, anchor
- Missing var type: `match` (nested match); has `global` which is not in official
- Missing var properties: inject_vars (on all var types), trim (on shell/script)
- Date var missing: tz, locale (proper enum); offset should accept string|number not just integer
- Shell var missing shells: nu, pwsh, wsl2, zsh
- Form field definition: official uses patternProperties + anyOf refs; custom uses additionalProperties + allOf if/then
- Custom has `passive_only` which is not in official schema (legacy feature)
