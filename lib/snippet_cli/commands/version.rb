# frozen_string_literal: true

require 'dry/cli'
require_relative '../version'

module SnippetCli
  module Commands
    class Version < Dry::CLI::Command
      desc 'Print snippet_cli version'

      def call(**)
        puts SnippetCli::VERSION
      end
    end
  end
end
