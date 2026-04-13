# snippet_cli
[![Gem Version](https://badge.fury.io/rb/snippet_cli.svg)](https://badge.fury.io/rb/snippet_cli)

snippet_cli is a gem for generating valid yaml configurations for snippets for the program Espanso.  Additionally, it includes a few espanso related utilities, like commands to check your matchfile for validity against the Espanso schema, or for conflicting triggers in your matchfile.

## Installation

Install it using command:

    $ sudo gem install snippet_cli

## Usage

TODO: Write usage instructions here

## Development

This project uses [devenv](https://devenv.sh) (Nix-based) for environment management. 

### First-time setup

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

### Releasing a new version

1. Update the version number in `lib/snippet_cli/version.rb`
2. Commit with the message containing `gem-release-ready` — CI will build and push the gem to RubyGems automatically once tests pass

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/snippet_cli. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/snippet_cli/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the SnippetCli project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/snippet_cli/blob/master/CODE_OF_CONDUCT.md).

## Copyright

Copyright (c) 2020 AJ Markow. See [MIT License](LICENSE.txt) for further details.
