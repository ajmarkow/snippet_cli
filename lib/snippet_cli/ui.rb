# frozen_string_literal: true

require 'gum'
require_relative 'cursor_helper'

module SnippetCli
  module UI
    BASE_FLAGS = ['--border=rounded', '--padding=0 4'].freeze
    PROMPT_STYLE = { padding: '0 1', margin: '0' }.freeze

    STYLE_FLAGS = {
      info: [],
      hint: ['--border-foreground=220'],
      success: ['--border-foreground=46', '--bold'],
      warning: ['--border-foreground=220', '--foreground=220', '--bold'],
      error: ['--border-foreground=196', '--foreground=196', '--bold'],
      preview: []
    }.freeze

    def self.note(text)
      puts "\e[38;5;231m#{text}\e[0m"
    end

    def self.info(text)    = gum_style(text, *STYLE_FLAGS[:info])
    def self.hint(text)    = gum_style(text, *STYLE_FLAGS[:hint])
    def self.success(text) = gum_style(text, *STYLE_FLAGS[:success])
    def self.warning(text) = gum_style(text, *STYLE_FLAGS[:warning])
    def self.error(text)   = gum_style(text, *STYLE_FLAGS[:error])
    def self.preview(text) = gum_style(text, *STYLE_FLAGS[:preview])

    # Renders a warning and returns a lambda that erases it via line-count tracking.
    # The warning is always rendered; the clear lambda is a no-op when not a TTY.
    def self.transient_note(text)
      puts "\e[38;5;231m #{text}\e[0m"
      puts
      erase_lambda(2)
    end

    def self.transient_warning(text)
      warning(text)
      erase_lambda(text.lines.count + 2)
    end

    def self.transient_error(text)
      error(text)
      erase_lambda(text.lines.count + 2)
    end

    # Renders an info box and returns a lambda that erases it via line-count tracking.
    # The info box is always rendered; the clear lambda is a no-op when not a TTY.
    def self.transient_info(text)
      info(text)
      erase_lambda(text.lines.count + 2)
    end

    def self.erase_lambda(line_count)
      CursorHelper.build_erase_lambda(line_count)
    end
    private_class_method :erase_lambda

    def self.format_code(text, language: 'yaml')
      Gum::Command.run_display_only('format', '--type=code', "--language=#{language}", input: text)
      puts
    rescue Gum::Error
      puts text
      puts
    end

    # Delivers YAML output: pipes to stdout if piped, or displays with a label if interactive.
    # context must respond to #pipe_output (nil = interactive mode).
    def self.deliver(yaml, label:, context: nil)
      pipe = context&.pipe_output
      if pipe
        pipe.print yaml
      else
        info("#{label} YAML below.")
        format_code(yaml)
      end
    end

    # Pass text via stdin instead of as a positional CLI argument.
    # Gum's arg parser interprets leading `-` characters (e.g. YAML list
    # markers like `- triggers:`) as unknown flags when passed positionally.
    def self.gum_style(text, *extra_flags)
      result = Gum::Command.run_non_interactive('style', *BASE_FLAGS, *extra_flags, input: text)
      puts result
    end
    private_class_method :gum_style
  end
end
