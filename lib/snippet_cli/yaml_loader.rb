# frozen_string_literal: true

require 'yaml'
require_relative 'file_helper'

module SnippetCli
  # Shared YAML file loading with existence check and syntax-error handling.
  module YamlLoader
    # Loads and parses a YAML file.
    # Raises FileMissingError if the file does not exist.
    # Raises InvalidYamlError if the file contains invalid YAML syntax.
    def self.load(path, permitted_classes: [Symbol])
      FileHelper.ensure_readable!(path)
      YAML.safe_load_file(path, permitted_classes: permitted_classes) || {}
    rescue Psych::SyntaxError => e
      raise InvalidYamlError, "Invalid YAML: #{e.message}"
    end
  end
end
