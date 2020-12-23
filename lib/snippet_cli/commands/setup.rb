require_relative '../command'
require 'tty-box'
require 'tty-prompt'
require 'tty-platform'
require './lib/banner'
# frozen_string_literal: true


module SnippetCli
  module Commands
    class Setup < SnippetCli::Command
      platform= TTY::Platform.new
      @leading = "                                      "
      attr_accessor :user_name,:config_path,:user_storage,:config_present,:os_choice
    
        def initialize()
          @user_name = user_name
          @config_path = config_path 
          @user_storage = user_storage
          @os_choice = os_choice  
          @config_present = config_present 
        end
    
        def get_name()
          puts @leading
          prompt = TTY::Prompt.new
            name = prompt.ask("⟶  To begin setup, may I have your name?", default: ENV["USER"], active_color: :bright_blue) do |q|
              q.required true
            end
          puts @leading
          self.user_name = name
        end
    
        def get_os()
          puts @leading
          puts "Checking what os you're using..."
            os_choice = platform.os()
              if (platform.windows? == true)
                 config_path = "#{ENV["HOMEPATH"]}\\AppData\\Roaming\\espanso\\default.yml"
              elsif (platform.mac? == true)
                 config_path = "#{ENV["HOME"]}/Library/Preferences/espanso/default.yml"
              else (platform.linux? == true)
                 config_path = "#{ENV["XDG_CONFIG_HOME"]}/espanso/default.yml"
              end
          puts @leading
          self.config_path=config_path
          self.os_choice = os_choice
          puts "We'll set the config path to:"
          puts @leading
          prompt.ok("#{config_path}")
  
        end
    
      # REFACTOR TO PROVIDE PATH
        def get_storage()
          puts @leading
          prompt = TTY::Prompt.new
          return snippet_storage = prompt.select("Do your store your snippets in Dropbox or a different directory?", default: 1, active_color: :bright_blue) do |menu|
          menu.enum "."
    
          menu.choice "No I use the default folder.", 1
          menu.choice "I use Dropbox.", 2
          menu.choice "I use Google Drive", 3
          menu.choice "I use Another Directory.", 4
          end
          puts @leading
          self.user_storage = snippet_storage
        end
    
      def generate_config()
        if File.exist?("#{ENV["HOMEPATH"]}\\snippet_cli_config.txt") && File.read("#{ENV["HOMEPATH"]}\\snippet_cli_config.txt").include?("CONFIG_PRESENT = TRUE")
        else
          File.open("#{ENV["HOMEPATH"]}/snippet_cli_config.txt", "a") { |f| f.write "NAME = #{self.user_name}\n"}
          File.open("#{ENV["HOMEPATH"]}/snippet_cli_config.txt", "a") { |f| f.write "#{self.config_path}\n"}
          File.open("#{ENV["HOMEPATH"]}/snippet_cli_config.txt", "a") { |f| f.write "CONFIG_PRESENT = TRUE\n"}
        end
      end

      def execute(input: $stdin, output: $stdout)
          show_banner()
          self.get_name()
          self.get_os()
          output.puts @leading
          output.puts "Thanks, that's all we need to know about your configuration."
          output.puts @leading
          output.puts @leading
          output.puts "You can now type snippet_cli new to get started."
          output.puts @leading
          self.generate_config()
      end
    end
  end
end
