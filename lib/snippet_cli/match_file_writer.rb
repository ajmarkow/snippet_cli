# frozen_string_literal: true

require_relative 'file_helper'

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
      content = String.new
      if existing.strip.empty?
        content << "matches:\n"
      else
        content << existing
        content << "\n" unless existing.end_with?("\n")
      end
      content << indented
      content << "\n" unless content.end_with?("\n")
      content
    end
    private_class_method :build_content
  end
end
