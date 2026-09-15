# Updating the version

How to release a new version of snippet_cli. Follow these steps in order.

## Change exactly two files

| File                         | Change                                                             |
| ---------------------------- | ------------------------------------------------------------------ |
| `lib/snippet_cli/version.rb` | Set `VERSION` to the new number. This is the only source of truth. |
| `CHANGELOG.md`               | Add a section for the new version.                                 |

That is the whole edit. Do not change the version anywhere else.

## Never hand-edit these

These already derive the version. Editing them creates two sources of truth.

- `snippet_cli.gemspec` — reads `SnippetCli::VERSION`
- `lib/snippet_cli/commands/version.rb` — interpolates the constant
- `spec/commands/version_spec.rb` — asserts against the constant

These two are different. They pin the **published** gem, not the source:

- `nix/gemset.nix`
- `nix/Gemfile.lock`

They must stay on the **old** version while you release. The new gem does not exist
on RubyGems yet, so bundix cannot resolve it. CI repins them after publish. If you
bump them by hand, the build breaks.

## Choose the number

Follow [semantic versioning](https://semver.org), with one caveat: the spec exempts
`0.x` releases, where "anything MAY change at any time". While this gem is pre-1.0,
the rule below is convention rather than a requirement — but follow it anyway.

**Raising `required_ruby_version` is a minor bump, not a patch.** Treat any narrowing
of supported Ruby, Espanso schema, or platform the same way.

Nobody breaks when you do this. RubyGems enforces `required_ruby_version` while
resolving, so users on the dropped Ruby stay on the last version that supported them
and keep a working install. What they lose is future updates, silently. The minor
bump is what makes that visible, and it is what lets someone pinned at `~> 0.5.3` opt
in deliberately instead of being held back without knowing why.

## Steps

1. Branch off `master`. Name it `release/<version>`.
2. Set `VERSION` in `lib/snippet_cli/version.rb`.
3. Add a `CHANGELOG.md` section. Write it for users, not for the git log. Read the
   commits since the last tag to find what actually changed:
   ```bash
   git log --no-merges --pretty="%s" v<previous>..master
   ```
4. Run the suite:
   ```bash
   devenv shell -- bundle exec rake spec
   ```
   Compare the failure count against `master` before you assume you broke something.
   Some `spec/integration/cli_spec.rb` examples fail in a polluted local Bundler
   environment and pass in CI.
5. Commit and push the branch.
6. Open a PR against `master`. **Put `gem-release-ready` in the PR title.**
7. Wait for the required checks.
8. Squash-merge. Keep `gem-release-ready` in the squash commit message.

## Why the marker goes in the title

The `publish` job runs only when this is true:

```yaml
github.event_name == 'push' && github.ref == 'refs/heads/master'
&& contains(github.event.head_commit.message, 'gem-release-ready')
```

The `master` ruleset requires a pull request, so the push to `master` is the squash
commit. GitHub builds that commit message from the PR title. A marker in a branch
commit does not survive the squash. **No marker means no release.**

## What CI does

| Job             | When               | Purpose                                                        |
| --------------- | ------------------ | -------------------------------------------------------------- |
| `test`          | every push and PR  | rspec across Ruby 3.2–4.0 on Linux and macOS                   |
| `package`       | every push and PR  | installs the built gem and runs it outside the checkout        |
| `gemset-check`  | every push and PR  | compares the Nix pins to `version.rb`                          |
| `publish`       | marker on `master` | builds, pushes to RubyGems and GitHub Packages, tags, releases |
| `update-gemset` | after `publish`    | repins the Nix files and opens a PR                            |

## Expect `gemset-check` to pass with a notice

On a release PR, `version.rb` is ahead of `nix/gemset.nix`. That is correct, not a
failure. The job asks RubyGems whether the new version is published. It is not yet,
so the job treats it as a release in flight and passes:

```
::notice::version.rb is <version>, which RubyGems has not indexed yet.
Release in flight -- update-gemset repins after publish.
```

If it **fails** instead, the pins lag a version that is already published. That is
real drift. Regenerate them (see below).

## After the merge

`publish` pushes the gem, then `update-gemset` runs. It waits for RubyGems to index
the release, regenerates the Nix pins, and opens a `chore/repin-gemset-v<version>`
PR with auto-merge enabled. Confirm that PR lands.

Then verify:

```bash
gem list -r snippet_cli          # new version is on RubyGems
nix run github:ajmarkow/snippet_cli -- version
```

## Failure modes

**`update-gemset` times out.** It polls RubyGems for 10 minutes. If indexing is
slower, the job fails but the gem is already published. Rerun that job alone from
the Actions tab. Nothing is broken.

**Bundler resolves the wrong version.** `nix/Gemfile` pins `~> 0.5`, which stops
before 1.0. A major release falls outside it. The job detects this and fails rather
than repinning the wrong version. Widen the constraint in `nix/Gemfile`.

**`update-gemset` fails at checkout.** The `GEMSET_BOT_TOKEN` secret is missing or
expired. It must be a fine-grained PAT with Contents and Pull requests read/write.
`GITHUB_TOKEN` does not work here: GitHub does not start check runs for pull
requests it opens, so the required checks never report and auto-merge waits forever.

## Regenerating the Nix pins by hand

Only do this when `gemset-check` reports real drift, or when `update-gemset` failed
and you are cleaning up. The gem must already be on RubyGems.

```bash
nix develop --command bash -c "cd nix && bundle lock --update snippet_cli && bundix"
nix fmt nix/gemset.nix
```

Both lines matter. `--update snippet_cli` keeps unrelated transitive gems pinned.
`nix fmt` matches the checked-in formatting, because bundix emits compact lists.
Run together, they produce no drift when the pins are already correct.
