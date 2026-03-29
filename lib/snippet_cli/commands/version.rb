# frozen_string_literal: true

require 'dry/cli'
require_relative '../version'

module SnippetCli
  module Commands
    class Version < Dry::CLI::Command
      desc 'Print snippet_cli version (alias: v)'

      def call(**)
        label = "  VERSION #{SnippetCli::VERSION}  "
        bar   = '═' * label.length
        puts "╔#{bar}╗"
        puts "║#{label}║"
        puts "╚#{bar}╝"
      end
    end
  end
end
