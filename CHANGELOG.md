# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2026-09-15

### Added

- Installable Nix flake. `nix run github:ajmarkow/snippet_cli` runs the CLI without
  installing the gem, and `overlays.default` lets Nix users refer to `snippet_cli`
  by bare name in `environment.systemPackages` or `home.packages`.
- This changelog. The gemspec advertised a `changelog_uri` that pointed at a file
  which did not exist.

### Changed

- **Require Ruby 3.2 or newer.** The runtime dependencies already needed it, so the
  previous `>= 3.1.0` constraint let the gem install on a Ruby it could not run on.
  Narrowing supported Ruby is why this is a minor release rather than a patch.
  RubyGems resolves Ruby 3.1 users to 0.5.3, so they keep a working install.

## [0.5.3] - 2026-04-13

### Added

- Nix packaging: a `bundlerApp` derivation with a `gemConfig` patch that links the
  `gum` binary into the path the `gum` gem expects.

### Fixed

- Replaced an implicit `it` block parameter with an explicit one, which Ruby 3.4
  otherwise reinterprets.

## [0.5.2] - 2026-04-13

### Fixed

- Embedded the Espanso schema JSON under `lib/` so `check` resolves it from an
  installed gem rather than only from a source checkout.

## [0.5.1] - 2026-04-13

### Fixed

- Gemspec packaging correction for files missing from the published gem.

## [0.5.0] - 2026-04-13

### Changed

- Restricted `spec.files` to an explicit allowlist, so the gem ships only `lib/`,
  `exe/`, and the top-level README, CHANGELOG, and LICENSE.

[0.6.0]: https://github.com/ajmarkow/snippet_cli/compare/v0.5.3...v0.6.0
[0.5.3]: https://github.com/ajmarkow/snippet_cli/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/ajmarkow/snippet_cli/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/ajmarkow/snippet_cli/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/ajmarkow/snippet_cli/releases/tag/v0.5.0
