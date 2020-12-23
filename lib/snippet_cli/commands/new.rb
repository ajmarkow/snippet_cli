# frozen_string_literal: true
require 'tty-box'
require 'tty-prompt'
require 'snippet_generator'
require 'httparty'
require './lib/banner'
require 'json'
# require 'snippets_for_espanso/SnippetGenerator'
require_relative '../command'


module SnippetCli
  module Commands
    class New < SnippetCli::Command
      include SnippetGenerator
      @leading = "                                      "
      
      prompt=TTY::Prompt.new
      def initialize(options)
        @options = options
        @file_path = File.readlines("#{ENV["HOMEPATH"]}/snippet_cli_config.txt")[1]
        puts @file_path
      end

      def but_first()
        puts @leading
        puts "Now you'll enter what you want replaced."
        puts @leading
        puts "But first ..."
        puts @leading
        prompt.error("Don't use tabs. YAML hates them and it leads to unpredictable results.")
        puts @leading
      end

      def new_form()
          puts "Let's add a new snippet to your configuration"
          puts @leading
          snippet_type = prompt.select("Do you want a Snippet or a Snippet with a form?") do |menu|
          menu.enum "."

          menu.choice "A snippet",1
          menu.choice "A snippet with a form",2 
          menu.choice "A snippet from Semplificato API",3
          end
          case snippet_type
            when 1
              puts @leading
              snippet_trigger=prompt.ask("What do you want to type to trigger the snippet?")
              puts @leading
              puts "Okay, the snippet will be triggered by:"
              prompt.ok( ":#{snippet_trigger}")
              puts@leading
              but_first()
              replacement = prompt.multiline("what did you want the trigger to be replaced with?")
              if (replacement.length() > 1)
                single_snippet_export(@file_path,snippet_trigger,replacement)
              else
                single_snippet_export(@file_path,snippet_trigger,replacement[0])
              end
            when 2
              puts @leading
              snippet_trigger=prompt.ask("What do you want to type to trigger the snippet?")
              puts @leading
              puts "Okay, the snippet will be triggered by:"
              prompt.ok( ":#{snippet_trigger}")
              puts@leading
              but_first()
              newprompt = TTY::Prompt.new
              newprompt.warn("For a form field wrap the word in double brackets.  Like {{example}}")
              puts @leading
              newprompt.ok("Also make sure the name of each form field is unique.")
              puts @leading
              replacement = prompt.multiline("what did you want the trigger to be replaced with?")
                if (replacement.length() > 1)
                  input_form_snippet_export(@file_path,snippet_trigger,replacement)
                else
                  input_form_snippet_export(@file_path,snippet_trigger,replacement[0])
                end
            when 3
              puts @leading
              url = prompt.ask("What's the URL of the snippet?",default: "http://localhost:3000/snippets/1")
              json_url = url+(".json")
              api_response=HTTParty.get(json_url)
              response_parsed = api_response.body
              single_snippet_export(@file_path,response_parsed['trigger'],response_parsed['replacement'])
              puts@leading
              prompt.ok("Added snippet from #{url}")
            end
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts show_banner()
        new_form()
      end
    end
  end
end
