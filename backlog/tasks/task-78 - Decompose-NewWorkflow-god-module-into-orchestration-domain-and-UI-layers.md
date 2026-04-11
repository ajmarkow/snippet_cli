---
id: TASK-78
title: 'Decompose NewWorkflow god module into orchestration, domain, and UI layers'
status: To Do
assignee: []
created_date: '2026-04-11 15:47'
labels:
  - architecture
  - refactor
dependencies: []
priority: high
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
NewWorkflow (`lib/snippet_cli/new_workflow.rb`) mixes three distinct responsibilities in a single module: orchestration (preparing context, building snippet, delivering output), domain logic (YAML assembly, replacement type resolution), and UI/presentation (confirmation prompts, error display). Every new feature addition requires modifying this file, increasing regression risk and cognitive load. It is the primary bottleneck for change in the codebase.

The goal is to separate concerns so that domain logic can be tested without UI, and orchestration is a thin coordinator of well-defined collaborators.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Domain logic (replacement type resolution, YAML context assembly) lives in a class/module with no direct Gum/UI calls
- [ ] #2 UI interactions (confirmations, prompts) are delegated to a presenter or wizard class rather than living inline in the workflow
- [ ] #3 NewWorkflow (or its replacement) is a thin orchestrator: it sequences collaborators but contains no business rules itself
- [ ] #4 All existing behavior is preserved — existing specs pass without modification to test expectations
<!-- AC:END -->
