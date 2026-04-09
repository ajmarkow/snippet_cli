# frozen_string_literal: true

module SnippetCli
  # Utility methods for safe file reading.
  module FileHelper
    # Checks that path exists. Warns to stderr and exits 1 if not.
    def self.ensure_readable!(path)
      return if File.exist?(path)

      warn "File not found: #{path}"
      exit 1
    end

    # Returns the contents of path if it exists, or an empty string otherwise.
    def self.read_or_empty(path)
      File.exist?(path) ? File.read(path) : ''
    end
  end
end
