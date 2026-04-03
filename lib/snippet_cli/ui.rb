# frozen_string_literal: true

require 'gum'
require 'tty-cursor'

module SnippetCli
  module UI
    def self.info(text)
      gum_style(text, '--border=rounded', '--padding=0 1')
    end

    def self.hint(text)
      gum_style(text, '--border=rounded', '--padding=0 1', '--border-foreground=220')
    end

    def self.success(text)
      gum_style(text, '--border=rounded', '--padding=0 1', '--border-foreground=46', '--bold')
    end

    def self.warning(text)
      gum_style(text, '--border=rounded', '--padding=0 1', '--border-foreground=220', '--foreground=220', '--bold')
    end

    def self.error(text)
      gum_style(text, '--border=rounded', '--padding=0 1', '--border-foreground=196', '--foreground=196', '--bold')
    end

    # Saves the current cursor position and returns a lambda that restores it
    # and clears everything below — call it to erase a transient warning block.
    # Returns a no-op lambda when stdout is not a TTY (e.g. in tests).
    def self.cursor_checkpoint
      return -> {} unless $stdout.tty?

      $stdout.print "\r" # Ensure column 0 before saving
      $stdout.print TTY::Cursor.save
      lambda {
        $stdout.print TTY::Cursor.restore
        $stdout.print "\r" # Ensure column 0 before clearing
        $stdout.print TTY::Cursor.clear_screen_down
      }
    end

    def self.preview(text)
      gum_style(text, '--border=double', '--padding=0 1')
    end

    def self.format_code(text, language: 'yaml')
      Gum::Command.run_display_only('format', '--type=code', "--language=#{language}", input: text)
      puts
    rescue Gum::Error
      puts text
      puts
    end

    # Pass text via stdin instead of as a positional CLI argument.
    # Gum's arg parser interprets leading `-` characters (e.g. YAML list
    # markers like `- triggers:`) as unknown flags when passed positionally.
    def self.gum_style(text, *flags)
      result = Gum::Command.run_non_interactive('style', *flags, input: text)
      puts result
    end
    private_class_method :gum_style
  end
end
