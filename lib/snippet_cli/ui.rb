# frozen_string_literal: true

require 'gum'
require 'tty-cursor'

module SnippetCli
  module UI
    def self.info(text)
      gum_style(text, '--border=rounded', '--padding=0 4')
    end

    def self.hint(text)
      gum_style(text, '--border=rounded', '--padding=0 4', '--border-foreground=220')
    end

    def self.success(text)
      gum_style(text, '--border=rounded', '--padding=0 4', '--border-foreground=46', '--bold')
    end

    def self.warning(text)
      gum_style(text, '--border=rounded', '--padding=0 4', '--border-foreground=220', '--foreground=220', '--bold')
    end

    def self.error(text)
      gum_style(text, '--border=rounded', '--padding=0 4', '--border-foreground=196', '--foreground=196', '--bold')
    end

    # Renders a warning and returns a lambda that erases it via line-count tracking.
    # The warning is always rendered; the clear lambda is a no-op when not a TTY.
    def self.transient_warning(text)
      warning(text)
      erase_lambda(text.lines.count + 2)
    end

    # Renders an info box and returns a lambda that erases it via line-count tracking.
    # The info box is always rendered; the clear lambda is a no-op when not a TTY.
    def self.transient_info(text)
      info(text)
      erase_lambda(text.lines.count + 2)
    end

    def self.erase_lambda(line_count)
      return -> {} unless $stdout.tty?

      lambda {
        $stdout.print TTY::Cursor.up(line_count)
        $stdout.print "\r"
        $stdout.print TTY::Cursor.clear_screen_down
      }
    end
    private_class_method :erase_lambda

    def self.preview(text)
      gum_style(text, '--border=rounded', '--padding=0 4')
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
