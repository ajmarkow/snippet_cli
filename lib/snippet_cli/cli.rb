# frozen_string_literal: true

require 'thor'

module SnippetCli
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'snippet_cli version'
    def version
      require_relative 'version'
      puts "v#{SnippetCli::VERSION}"
    end
    map %w(--version -v) => :version

    desc 'setup', 'Creates Config for Using Tool to Add Snippets'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Set directory to write to snippet file in'
    def setup(*)
      if options[:help]
        invoke :help, ['setup']
      else
        require_relative 'commands/setup'
        SnippetCli::Commands::Setup.new().execute
      end
    end

  end
end