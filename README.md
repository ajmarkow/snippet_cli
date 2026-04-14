# snippet_cli
[![Gem Version](https://badge.fury.io/rb/snippet_cli.svg)](https://badge.fury.io/rb/snippet_cli)

snippet_cli is a gem for generating valid yaml configurations for snippets for the program Espanso.  Additionally, it includes a few espanso related utilities, like commands to check your matchfile for validity against the Espanso schema, or for conflicting triggers in your matchfile.
## Features

### Interactive Snippet Builder
- Designed to make adding complex snippets to your Espanso config completely painless (`new` command).
- Handles quoting, escaping, and multiline replacements for you.
- Supports `trigger`, `triggers`, or `regex` for snippet matching.
- Supports all replacement types: `replace`, `markdown`, `html`, `image_path`.
- Supports advanced snippet options: `label`, `comment`, `search_terms`, and `word` trigger.
- Offers `--no-vars` and `--bare` flags on `new` for defining simpler snippets without the variable builder or advanced options.
   - `--no-vars` - Snippet builder without variables.
   - `--bare` - Bare-bones snippet builder with just basic trigger and replace types.

### Interactive Variable Builder
- Offers an interactive variable builder to define as many variables as you'd like.
  - Can be invoked separately (`vars` command) to add variables to the `global_vars` array in your config.
  - Supports the following variable types: `echo`, `random`, `choice`, `date`, `shell`, `script`, `form`, `clipboard`.
  - No guessing at parameters or double-checking schema, asks for all required fields and prompts for optional ones if you choose to set them.
- Defined variables are shown as you enter your snippet text for easy reference.
  - Warns you if you forgot to use a variable or referenced an undefined one.
- Allows you to re-order variables after defining them.


### Config Integration
- Automatically uses the Espanso default config path for appending variables or snippets to your match file(s).
  - If you have multiple match files, the wizard will ask which one to append to.
- Supports piped output if you don't want to save directly to a match file. Use `--save` / `-s` to append directly.

### Utilities
- Validate a match file against the Espanso schema (`check` command).
- Detect duplicate triggers in a match file (`conflict` command).

## Commands
<details>
<Summary>More Info</Summary>

| Command | Alias | Description |
|---|---|---|
|  new | n | Interactively build and optionally save to your match file|
|  vars | v | Interactively build a vars block and optionally save it to global_vars |
|  check | k | Validate a match file against the Espanso schema |
|  conflict | c | Detect duplicate triggers in a match file |
|  version | — | Print the current version |
</details>

### Flags
<details>
<Summary>More Info</Summary>

| Flag | Alias | Commands | Description |
|------|-------|---------|-------------|
| `--save` | `-s` | `new`, `vars` | Save output to match file |
| `--no-vars` | `-n` | `new` | Skip variable builder; still offers alt types and advanced options |
| `--bare` | `-b` | `new` | Trigger(s) + plaintext only; no vars, alt types, or advanced |
| `--file` | `-f` | `check`, `conflict` | Path to match file |
| `--trigger` | `-t` | `conflict` | Trigger(s) to look up (comma-separated or repeated) |
</details>
 
## Installation

Install it using command:

    $ sudo gem install snippet_cli

## Development

> [!NOTE]
> This project uses [devenv](https://devenv.sh) (Nix-based) for environment management. 

### First-time setup
<details>
<Summary>Devenv Install Instructions</Summary>

1. [Install Nix](https://nixos.org/download) and [devenv](https://devenv.sh/getting-started/)
2. Clone the repo:
   ```bash
   git clone https://github.com/ajmarkow/snippet_cli.git
   cd snippet_cli
   ```
3. Enter the development environment:
   ```bash
   devenv shell
   ```
4. Install dependencies:
   ```bash
   bundle install
   ```
5. Run the tests to verify everything works:
   ```bash
   bundle exec rake spec
   ```
</details>

### Releasing a new version
<details>
<Summary> Instructions </Summary>

1. Update the version number in `lib/snippet_cli/version.rb`
2. Commit with the message containing `gem-release-ready` — CI will build and push the gem to RubyGems automatically once tests pass

</details>

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/snippet_cli. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/snippet_cli/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the SnippetCli project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/snippet_cli/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2020 AJ Markow. See [MIT License](LICENSE.txt) for further details.
