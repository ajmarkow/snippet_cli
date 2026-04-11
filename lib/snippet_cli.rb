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
  class WizardInterrupted < StandardError; end

  # Raised by FileHelper when a required file does not exist.
  class FileMissingError < StandardError; end

  # Raised by YamlLoader when a file contains invalid YAML syntax.
  class InvalidYamlError < StandardError; end

  # Raised by TriggerResolver when mutually exclusive trigger flags are combined.
  class InvalidFlagsError < StandardError; end

  # Raised by WizardHelpers when no Espanso match files are found.
  class NoMatchFilesError < StandardError; end

  # When stdout is piped, holds the original stdout IO for structured output (YAML).
  # All UI continues through $stdout (redirected to the terminal).
  @pipe_output = nil

  class << self
    attr_accessor :pipe_output
  end

  module CLI
    extend Dry::CLI::Registry

    register 'version',  Commands::Version
    register 'conflict', Commands::Conflict, aliases: ['c']
    register 'vars',     Commands::Vars
    register 'new',      Commands::New,      aliases: ['n']
    register 'validate', Commands::Validate, aliases: ['v']
  end
end
