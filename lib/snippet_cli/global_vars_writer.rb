# frozen_string_literal: true

require 'yaml'
require_relative 'file_helper'

module SnippetCli
  # Appends generated var entries to the global_vars key in an Espanso match file.
  # Uses string-level append (not YAML round-trip) to preserve formatting.
  module GlobalVarsWriter
    # Appends var entries under the global_vars key in the given file.
    # Creates the key if it doesn't exist. Never overwrites existing vars.
    # +var_entries+ is the indented YAML string (each line already indented by 2).
    def self.append(file_path, var_entries)
      existing = FileHelper.read_or_empty(file_path)
      content = build_content(existing, var_entries)
      File.write(file_path, content)
    end

    # Returns an array of var name strings from the global_vars key in the file.
    def self.read_names(file_path)
      return [] unless File.exist?(file_path)

      data = YAML.safe_load_file(file_path, permitted_classes: [Symbol]) || {}
      Array(data['global_vars']).filter_map { |v| v['name'] }
    end

    def self.build_content(existing, var_entries)
      return new_global_vars(var_entries) if existing.strip.empty?
      return insert_into_block(existing, var_entries) if existing.match?(/^global_vars:\s*$/m)

      append_global_vars(existing, var_entries)
    end
    private_class_method :build_content

    def self.new_global_vars(var_entries)
      ensure_newline("global_vars:\n#{var_entries}")
    end
    private_class_method :new_global_vars

    def self.append_global_vars(existing, var_entries)
      ensure_newline("#{existing.chomp}\n\nglobal_vars:\n#{var_entries}")
    end
    private_class_method :append_global_vars

    def self.insert_into_block(existing, var_entries)
      lines = existing.lines
      gv_index = lines.index { |l| l.match?(/^global_vars:\s*$/) }
      last_content = find_block_end(lines, gv_index)

      join_parts(lines, last_content, var_entries)
    end
    private_class_method :insert_into_block

    # Find the last content line of the global_vars block
    def self.find_block_end(lines, gv_index)
      last_content = gv_index
      ((gv_index + 1)...lines.length).each do |i|
        break if lines[i].match?(/^\S/)

        last_content = i unless lines[i].strip.empty?
      end
      last_content
    end
    private_class_method :find_block_end

    def self.join_parts(lines, last_content, var_entries)
      before = lines[0..last_content].join
      rest = lines[(last_content + 1)..]

      result = "#{before.chomp}\n#{var_entries}"
      if rest && !rest.empty?
        result << "\n" unless result.end_with?("\n\n") || rest.first&.strip&.empty?
        result << rest.join
      end
      ensure_newline(result)
    end
    private_class_method :join_parts

    def self.ensure_newline(str)
      str.end_with?("\n") ? str : "#{str}\n"
    end
    private_class_method :ensure_newline
  end
end
