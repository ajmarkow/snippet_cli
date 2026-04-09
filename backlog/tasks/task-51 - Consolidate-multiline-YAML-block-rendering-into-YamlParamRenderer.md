---
id: TASK-51
title: Consolidate multiline YAML block rendering into YamlParamRenderer
status: To Do
assignee: []
created_date: '2026-04-08 21:04'
labels:
  - refactor
  - dry
dependencies: []
priority: medium
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The multiline YAML block rendering pattern appears with slight variations in `snippet_builder.rb:47-54`, `yaml_param_renderer.rb:24-31`, and `var_builder/params.rb:71-75`. Consolidate into a single method in `YamlParamRenderer`.
<!-- SECTION:DESCRIPTION:END -->
