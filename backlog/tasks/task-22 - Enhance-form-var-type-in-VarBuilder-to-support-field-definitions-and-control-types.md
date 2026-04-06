---
id: TASK-22
title: >-
  Enhance form var type in VarBuilder to support field definitions and control
  types
status: To Do
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-04-06 02:57'
labels:
  - ux
  - wizard
  - forms
milestone: none
dependencies: []
references:
  - 'https://espanso.org/docs/matches/forms/'
priority: medium
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Enhance the existing `form` variable type in `VarBuilder::Params` to support full Espanso form functionality. Currently, the `form` collector only prompts for a raw layout string. It needs to be expanded to also collect field-level configuration (control type, multiline, values, defaults) for each `[[field]]` placeholder in the layout.

In Espanso, forms are a type of variable (`type: form`) — not a separate concept. They sit alongside `shell`, `script`, `date`, etc. in the `vars:` array. This means the implementation belongs inside VarBuilder as an enhanced param collector for the existing `form` type, not as a separate builder.

### How forms work as vars

Forms are declared as `type: form` variables with a `params.layout` containing `[[field_name]]` placeholders, and an optional `params.fields` hash for field-level config:

```yaml
vars:
  - name: form1
    type: form
    params:
      layout: |
        Name: [[name]]
        Fruit: [[fruit]]
      fields:
        name:
          multiline: true
        fruit:
          type: list
          values:
            - Apples
            - Bananas
```

Form field values are referenced by other vars as `{{formName.fieldName}}`:

```yaml
vars:
  - name: form1
    type: form
    params:
      layout: "Reverse [[name]]"
  - name: reversed
    type: shell
    params:
      cmd: "echo '{{form1.name}}' | rev"
```

### Form control types

| Control | Key properties |
|---------|---------------|
| **Text** (default) | `multiline: true/false`, `default` |
| **Choice** (dropdown) | `type: choice`, `values` (array), `default` |
| **List** (list box) | `type: list`, `values` (array), `default` |

### What needs to change

The current `form` collector in `Params::COLLECTORS` is a single lambda that prompts for a layout string. It needs to become a full private method (like `shell` or `script`) that:

1. Prompts for the layout string (existing behavior)
2. Parses `[[field_name]]` placeholders from the layout
3. For each field, prompts for control type (text/choice/list) and type-specific options
4. Returns `{ layout: ..., fields: { ... } }` (only includes `fields` if any field has non-default config)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Existing `form` type in VarBuilder enhanced — no separate FormFieldBuilder class
- [ ] #2 Layout prompt collects a multi-line template with `[[field_name]]` placeholders
- [ ] #3 After layout entry, each `[[field]]` placeholder is parsed and the user is prompted for its control type (text/choice/list)
- [ ] #4 Text fields: user prompted for multiline (bool) and default value
- [ ] #5 Choice and list fields: user prompted for values list and default
- [ ] #6 Params output includes `fields:` hash only when fields have non-default config
- [ ] #7 Form field values referenceable by subsequent vars as `{{formName.fieldName}}`
- [ ] #8 Summary table displays form fields with their types after collection
- [ ] #9 Generated YAML matches Espanso verbose form syntax (`type: form`, `params.layout`, `params.fields`)
- [ ] #10 Integration with existing VarBuilder flow — form is just another var type alongside shell, script, etc.
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Notes

### Current state

The `form` type already exists in `VarBuilder::Params::COLLECTORS` as a simple lambda:
```ruby
'form' => ->(b) { { layout: b.prompt!(Gum.write(header: 'Form layout...')) } }
```

This only collects a raw layout string. No field-level configuration is collected.

### What to change

1. **Move `form` from `COLLECTORS` hash to a private method** (like `date`, `shell`, `script`) since it now needs multi-step collection
2. **Add to `case/when` dispatch** in `Params.collect`:
   ```ruby
   when 'form' then form(builder)
   ```
3. **Implement `form` private method** that:
   - Prompts for layout string (multi-line via `Gum.write`)
   - Parses `[[field_name]]` placeholders from the layout using regex
   - For each parsed field, prompts for:
     - Control type: `Gum.filter(%w[text choice list])`
     - If text: multiline? (`Gum.confirm`), default value (`Gum.input`, optional)
     - If choice/list: values list (`collect_list`), default value (optional)
   - Builds `fields` hash only for fields with non-default config
   - Returns `{ layout: ..., fields: { ... } }` (omit `fields` key if all defaults)

### Patterns to reuse

- `Params.collect_list(builder, label)` — already exists for `choice`/`random` types, reuse for form choice/list values
- `builder.confirm!` — for yes/no prompts (multiline toggle)
- `Gum.filter` — for type selection
- `TableFormatter` — for summary display of collected fields

### Reference
- Espanso forms docs: https://espanso.org/docs/matches/forms/
- Verbose syntax with extensions: https://espanso.org/docs/matches/forms/#using-forms-with-script-and-shell-extensions
<!-- SECTION:NOTES:END -->
