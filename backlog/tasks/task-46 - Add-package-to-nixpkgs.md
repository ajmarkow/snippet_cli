---
id: TASK-46
title: Add package to nixpkgs
status: To Do
assignee: []
created_date: '2026-04-06 20:35'
updated_date: '2026-04-09 22:49'
labels:
  - nix
dependencies: []
references:
  - >-
    https://github.com/nix-community/bundix
    https://fzakaria.com/2020/07/18/what-is-bundlerenv-doing
    https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/ruby.section.md#packaging-applications-packaging-applications
priority: low
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Package snippet_cli as a Ruby application and submit it to nixpkgs.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 gemset.nix generated via bundix and committed to repo
- [ ] #2 nix/default.nix written using bundlerApp with correct exes, meta, and gum in buildInputs
- [ ] #3 Local nix-build succeeds and snippet binary runs
- [ ] #4 PR opened to nixpkgs following by-name convention
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Phase 1 — Generate gemset.nix with bundix

bundix converts Gemfile.lock into a Nix-compatible `gemset.nix` that pins every gem's SHA256 hash.

```bash
# From project root inside devenv shell
bundix --lockfile=Gemfile.lock
```

This generates `gemset.nix` in the project root. Commit it alongside `Gemfile.lock` — both must stay in sync.

**Watch for:** gems with native C extensions (`json_schemer` pulls in `json-schema` and may need `pkg-config`/`openssl` in `buildInputs`). Run `bundle exec gem list` and cross-reference with nixpkgs to check for `buildInputs` requirements.

---

## Phase 2 — Write the nixpkgs derivation

Create `nix/default.nix` (or inline in a nixpkgs PR as `pkgs/tools/misc/snippet_cli/default.nix`):

```nix
{ lib, bundlerApp, bundlerUpdateScript }:

bundlerApp {
  pname = "snippet_cli";
  gemdir = ./.;               # directory containing gemset.nix + Gemfile.lock
  exes = [ "snippet" ];       # matches exe/ entrypoint

  passthru.updateScript = bundlerUpdateScript "snippet_cli";

  meta = with lib; {
    description = "Interactively build snippets for Espanso";
    homepage    = "https://github.com/ajmarkow/snippet_cli";
    license     = licenses.mit;
    maintainers = with maintainers; [ ];   # add your nixpkgs handle
    mainProgram = "snippet";
    platforms   = platforms.unix;
  };
}
```

Key points:
- `bundlerApp` (not `bundlerEnv`) is correct for CLI tools with a single binary
- `gemdir` must contain `gemset.nix`, `Gemfile`, and `Gemfile.lock`
- `gum` is a runtime dependency — it must be in `PATH` at runtime. Check if the `gum` Ruby gem shells out to the `gum` binary; if so, add `pkgs.gum` to `buildInputs`

---

## Phase 3 — Test locally

```bash
nix-build -E 'with import <nixpkgs> {}; callPackage ./nix/default.nix {}'
./result/bin/snippet --help
```

Or with flakes:
```bash
nix build .#snippet_cli
```

---

## Phase 4 — Submit to nixpkgs

1. Fork nixpkgs, place derivation at `pkgs/by-name/sn/snippet-cli/package.nix` (new `by-name` convention)
2. Add entry to `pkgs/top-level/all-packages.nix`: `snippet-cli = callPackage ../by-name/sn/snippet-cli/package.nix { };`
3. Run nixpkgs CI checks: `nix-build -A snippet-cli`
4. Open PR following the nixpkgs contributing guide — title: `snippet-cli: init at x.y.z`

---

## Native extension audit (runtime deps)

| Gem | Native ext? | Notes |
|---|---|---|
| dry-cli | No | Pure Ruby |
| gum | No | Shells out to `gum` binary |
| json_schemer | Yes (via `regexp_parser`) | May need nothing extra; check nixpkgs |
| tty-cursor | No | Pure Ruby |

The `gum` gem wrapping the `gum` binary means `pkgs.gum` must be in the derivation's `buildInputs` or available on `PATH` at runtime.
<!-- SECTION:PLAN:END -->
