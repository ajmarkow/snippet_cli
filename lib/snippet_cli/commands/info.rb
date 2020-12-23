# frozen_string_literal: true
require 'bundler/setup'
require_relative '../command'
require 'tty-markdown'
require 'tty-box'

module SnippetCli
  module Commands
    class Info < SnippetCli::Command
      def initialize(docs, options)
        @docs = docs
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
              def show_banner()
        box = TTY::Box::frame(width:67, height:11, border: :thick, align: :left) do 
        "
        #####   #     # ### ######  ######  ####### ####### 
        #     # ##    #  #  #     # #     # #          #    
        #       # #   #  #  #     # #     # #          #    
         #####  #  #  #  #  ######  ######  #####      #    
              # #   # #  #  #       #       #          #    
        #     # #    ##  #  #       #       #          #    
         #####  #     # ### #       #       #######    #    CLI                                                                
        "
        end
        puts box
      end
        puts show_banner()
        parsed_markdown=TTY::Markdown.parse_file('./lib/info.md')
        output.puts parsed_markdown
      end
    end
  end
end
