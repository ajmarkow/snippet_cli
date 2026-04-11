# frozen_string_literal: true

require 'yaml'
require_relative 'file_helper'
require_relative 'file_writer'
require_relative 'global_vars_formatter'

module SnippetCli
  # Thin I/O wrapper around GlobalVarsFormatter.
  # Reads from and writes to Espanso match files; delegates all formatting logic.
  module GlobalVarsWriter
    # Appends var entries under the global_vars key in the given file.
    # Creates the key if it doesn't exist. Never overwrites existing vars.
    # +var_entries+ is the indented YAML string (each line already indented by 2).
    def self.append(file_path, var_entries)
      existing = FileHelper.read_or_empty(file_path)
      content = GlobalVarsFormatter.build_content(existing, var_entries)
      FileWriter.write(file_path, content)
    end

    # Returns an array of var name strings from the global_vars key in the file.
    def self.read_names(file_path)
      return [] unless File.exist?(file_path)

      data = YAML.safe_load_file(file_path, permitted_classes: [Symbol]) || {}
      Array(data['global_vars']).filter_map { |v| v['name'] }
    end
  end
end
