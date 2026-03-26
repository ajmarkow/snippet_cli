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
