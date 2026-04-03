---
id: TASK-36
title: Make rendering of gum UI elements consistent
status: To Do
assignee: []
created_date: '2026-04-02 21:04'
updated_date: '2026-04-02 21:10'
labels: []
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The CLI's visual layout is currently ad-hoc — UI elements render wherever the cursor happens to be, producing an inconsistent and cluttered experience across wizard runs. This task establishes a deliberate, stable layout contract for all rendered elements.

## Target layout contract
- **Banner + padding** — always pinned at the top of the interaction area
- **Warnings** (`UI.warning`) — always appear in a consistent zone, cleared once the issue is resolved
- **Gum prompts** (input, filter, confirm, write) — always render in a consistent position below warnings
- **Output** (snippet YAML, "Copied to clipboard", "Not copied to clipboard") — may render below the interaction area after the wizard completes

## Current problems
- Warnings linger after the user corrects the triggering issue
- `cursor_checkpoint` (save/restore approach) is unreliable — gum's own TUI cursor management interferes, leaving partial borders visible after clearing
- The multi-trigger info box persists through the entire wizard flow
- No consistent anchor point for prompts relative to prior output

## Proposed approach for transient clearing
Replace `cursor_checkpoint` (save/restore) with a line-count-based strategy that avoids cursor-position uncertainty:

```ruby
def self.transient_warning(text)
  return -> {} unless $stdout.tty?
  warning(text)
  line_count = text.lines.count + 2  # content + top/bottom borders
  -> {
    $stdout.print TTY::Cursor.up(line_count)
    $stdout.print "\r"
    $stdout.print TTY::Cursor.clear_screen_down
  }
end
```

Call sites change from `UI.cursor_checkpoint` + `UI.warning(text)` to `UI.transient_warning(text)`. `cursor_checkpoint` can be removed.

## Call sites to update
- `trigger_resolver.rb` — `prompt_non_empty_trigger` (empty trigger warning)
- `trigger_resolver.rb` — `prompt_trigger_loop` (multi-trigger info box)
- `commands/new.rb` — `var_warnings_cleared?` (var usage warnings)
- `var_builder.rb` — `collect_one_var` (prohibited char + empty name warnings)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Banner and padding always render at the top of the interaction area
- [ ] #2 Warnings always appear in a consistent location and are cleared once the issue is resolved
- [ ] #3 Gum prompts (input, filter, confirm, write) always render in a consistent position
- [ ] #4 Snippet YAML and clipboard status messages render below the interaction area after wizard completes
- [ ] #5 UI.transient_warning replaces cursor_checkpoint for all transient warning call sites
- [ ] #6 No regressions — all existing examples pass
<!-- AC:END -->
