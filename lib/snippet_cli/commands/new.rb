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
        @file_path = "#{ENV["HOME"]}/ajstest.yml"
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
        def user_input_process()
          snippet_type = prompt.select("Do you want a Snippet or a Snippet with a form?") do |menu|
          menu.enum "."

          menu.choice "A snippet",1
          menu.choice "A snippet with a form",2 
          end

          puts @leading
          snippet_trigger=prompt.ask("What do you want to type to trigger the snippet?")
          puts @leading
          puts "Okay, the snippet will be triggered by:"
          prompt.ok( ":#{snippet_trigger}")
          puts@leading
          case snippet_type
            when 1
              but_first()

              replacement = prompt.multiline("what did you want the trigger to be replaced with?")
              if (replacement.length() > 1)
                single_snippet_export("#{ENV["HOME"]}/ajstest.yml",snippet_trigger,replacement)
              else
                single_snippet_export("#{ENV["HOME"]}/ajstest.yml",snippet_trigger,replacement[0])
              end
            when 2
              newprompt = TTY::Prompt.new
              newprompt.warn("For a form field wrap the word in double brackets.  Like {{example}}")
              puts @leading
              newprompt.ok("Also make sure the name of each form field is unique.")
              puts @leading
              replacement = prompt.multiline("what did you want the trigger to be replaced with?")
            if (replacement.length() > 1)
                input_form_snippet_export("#{ENV["HOME"]}/ajstest.yml",snippet_trigger,replacement)
              else
                input_form_snippet_export("#{ENV["HOME"]}/ajstest.yml",snippet_trigger,replacement[0])
              end
            end
        end

        puts "Let's add a new snippet to your configuration"
        puts @leading
        from_api = prompt.select("Did you want to pull a snippet from our Web API?", %w(API NO))
        puts from_api
        if (from_api == "NO") then
          puts "false"
          user_input_process()
        else (from_api == "API")
          def api_process()
            url = prompt.ask("What's the URL of the snippet?",default: "http://localhost:3000/snippets/1")
            puts url
          
            json_url = url+(".json")
            api_response=HTTParty.get(json_url)
            response_parsed = api_response.body
            puts response_parsed
            single_snippet_export(@file_path,response_parsed['trigger'],response_parsed['replacement'])
            puts prompt.ok("Added snippet at #{url}")
          end
          api_process()
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
