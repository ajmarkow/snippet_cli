# frozen_string_literal: true

require 'tty-cursor'

module SnippetCli
  # Utility for TTY cursor manipulation.
  module CursorHelper
    # Returns a lambda that erases `line_count` lines upward when called.
    # Returns a no-op lambda when stdout is not a TTY.
    def self.build_erase_lambda(line_count)
      return -> {} unless $stdout.tty?

      lambda {
        $stdout.print TTY::Cursor.up(line_count)
        $stdout.print "\r"
        $stdout.print TTY::Cursor.clear_screen_down
      }
    end
  end
end
