# frozen_string_literal: true

require 'dry/cli'
require_relative 'snippet_cli/version'
require_relative 'snippet_cli/commands/version'

module SnippetCli
  module CLI
    extend Dry::CLI::Registry

    register 'version', Commands::Version, aliases: ['v']
  end
end
