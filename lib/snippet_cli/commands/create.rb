# frozen_string_literal: true
require 'tty-box'
require 'tty-prompt'
require_relative '../command'

module SnippetCli
  module Commands
    class Create < SnippetCli::Command
      @leading = "                                      "
      prompt=TTY::Prompt.new
      def initialize(options)
        @options = options
      end

      def show_banner()
        box = TTY::Box::frame(width:80, height:11, border: :thick, align: :left) do 
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

      def create_form()
        puts "Let's add a new snippet to your configuration"
        puts @leading
        choices = {"A snippet":1, "A snippet with a form":2}
        snippet_type = prompt.select("Do you want a Snippet or a Snippet with a form?", choices)
        puts snippet_type
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts show_banner()
        create_form()
      end
    end
  end
end
