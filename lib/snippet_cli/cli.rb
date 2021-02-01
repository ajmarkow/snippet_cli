# frozen_string_literal: true

require 'thor'

module SnippetCli
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
  def self.exit_on_failure?
    true
    puts "Something went wrong, try again."
  end
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'snippet_cli version'
    def version
      require_relative 'version'
      puts "v#{SnippetCli::VERSION}"
    end
    map %w(--version -v) => :version

    desc 'info [DOCS]', 'Show info and docs about using the program.'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Shows you where you can find more documentation and leave feedback for the program.'
    def info(docs = nil)
      if options[:help]
        invoke :help, ['info']
      else
        require_relative 'commands/info'
        SnippetCli::Commands::Info.new(docs, options).execute
      end
    end

    desc 'new', 'Guides you through adding a new snippet.'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Adds a new snippet to your yml file.'
    def new(*)
      if options[:help]
        invoke :help, ['new']
      else
        require_relative 'commands/new'
        SnippetCli::Commands::New.new(options).execute
      end
    end

    desc 'setup', 'Sets up snippet_cli to modify correct file.'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Sets directory to write to snippet file in.'
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
