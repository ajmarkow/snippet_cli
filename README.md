# snippet_cli

![Gem Total Downloads](https://img.shields.io/gem/dt/snippet_cli) ![Gem Version](https://img.shields.io/gem/v/snippet_cli)

A CLI gem for generating valid YAML snippet configs for [Espanso](https://espanso.org), with utilities to validate match files and detect conflicting triggers.

![snippet_cli demo](https://raw.githubusercontent.com/ajmarkow/snippet_cli/83dc3016f88e7f1e4862d7a0eb166ef4e456a6c2/assets/snippet.gif)

> [!TIP]
> To get started, run `snippet_cli new --save` to build a snippet interactively and append it directly to your config file.

## Installation

Needs Ruby 3.1 or newer.

| Platform                        | Supported |
| ------------------------------- | --------- |
| macOS (Apple Silicon and Intel) | Yes       |
| Linux (`x86_64`, `arm64`)       | Yes       |
| Windows                         | No        |

`snippet_cli` drives its prompts with [`gum`](https://github.com/charmbracelet/gum),
which ships as a platform-specific gem. No Windows build of that gem is published,
so Windows is not supported. WSL works, since it installs the Linux build.

### RubyGems

```bash
gem install snippet_cli
```

### Nix

The flake builds `snippet_cli` and every gem it needs against a pinned Ruby, and
wires up the [`gum`](https://github.com/charmbracelet/gum) binary for you. Nothing
is written to `~/.gem`, so the install cannot break when your system Ruby changes.

<details>
<summary><b>Run it without installing</b> — <code>nix run</code></summary>

Try the latest release straight from GitHub:

```bash
nix run github:ajmarkow/snippet_cli
```

Pass arguments after `--`:

```bash
nix run github:ajmarkow/snippet_cli -- new --save
nix run github:ajmarkow/snippet_cli -- check ~/.config/espanso/match/base.yml
```

</details>

<details>
<summary><b>Install into your profile</b> — <code>nix profile add</code></summary>

```bash
nix profile add github:ajmarkow/snippet_cli
```

On Nix older than 2.30, the subcommand is `install` instead of `add`:

```bash
nix profile install github:ajmarkow/snippet_cli
```

Then upgrade or remove it with:

```bash
nix profile upgrade snippet_cli
nix profile remove snippet_cli
```

</details>

<details>
<summary><b>Add it to your system config</b> — flake input, Home Manager, or NixOS</summary>

Add the flake as an input:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    snippet_cli.url = "github:ajmarkow/snippet_cli";
  };
}
```

Then add the package where you need it — Home Manager:

```nix
home.packages = [ inputs.snippet_cli.packages.${pkgs.system}.default ];
```

…or NixOS:

```nix
environment.systemPackages = [ inputs.snippet_cli.packages.${pkgs.system}.default ];
```

</details>

<details>
<summary><b>Build from a local checkout</b></summary>

```bash
git clone https://github.com/ajmarkow/snippet_cli
cd snippet_cli
nix build .#snippet_cli   # result appears at ./result/bin/snippet_cli
nix run .#snippet_cli -- version
```

Flakes only see files tracked by git, so `git add` any new file before building.

</details>

> [!NOTE]
> The Nix commands above need flakes enabled. If your Nix predates flakes being
> on by default, prefix them with
> `--extra-experimental-features 'nix-command flakes'`.

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

<details open>
<summary>More Info</summary>

| Command    | Alias | Description                                                            |
| ---------- | ----- | ---------------------------------------------------------------------- |
| `new`      | `n`   | Interactively build and optionally save to your match file             |
| `vars`     | `v`   | Interactively build a vars block and optionally save it to global_vars |
| `check`    | `k`   | Validate a match file against the Espanso schema                       |
| `conflict` | `c`   | Detect duplicate triggers in a match file                              |
| `version`  | —     | Print the current version                                              |

</details>

### Flags

<details>
<summary>More Info</summary>

| Flag        | Alias | Commands            | Description                                                        |
| ----------- | ----- | ------------------- | ------------------------------------------------------------------ |
| `--save`    | `-s`  | `new`, `vars`       | Save output to match file                                          |
| `--no-vars` | `-n`  | `new`               | Skip variable builder; still offers alt types and advanced options |
| `--bare`    | `-b`  | `new`               | Trigger(s) + plaintext only; no vars, alt types, or advanced       |
| `--file`    | `-f`  | `check`, `conflict` | Path to match file                                                 |
| `--trigger` | `-t`  | `conflict`          | Trigger(s) to look up (comma-separated or repeated)                |
| `--help`    | `-h`  | all                 | Show help info for commands                                        |

</details>

---

## Development

> [!NOTE]
> This project uses [devenv](https://devenv.sh) (Nix-based) for environment management. Use `devenv shell` for local development.

### First-time setup

<details>
<summary>Devenv Install Instructions</summary>

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
<summary>Instructions</summary>

1. Update the version number in `lib/snippet_cli/version.rb`
2. Commit with the message containing `gem-release-ready` — CI will build and push the gem to RubyGems automatically once tests pass

</details>

### Additional Info

<details>
<summary>Contributing, Code of Conduct</summary>

#### Contributing

Bug reports and pull requests are welcome on GitHub at [ajmarkow/snippet_cli](https://github.com/ajmarkow/snippet_cli). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ajmarkow/snippet_cli/blob/master/CODE_OF_CONDUCT.md).

#### Code of Conduct

Everyone interacting in the SnippetCli project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ajmarkow/snippet_cli/blob/master/CODE_OF_CONDUCT.md).

</details>
