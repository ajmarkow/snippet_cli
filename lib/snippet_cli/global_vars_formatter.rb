# frozen_string_literal: true

require_relative 'string_helper'

module SnippetCli
  # Pure formatting logic for the global_vars section of an Espanso match file.
  # Operates entirely on strings — no file I/O.
  module GlobalVarsFormatter
    # Returns updated file content with var_entries appended under global_vars.
    # Creates the global_vars key if absent. Never overwrites existing vars.
    # +existing+ is the current file content (or empty string).
    # +var_entries+ is the pre-indented YAML string for the new vars.
    def self.build_content(existing, var_entries)
      return new_global_vars(var_entries) if existing.strip.empty?
      return insert_into_block(existing, var_entries) if existing.match?(/^global_vars:\s*$/m)

      append_global_vars(existing, var_entries)
    end

    def self.new_global_vars(var_entries)
      StringHelper.ensure_trailing_newline("global_vars:\n#{var_entries}")
    end
    private_class_method :new_global_vars

    def self.append_global_vars(existing, var_entries)
      StringHelper.ensure_trailing_newline("#{existing.chomp}\n\nglobal_vars:\n#{var_entries}")
    end
    private_class_method :append_global_vars

    def self.insert_into_block(existing, var_entries)
      lines = existing.lines
      gv_index = lines.index { |l| l.match?(/^global_vars:\s*$/) }
      last_content = find_block_end(lines, gv_index)

      join_parts(lines, last_content, var_entries)
    end
    private_class_method :insert_into_block

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
      StringHelper.ensure_trailing_newline(result)
    end
    private_class_method :join_parts
  end
end
