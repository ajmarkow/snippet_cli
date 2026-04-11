# frozen_string_literal: true

require 'dry/cli'
require_relative '../version'
require_relative '../ui'

module SnippetCli
  module Commands
    class Version < Dry::CLI::Command
      desc 'Print snippet_cli version'

      def call(**)
        UI.info("snippet_cli v#{SnippetCli::VERSION}")
      end
    end
  end
end
