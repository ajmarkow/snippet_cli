# CLI Guidelines Compliance Review — `snippet_cli`

Source: [cli-guidelines/cli-guidelines](https://github.com/cli-guidelines/cli-guidelines)

---

## Issues Found

### 1. ASCII art banner on every invocation
The banner prints unconditionally, including in non-interactive contexts. Guidelines: avoid unnecessary output; anything not essential to the task is noise. The banner should be suppressed when stdout is not a TTY.

### 2. `version` output is decorative, not machine-readable
Outputs a styled box instead of a plain string. The convention (`git --version`, `ruby --version`) is to print `snippet_cli 0.3.2` to stdout and nothing else. This breaks scripting.

### 3. Flag naming uses underscores
`--no_warn` should be `--no-warn`. Hyphens are the universal convention for multi-word CLI flags.

### 4. Two-character short flag `-nw`
Short flags are single characters by convention. `-nw` is non-standard. Remove it or replace with a single character like `-W`.

### 5. No `--no-input` flag
The CLI is deeply interactive with no way to suppress prompts entirely. Guidelines say to support `--no-input` (or equivalent) so the tool is usable in scripts and CI pipelines without hanging.

### 6. No `--version` top-level flag
`snippet_cli --version` should work in addition to `snippet_cli version`. Most users expect this pattern.

### 7. Command aliases are single-letter abbreviations
`n`, `c`, `v` as aliases for `new`, `conflict`, `validate` — the guidelines warn against arbitrary abbreviations that reduce discoverability. If aliases are kept, they should be intuitive full words (e.g., no alias needed since the commands are already short).

### 8. No `NO_COLOR` support
The CLI uses color heavily but there's no indication it respects the `NO_COLOR` environment variable or disables colors/styling when stdout is not a TTY (beyond the TTY redirect for prompts).

### 9. Diagnostic messages routing
Verify that `UI.error`, `UI.warning`, etc. write to `$stderr`. Guidelines: all diagnostic/informational output goes to stderr; only primary output goes to stdout.

---

## Summary of Suggested Changes

| Issue | Change |
|---|---|
| Banner | Suppress when stdout is not a TTY |
| `version` output | Print `snippet_cli 0.3.2` plaintext to stdout |
| `--no_warn` | Rename to `--no-warn` |
| `-nw` | Remove or replace with single char |
| Interactivity | Add `--no-input` flag that errors instead of prompting |
| Version flag | Add `--version` as top-level flag alias |
| Command aliases | Remove single-letter aliases or document clearly |
| Color | Respect `NO_COLOR` env var; strip styling when not a TTY |
| Stderr | Audit all UI output routes to ensure errors go to stderr |

> **Highest priority:** issues 2, 5, and 3 — these are most likely to cause friction in scripting or automation contexts.
