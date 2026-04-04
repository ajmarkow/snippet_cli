# frozen_string_literal: true

require 'dry/cli'
require_relative 'snippet_cli/version'
require_relative 'snippet_cli/commands/version'
require_relative 'snippet_cli/commands/conflict'
require_relative 'snippet_cli/commands/vars'
require_relative 'snippet_cli/commands/new'
require_relative 'snippet_cli/commands/validate'

module SnippetCli
  # Raised when any Gum prompt is cancelled by Ctrl+C.
  class WizardInterrupted < StandardError
  end

  # When stdout is piped, holds the original stdout IO for structured output (YAML).
  # All UI continues through $stdout (redirected to the terminal).
  @pipe_output = nil

  class << self
    attr_accessor :pipe_output
  end

  module CLI
    extend Dry::CLI::Registry

    register 'version',  Commands::Version,  aliases: ['v']
    register 'conflict', Commands::Conflict, aliases: ['c']
    register 'vars',     Commands::Vars,     aliases: ['va']
    register 'new',      Commands::New,      aliases: ['n']
    register 'validate', Commands::Validate, aliases: ['vl']
  end
end
