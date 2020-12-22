# frozen_string_literal: true

require_relative '../command'
require 'tty-markdown'
require 'tty-box'
require './lib/banner'

module SnippetCli
  module Commands
    class Info < SnippetCli::Command
      def initialize(docs, options)
        @docs = docs
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        puts show_banner()
        parsed_markdown=TTY::Markdown.parse_file('./lib/info.md')
        output.puts parsed_markdown
      end
    end
  end
end
