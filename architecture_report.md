# snippet_cli: DRY & Architecture Improvement Report

## 1. DRY Violations

| Issue | Files | Fix |
|---|---|---|
| YAML var block rendering implemented twice, with different scalar-quoting strategies | `snippet_builder.rb:74-87`, `commands/vars.rb:50-74` | Extract `VarYamlRenderer` module |
| Transient screen-clear lambda duplicated | `ui.rb:51-59`, `var_builder.rb:118-129` | Extract `CursorHelper.build_erase_lambda(n)` |
| `File.exist? ? File.read : ''` idiom written inline twice | `match_file_writer.rb:10`, `global_vars_writer.rb:13` | Extract `FileHelper.read_or_empty(path)` |
| Trailing-newline enforcement done two different ways | `match_file_writer.rb:16`, `global_vars_writer.rb:78-81` | One shared `StringHelper.ensure_trailing_newline` |
| Multiline YAML block rendering repeated | `snippet_builder.rb:47-54`, `yaml_param_renderer.rb:24-31`, `var_builder/params.rb:71-75` | Consolidate in `YamlParamRenderer` |
| "Loop until valid with transient feedback" prompt pattern written 3x | `replacement_collector.rb:35-53`, `trigger_resolver.rb:93-101`, `var_builder/name_collector.rb:23-34` | Extract `TransientValidatedPrompt` helper |

---

## 2. Single Responsibility Violations

**`ReplacementCollector`** — handles prompt strategy, alt-type validation, variable usage warnings, and transient error clearing all in one module. Split into a `ReplacementTextCollector` + `ReplacementValidator`, let the `New` command orchestrate.

**`VarBuilder`** — mixes interactive flow orchestration, summary display, TTY cursor manipulation, and platform shell detection. Extract `VarSummaryRenderer` and reduce `VarBuilder` to pure collection logic.

**`GlobalVarsWriter`** — content formatting (`build_content` and helpers) is entangled with file I/O (`append`, `read_names`). Separate into `GlobalVarsFormatter` (pure, testable) + thin I/O wrapper.

---

## 3. Missing Abstractions

**Error handling boilerplate** — `rescue ValidationError / EspansoConfigError / WizardInterrupted` with `UI.error + exit 1` repeated verbatim in every command. Extract a `CommandHelpers#handle_errors { yield }` mixin.

**Gum tight coupling** — `Gum.*` called directly in 9+ files. Introduce a `Prompts` facade (`Prompts.choose`, `Prompts.input`, etc.) so the UI library is swappable and testable without mocking a gem.

**Confirm-then-prompt pattern** — `confirm!('Add X?') ? prompt!(Gum.input(...)) : nil` repeated across `commands/new.rb`, `var_builder/params.rb`, `replacement_collector.rb`. Extract `WizardHelpers#optional_prompt(question, &collector)`.

**Return value objects** — `trigger_resolver.rb:36` returns an unnamed 3-tuple `[list, is_regex, false]`. Use a `Struct` (`TriggerResolution`) so callers aren't position-dependent.

---

## 4. Consistency Issues

**File validation** — three patterns in use: delegate to `YamlLoader`, manual `File.exist?` + `UI.error`, and silent `return unless`. Standardize with `FileValidator.ensure_readable!(path)`.

**Error output** — `trigger_resolver.rb:44` uses raw `warn` instead of `UI.error`. Everything should go through `UI`.

**`YamlScalar::InvalidCharacterError`** — raised in `yaml_scalar.rb:36` but never rescued anywhere; will produce an unformatted crash. Catch in commands and surface via `UI.error`.

---

## Recommended Phases

### Phase 1 — Quick wins (low effort)
- `FileHelper.read_or_empty`
- `StringHelper.ensure_trailing_newline`
- `CursorHelper.build_erase_lambda`
- Catch `InvalidCharacterError` in commands

### Phase 2 — Medium effort, high value
- `Prompts` facade to decouple Gum
- `CommandHelpers#handle_errors` mixin
- `TransientValidatedPrompt` loop helper

### Phase 3 — Structural (higher effort)
- Split `ReplacementCollector` and `VarBuilder` for SRP
- Separate `GlobalVarsWriter` formatting from I/O
- Introduce value objects (`TriggerResolution`, etc.)
