---
id: TASK-33
title: 'feat: add discard-vars gate when image_path replacement type is selected'
status: Done
assignee: []
created_date: '2026-04-01 22:21'
updated_date: '2026-04-03 02:33'
labels:
  - ux
  - validation
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Vars are collected before the replacement type is chosen in `snippet new`. When a user selects `image_path`, the schema forbids `vars` — but the current flow silently includes them, generating confusing "unused var" warnings or producing invalid YAML.

Add a one-time confirmation gate: after the user selects `image_path` and has vars defined, show a warning and ask them to confirm discarding vars before continuing. If they decline, loop back to re-prompt the type selection. No restructuring of the vars flow needed.

## Implementation

Modify `collect_replacement` in `lib/snippet_cli/commands/new.rb` (lines 61–68). Wrap the alt-type selection in a loop and insert the gate when `image_path` is chosen with vars present:

```ruby
def collect_replacement(vars)
  if confirm!('Alternative (non-plaintext) replacement type?')
    loop do
      type = prompt!(Gum.filter('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type'))
      if type == 'image_path' && vars.any?
        UI.info('image_path replacements do not support vars — they will be discarded.')
        next unless confirm!('Discard vars and continue with image_path?')
        return collect_alt_with_check(:image_path, []).merge(vars: [])
      end
      return collect_alt_with_check(type.to_sym, vars)
    end
  else
    collect_replace_with_check(vars)
  end
end
```

`vars: []` is included in the return hash so `resolve_replacement`'s merge (line 58) overwrites the original vars. The loop allows the user to re-pick a non-image_path type if they decline the discard.

## Notes

- Schema already has a `not: { required: [vars] }` constraint for `image_path` — no schema changes needed.
- `UI.info` and `confirm!` are already used throughout this file for the same warning pattern.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 After selecting image_path with vars defined, a warning message is shown and user must confirm to discard vars
- [x] #2 Confirming the discard proceeds with image_path and vars are absent from the output YAML
- [x] #3 Declining the discard re-prompts the replacement type selection (loop back, not exit)
- [x] #4 When no vars are defined, image_path selection proceeds without any gate
- [x] #5 Tests added for: confirm-discard path (YAML has image_path, no vars) and decline-then-pick-other-type path (type filter shown twice)
- [x] #6 All existing image_path and vars specs continue to pass
<!-- AC:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented the discard-vars gate for `image_path` selection in `collect_replacement`. Wrapped the alt-type prompt in a loop; when `image_path` is chosen and vars are present, `UI.info` shows the warning and `confirm!` asks to discard — declining loops back to re-prompt the type filter, confirming returns `image_path` with `vars: []` overriding the original vars via the merge in `resolve_replacement`. Added 7 new specs covering: confirm-discard path (warning shown, YAML has image_path, no vars key), decline-then-pick-other-type path (filter called twice, markdown emitted), and no-gate path when no vars defined. All 61 examples pass.
<!-- SECTION:FINAL_SUMMARY:END -->
