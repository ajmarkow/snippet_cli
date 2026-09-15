# Agent instructions

Facts specific to this repo. General working preferences live in your global config,
not here.

## Ruby and the dev environment

This project uses [devenv](https://devenv.sh) (Nix-based) to manage Ruby and the
development environment. Do **not** suggest or use rbenv, rvm, asdf, or Homebrew Ruby.

```bash
devenv shell                 # interactive
devenv shell -- <command>    # one-off
```

The Ruby version is set in `devenv.nix`. It currently targets Ruby 4.0. The gem
itself supports Ruby 3.2 and newer (`required_ruby_version` in the gemspec), and CI
tests that whole range.

## Releasing a new version

**Read [`docs/updating-version.md`](docs/updating-version.md) before changing the
version.** Do not improvise a release.

The three things that trip agents up:

1. Only `lib/snippet_cli/version.rb` and `CHANGELOG.md` change. The gemspec, the
   `version` command, and its spec all read `SnippetCli::VERSION`.
2. `nix/gemset.nix` and `nix/Gemfile.lock` pin the **published** gem. They stay on
   the old version during a release. CI repins them after publish.
3. `gem-release-ready` must be in the **pull request title**, not a commit message.
   `master` requires a PR, so the squash commit message comes from the PR title, and
   that is what triggers `publish`.

## Nix packaging

`nix/default.nix` is a `bundlerApp` derivation that installs the published gem from
RubyGems. It does not build from the working tree, so source changes do not appear in
the Nix package until the gem is released and the pins are regenerated.

The `gum` gem ships its binary in a platform-specific directory. The derivation
patches around this by symlinking `pkgs.gum` into the expected path. If `gum` changes
its layout, that patch in `nix/default.nix` is what breaks.

Verify packaging changes with `nix flake check --no-build`. Do not run a full build
just to prove the package installs.

## Tests

```bash
devenv shell -- bundle exec rake spec
```

Some `spec/integration/cli_spec.rb` examples spawn a subprocess through aruba. They
fail in a polluted local Bundler environment and pass in CI. Always compare the
failure count against `master` before assuming a change broke them.
