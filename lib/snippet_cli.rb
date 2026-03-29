# frozen_string_literal: true

require 'dry/cli'
require_relative 'snippet_cli/version'
require_relative 'snippet_cli/commands/version'
require_relative 'snippet_cli/commands/conflict'

module SnippetCli
  module CLI
    extend Dry::CLI::Registry

    register 'version', Commands::Version, aliases: ['v']
    register 'conflict', Commands::Conflict
  end
end
