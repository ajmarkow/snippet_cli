# frozen_string_literal: true

require_relative 'file_helper'
require_relative 'string_helper'

module SnippetCli
  # Appends a generated snippet YAML string to an Espanso match file.
  # Uses string-level append (not YAML round-trip) to preserve formatting.
  module MatchFileWriter
    # Appends the snippet to the given file, indenting it by 2 spaces
    # to sit under the top-level `matches:` key.
    def self.append(file_path, snippet_yaml)
      existing = FileHelper.read_or_empty(file_path)
      indented = snippet_yaml.lines.map { |line| "  #{line}" }.join
      content = build_content(existing, indented)
      File.write(file_path, content)
    end

    def self.build_content(existing, indented)
      prefix = existing.strip.empty? ? "matches:\n" : StringHelper.ensure_trailing_newline(existing)
      StringHelper.ensure_trailing_newline("#{prefix}#{indented}")
    end
    private_class_method :build_content
  end
end
