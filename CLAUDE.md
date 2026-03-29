# Claude Code Instructions

## Ruby Version Management

This project uses [devenv](https://devenv.sh) (Nix-based) to manage the Ruby version and development environment. Do **not** suggest or use rbenv, rvm, asdf, or Homebrew Ruby for this project.

To enter the development environment:
```
devenv shell
```

To run a single command inside the devenv environment (without an interactive shell):
```
devenv shell -- <command>
```

For example: `devenv shell -- ruby --version`

The Ruby version is specified in `devenv.nix`. Currently targeting Ruby 4.0.

<!-- BACKLOG.MD MCP GUIDELINES START -->

<CRITICAL_INSTRUCTION>

## BACKLOG WORKFLOW INSTRUCTIONS

This project uses Backlog.md MCP for all task and project management activities.

**CRITICAL GUIDANCE**

- If your client supports MCP resources, read `backlog://workflow/overview` to understand when and how to use Backlog for this project.
- If your client only supports tools or the above request fails, call `backlog.get_backlog_instructions()` to load the tool-oriented overview. Use the `instruction` selector when you need `task-creation`, `task-execution`, or `task-finalization`.

- **First time working here?** Read the overview resource IMMEDIATELY to learn the workflow
- **Already familiar?** You should have the overview cached ("## Backlog.md Overview (MCP)")
- **When to read it**: BEFORE creating tasks, or when you're unsure whether to track work

These guides cover:
- Decision framework for when to create tasks
- Search-first workflow to avoid duplicates
- Links to detailed guides for task creation, execution, and finalization
- MCP tools reference

You MUST read the overview resource to understand the complete workflow. The information is NOT summarized here.

</CRITICAL_INSTRUCTION>

<!-- BACKLOG.MD MCP GUIDELINES END -->
