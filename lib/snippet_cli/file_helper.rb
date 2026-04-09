# frozen_string_literal: true

module SnippetCli
  # Utility methods for safe file reading.
  module FileHelper
    # Returns the contents of path if it exists, or an empty string otherwise.
    def self.read_or_empty(path)
      File.exist?(path) ? File.read(path) : ''
    end
  end
end
