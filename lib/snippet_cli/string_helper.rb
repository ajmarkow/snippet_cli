# frozen_string_literal: true

module SnippetCli
  # Utility methods for string manipulation.
  module StringHelper
    # Returns str with a trailing newline, appending one if not already present.
    def self.ensure_trailing_newline(str)
      str.end_with?("\n") ? str : "#{str}\n"
    end
  end
end
