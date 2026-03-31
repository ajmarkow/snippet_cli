---
id: TASK-22
title: Refine form-based snippet creation flow for clarity and usability
status: To Do
assignee: []
created_date: '2026-03-30 04:13'
updated_date: '2026-03-31 03:08'
labels:
  - ux
  - wizard
milestone: none
dependencies: []
priority: medium
ordinal: 0
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Improve the UX of the form wizard used in `snippet new --form` to make the process more intuitive efficient and less error-prone. Focus on step clarity reducing friction improving layout and readability and ensuring alignment between user input and generated output. Identify current pain points and address them via flow or prompt improvements.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each step in the form flow has a clear and specific prompt
- [ ] #2 User can complete the flow without confusion or backtracking
- [ ] #3 Input fields map cleanly to generated form output (`form:` syntax)
- [x] #4 Preview or output is accurate and easy to understand
- [x] #5 No redundant or unnecessary steps in the flow
- [ ] #6 Flow handles multiple variables cleanly and scales beyond a few inputs
- [ ] #7 At least one end-to-end example from input to generated snippet
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Implementation Notes

The form flow needs a dedicated `FormFieldBuilder` (analogous to `VarBuilder`) that guides the user through defining form fields before they can be referenced in the layout template.

### Key requirements

- Form fields in Espanso are defined under `vars` with `type: form`, and the `params.layout` references them as `[[field_name]]`
- The builder must collect field definitions first, then use those field names to construct (or validate) the layout template
- Fields must be defined before they can be used — the layout should only reference names that were explicitly collected
- This mirrors the `VarBuilder` pattern but scoped to `form` type vars and the `[[name]]` syntax

### Suggested approach

- Build a `FormFieldBuilder` module/class that:
  1. Collects one or more field names (and optionally field types, e.g. text, choice, toggle)
  2. Shows a summary table of defined fields (reuse `TableFormatter`)
  3. Either auto-generates the layout from the collected fields, or prompts the user to compose it with the field names surfaced for reference
- Wire it into `VarBuilder::Params` for the `form` collector, replacing the current raw `layout` input prompt
<!-- SECTION:NOTES:END -->
