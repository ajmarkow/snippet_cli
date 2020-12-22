# frozen_string_literal: true
require 'tty-box'
require 'tty-prompt'
require 'snippet_generator'
# require 'snippets_for_espanso/SnippetGenerator'
require_relative '../command'


module SnippetCli
  module Commands
    class Create < SnippetCli::Command
      include SnippetGenerator
      @leading = "                                      "
      
      prompt=TTY::Prompt.new
      def initialize(options)
        @options = options
        @file_path = "~/ajstest.yml"
      end

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

      def create_form()
        puts "Let's add a new snippet to your configuration"
        puts @leading
        choices = {"A snippet":1, "A snippet with a form":2}
        snippet_type = prompt.select("Do you want a Snippet or a Snippet with a form?", choices)
        puts @leading
        snippet_trigger=prompt.ask("What do you want to type to trigger the snippet?")
        puts @leading
        puts "Okay, the snippet will be triggered by:"
        prompt.ok( ":#{snippet_trigger}")
        case snippet_type
          when 1
            puts @leading
            puts "Now you'll enter what you want replaced."
            puts @leading
            puts "But first ..."
            puts @leading
            puts prompt.error("Don't use tabs. YAML hates them and it leads to unpredictable results.")
            puts @leading
            replacement = prompt.multiline("what did you want the trigger to be replaced with?")
            if (replacement.length() > 1)
              single_snippet_export("#{ENV["HOME"]}/ajstest.yml",snippet_trigger,replacement)
            else
              single_snippet_export("#{ENV["HOME"]}/ajstest.yml",snippet_trigger,replacement[0])
            end
          when 2
            puts "hit case 2"
          end
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts show_banner()
        create_form()
      end
    end
  end
end
