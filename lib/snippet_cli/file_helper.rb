# frozen_string_literal: true

module SnippetCli
  # Utility methods for safe file reading.
  module FileHelper
    # Checks that path exists. Raises FileMissingError if not.
    def self.ensure_readable!(path)
      raise FileMissingError, "File not found: #{path}" unless File.exist?(path)
    end

    # Returns the contents of path if it exists, or an empty string otherwise.
    def self.read_or_empty(path)
      File.exist?(path) ? File.read(path) : ''
    end
  end
end
