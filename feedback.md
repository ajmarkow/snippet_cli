# SRP / DRY / OOP Feedback Plan

## Scope
Reviewed core CLI, command, builder, and rendering code paths in `lib/` plus selected test pressure points in `spec/commands/new_spec.rb`.

---

## Quick strengths
- The project already separates many concerns into focused modules (rendering, YAML scalar quoting, schema validation, config discovery).
- There are good seams for refactoring because behavior is centralized in named modules.

---

## Priority findings and improvement plan

## 1) **SRP + encapsulation:** `Commands::New` is orchestrating too many concerns through mixins and implicit state

### Evidence
- `New` mixes trigger resolution, replacement collection, wizard helpers, save flow, and output flow in one command boundary: `lib/snippet_cli/commands/new.rb:18-93`.
- Cross-module state coupling through instance variables (implicit contract):
  - `@summary_clear` and `@global_var_names` are set in command methods: `lib/snippet_cli/commands/new.rb:58-59`, `lib/snippet_cli/commands/new.rb:71-73`.
  - `ReplacementCollector` reaches into `@global_var_names` dynamically: `lib/snippet_cli/replacement_collector.rb:67-70`.

### Why it matters
- Harder to reason about object boundaries and lifecycle.
- Increases test setup complexity and indirect coupling.

### Plan
1. Introduce a dedicated `NewWorkflow` (or similar) that receives dependencies explicitly (`trigger_resolver`, `replacement_collector`, `var_builder`, `writers`, `ui`).
2. Replace instance-variable communication with explicit data objects (e.g., `WizardContext` carrying `global_var_names`, `summary_clear`).
3. Keep `Commands::New#call` as thin command adapter only.

---

## 2) **SRP at abstraction boundaries:** low-level helpers terminate process (`exit`) and print warnings

### Evidence
- Helpers and utility modules call `warn`/`exit`: `lib/snippet_cli/file_helper.rb:7-12`, `lib/snippet_cli/yaml_loader.rb:11-17`, `lib/snippet_cli/trigger_resolver.rb:41-47`, `lib/snippet_cli/trigger_resolver.rb:105-115`, `lib/snippet_cli/wizard_helpers.rb:55-57`, `lib/snippet_cli/wizard_helpers.rb:68-73`.

### Why it matters
- Business/utility code controls process lifecycle, reducing reusability.
- Makes these modules harder to reuse from non-CLI contexts and harder to test in isolation.

### Plan
1. Replace `warn/exit` in non-command modules with typed exceptions (`InvalidFlagsError`, `FileMissingError`, etc.).
2. Handle process exit in command layer only (`Commands::*#call`) where CLI policy belongs.
3. Standardize a single error presenter for consistent UX and lower duplication.

---

## 3) **DRY:** schema validator logic duplicated between `MatchValidator` and `FileValidator`

### Evidence
- Repeated schema path constant and schemer memoization in both modules: `lib/snippet_cli/match_validator.rb:13-15`, `lib/snippet_cli/match_validator.rb:38-40`, `lib/snippet_cli/file_validator.rb:11-13`, `lib/snippet_cli/file_validator.rb:30-32`.
- Similar data-prep flow (`HashUtils.stringify_keys_deep`) and error mapping in both: `lib/snippet_cli/match_validator.rb:22-30`, `lib/snippet_cli/file_validator.rb:17-27`.

### Why it matters
- Parallel changes risk drift and inconsistent validation output.

### Plan
1. Create a shared `SchemaValidator` base/service responsible for loading schemer once and formatting errors.
2. Keep entry-specific behavior only (`wrap` for single-match validation) in tiny adapters.

---

## 4) **DRY:** repeated form-field parsing regex in multiple modules

### Evidence
- Same `[[field]]` parsing pattern appears in:
  - `lib/snippet_cli/var_builder/form_fields.rb:18`
  - `lib/snippet_cli/var_usage_checker.rb:8`, `lib/snippet_cli/var_usage_checker.rb:34`
  - `lib/snippet_cli/var_summary_renderer.rb:35-37`

### Why it matters
- Regex-rule changes must be updated in multiple places.
- Risk of subtle mismatch in how form fields are interpreted.

### Plan
1. Extract a `FormFieldParser.extract(layout)` helper.
2. Replace duplicated scans with parser calls.
3. Add focused unit tests on parser edge cases.

---

## 5) **DRY + consistency:** output styling and terminal rendering concerns are duplicated/inconsistent

### Evidence
- `UI` has multiple near-identical style wrappers: `lib/snippet_cli/ui.rb:12-30`.
- Raw ANSI output also appears outside `UI` in conflict command: `lib/snippet_cli/commands/conflict.rb:46`, `lib/snippet_cli/commands/conflict.rb:62`.

### Why it matters
- Styling policy is not centralized.
- Future style/theme changes require touching multiple layers.

### Plan
1. Define UI style presets (`:info`, `:warning`, `:error`, etc.) in one map.
2. Route all human-facing terminal output through `UI` only.
3. Remove command-level ANSI literals.

---

## 6) **OOP maintainability:** complexity hotspot intentionally bypasses complexity checks

### Evidence
- `TableFormatter.render` disables complexity cops and contains multiple formatting responsibilities in one method: `lib/snippet_cli/table_formatter.rb:5-17`.

### Why it matters
- Harder to extend/modify safely.
- Indicates method is carrying too much behavior.

### Plan
1. Break `render` into composable private methods (`compute_widths`, `build_border`, `build_rows`, `colorize`).
2. Consider delegating to existing table-rendering utility where possible to reduce custom rendering surface.

---

## 7) **DRY:** vars YAML assembly is partially duplicated across command and builder paths

### Evidence
- `Commands::Vars#vars_yaml` constructs lines manually: `lib/snippet_cli/commands/vars.rb:47-53`.
- `SnippetBuilder` also owns vars block assembly for snippet rendering: `lib/snippet_cli/snippet_builder.rb:70-74`.

### Why it matters
- Two call paths can drift in shape/ordering conventions.

### Plan
1. Extract shared `VarsBlockRenderer.render(vars, indent:)`.
2. Reuse from both command and snippet builder.

---

## Suggested implementation order
1. **Boundary cleanup first:** move `exit/warn` policy to command layer (Finding #2).
2. **Untangle New workflow:** explicit context + injected dependencies (Finding #1).
3. **Consolidate duplicate core logic:** schema validators + form field parser + vars block renderer (Findings #3, #4, #7).
4. **Presentation cleanup:** centralize UI styling and simplify table formatter (Findings #5, #6).

This order reduces coupling first, then consolidates duplication, then improves presentation maintainability.
