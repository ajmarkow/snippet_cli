# frozen_string_literal: true

require 'yaml'

module SnippetCli
  # Shared YAML file loading with existence check and syntax-error handling.
  module YamlLoader
    # Loads and parses a YAML file. Exits with an error message if the file
    # is missing or contains invalid YAML syntax.
    def self.load(path, permitted_classes: [Symbol])
      unless File.exist?(path)
        warn "File not found: #{path}"
        exit 1
      end
      YAML.safe_load_file(path, permitted_classes: permitted_classes) || {}
    rescue Psych::SyntaxError => e
      warn "Invalid YAML: #{e.message}"
      exit 1
    end
  end
end
