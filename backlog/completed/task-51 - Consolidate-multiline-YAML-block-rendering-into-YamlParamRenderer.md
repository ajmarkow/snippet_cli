---
id: TASK-51
title: Consolidate multiline YAML block rendering into YamlParamRenderer
status: Done
assignee: []
created_date: '2026-04-08 21:04'
updated_date: '2026-04-09 20:39'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The multiline YAML block rendering pattern appears with slight variations in `snippet_builder.rb:47-54`, `yaml_param_renderer.rb:24-31`, and `var_builder/params.rb:71-75`. Consolidate into a single method in `YamlParamRenderer`.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Made `YamlParamRenderer.scalar_lines` public, then reduced `SnippetBuilder.block_scalar_lines` to a one-liner delegate: `YamlParamRenderer.scalar_lines(key, val, '  ')`. Added `spec/yaml_param_renderer_spec.rb` covering both single-line and multiline paths. All 551 tests pass.
<!-- SECTION:FINAL_SUMMARY:END -->
