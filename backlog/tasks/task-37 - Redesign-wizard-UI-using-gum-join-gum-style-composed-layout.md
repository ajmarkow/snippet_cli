---
id: TASK-37
title: Redesign wizard UI using gum join + gum style composed layout
status: To Do
assignee: []
created_date: '2026-04-03 15:01'
labels: []
dependencies:
  - TASK-36
references:
  - 'https://github.com/charmbracelet/gum#join'
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
After TASK-36 establishes stable transient-warning mechanics, this task redesigns the wizard's visual presentation using `gum style` + `gum join` to compose a structured, intentional layout — inspired by tools like Charm Crush that use side-by-side styled panels.

## Motivation

The current UI prints elements serially — banner, then warnings, then prompts — with no spatial relationship between them. The result is visually noisy and stateless: there's no persistent context panel showing what the user has already entered.

## Target layout

```
┌────────────────────────────────────────────────────────────┐
│  SNIPPET CLI  (banner — full width, gum style double border)│
└────────────────────────────────────────────────────────────┘
┌──────────────────────────┐  ┌─────────────────────────────┐
│  Context panel           │  │  Step panel                 │
│  Trigger:  :hi           │  │  Step 3 of 6                │
│  Type:     plaintext     │  │  Replacement                │
│  Vars:     name, city    │  │                             │
└──────────────────────────┘  └─────────────────────────────┘
[Warning box — full width, only rendered when active]
> gum prompt renders here naturally
```

The layout is a static pre-render that prints above the interactive gum prompt. It is cleared and redrawn on each wizard step transition.

## Key constraint

`gum input`, `gum filter`, `gum confirm`, and `gum write` are interactive TUI prompts that must render directly to the terminal — they cannot be captured and composed with `gum join`. Therefore `gum join` is used only for the static header/context area; the interactive prompt always renders below it.

## Implementation approach

### 1. Banner — convert to `gum style`
Replace the current hand-drawn Ruby string banner (`banner.rb`) with a `gum style` call:
```
gum style --border=double --padding="1 4" --border-foreground=212 "SNIPPET CLI"
```
This makes the banner consistent with the rest of the styled UI and removes the hardcoded `INNER_WIDTH` constant.

### 2. `UI.composed_header(context:, step:)` 
Builds the two-column header using `gum join --horizontal`:
- Left panel: context accumulated so far (trigger, type, vars) — rendered with `gum style`
- Right panel: current step label + step number — rendered with `gum style`
- Joined with `gum join --horizontal --align=top`
- Returns rendered string + line count (for clearing)

Example shell equivalent:
```bash
left=$(gum style --border=rounded --width=35 --padding="0 2" "Trigger: :hi\nType:    plaintext\nVars:    name, city")
right=$(gum style --border=rounded --width=30 --padding="0 2" "Step 3 / 6\nReplacement")
gum join --horizontal "$left" "$right"
```

### 3. `UI.render_wizard_frame(context:, step:, warning: nil)` → `line_count`
Prints banner + composed header + optional warning box. Returns total line count printed so caller can clear it.

### 4. `UI.clear_frame(line_count)`
Moves cursor up by `line_count` and clears screen down. Used between steps to redraw the frame.

### 5. Wizard integration
Each wizard step in `commands/new.rb`, `trigger_resolver.rb`, `var_builder.rb`:
1. Call `UI.render_wizard_frame(context: wizard_state, step: current_step)` 
2. Run gum prompt
3. Before next step: call `UI.clear_frame(line_count)`

### 6. `WizardState` struct (or plain hash)
A lightweight value object passed through the wizard to carry accumulated context for display:
```ruby
WizardState = Struct.new(:triggers, :type, :vars, :step, :total_steps)
```

## gum join reference
```bash
# Horizontal join (side by side)
gum join --horizontal [--align=top|middle|bottom] <blocks...>

# Vertical join (stacked)
gum join --vertical [--align=left|center|right] <blocks...>
```

## Files to change
- `lib/snippet_cli/banner.rb` — replace Ruby string art with `gum style` call
- `lib/snippet_cli/ui.rb` — add `composed_header`, `render_wizard_frame`, `clear_frame`
- `lib/snippet_cli/commands/new.rb` — thread `WizardState` through; call render/clear around each prompt
- `lib/snippet_cli/trigger_resolver.rb` — accept + update `WizardState`
- `lib/snippet_cli/var_builder.rb` — accept + update `WizardState`
- Possibly extract `lib/snippet_cli/wizard_state.rb`
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Banner renders via gum style (not raw Ruby string art) with a double border and accent color
- [ ] #2 Two-column composed header renders above each interactive prompt using gum join --horizontal
- [ ] #3 Left panel shows accumulated wizard context (triggers, type, vars) updated each step
- [ ] #4 Right panel shows current step label and step number
- [ ] #5 Header is cleared and redrawn cleanly between wizard steps (no leftover border artifacts)
- [ ] #6 Warning box (when present) renders full-width below the header, above the prompt
- [ ] #7 No regressions — all existing specs pass
- [ ] #8 Layout degrades gracefully when stdout is not a TTY (no gum join calls, plain text fallback)
<!-- AC:END -->
