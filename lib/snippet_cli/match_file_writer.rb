# frozen_string_literal: true

module SnippetCli
  # Appends a generated snippet YAML string to an Espanso match file.
  # Uses string-level append (not YAML round-trip) to preserve formatting.
  module MatchFileWriter
    # Appends the snippet to the given file, indenting it by 2 spaces
    # to sit under the top-level `matches:` key.
    def self.append(file_path, snippet_yaml)
      existing = File.exist?(file_path) ? File.read(file_path) : ''
      needs_prefix = existing.strip.empty?

      indented = snippet_yaml.lines.map { |line| "  #{line}" }.join

      content = String.new
      content << "matches:\n" if needs_prefix
      content << existing unless needs_prefix
      content << indented
      content << "\n" unless content.end_with?("\n")

      File.write(file_path, content)
    end
  end
end
