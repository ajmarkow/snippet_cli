require 'tty/prompt'
require 'tty/box'
prompt = TTY::Prompt.new


class Setup
  @leading = "                                      "
  @divider = "------------------------------------"
  attr_accessor :user_name,:user_os,:user_storage,:config_present

    def initialize(user_name,user_os,user_storage,config_present)
      @user_name = user_name
      @user_os = user_os 
      @user_storage = user_storage 
      @config_present = config_present 
    end

    class Error < StandardError; end


    def get_name()
      puts @leading
      prompt = TTY::Prompt.new
        name = prompt.ask("To begin setup, may I have your name?", default: ENV["USER"], active_color: :bright_blue) do |q|
          q.required true
        end
      puts @leading
      self.user_name = name
    end

    def get_os()
      puts @leading
      prompt = TTY::Prompt.new
          config_path = prompt.ask("What OS are you using?", default: ENV["OS"], active_color: :bright_blue) do |q|
            q.required true
          end
          if (config_path.include? "Windows")
            return config_path = "\\Roaming\\AppData\\espanso\\default.yml"
          elsif (config_path.include?"OS X")
            return config_path = "$HOME/Library/Preferences/espanso/default.yml"
          else config_path.include?("Linux")
            return config_path = "$XDG_CONFIG_HOME/espanso/default.yml"
          end
      puts @leading
      self.user_os=config_path
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
    if File.exist?("./snippet_cli_config.txt") then

    else
      File.open("./snippet_cli_config.txt", "a") { |f| f.write "NAME = #{self.user_name}\n"}
      File.open("./snippet_cli_config.txt", "a") { |f| f.write "OS = #{self.user_os}\n"}
      File.open("./snippet_cli_config.txt", "a") { |f| f.write "STORAGE = #{self.user_storage}\n"}
      File.open("./snippet_cli_config.txt", "a") { |f| f.write "CONFIG_PRESENT = TRUE\n"}
    end
  end
end