# frozen_string_literal: true

require 'gum'
require_relative 'ui'
require_relative 'cursor_helper'

module SnippetCli
  # Pure display/formatting logic for the VarBuilder summary screen.
  # Handles row computation, UI.note output, Gum.table rendering, and cursor erase lambda.
  module VarSummaryRenderer
    # Returns display rows for the given vars array.
    # Form vars are expanded into dot-notation field rows; all others are [name, type].
    def self.rows(vars)
      vars.flat_map do |var|
        if var[:type] == 'form'
          form_field_names(var[:params][:layout]).map { |field| ["#{var[:name]}.#{field}", 'form field'] }
        else
          [[var[:name], var[:type]]]
        end
      end
    end

    # Renders the summary note + table. Returns a lambda that erases the output.
    def self.show(vars)
      display_rows = rows(vars)
      names = display_rows.map { |name, _type| "{{#{name}}}" }.join(', ')
      text = "Reference your variables in the replacement using {{var}} syntax:\n#{names}"
      UI.note(text)
      puts
      Gum.table(display_rows, columns: %w[Name Type], print: true)
      puts
      build_erase(text, display_rows)
    end

    def self.form_field_names(layout)
      layout.to_s.scan(/\[\[\s*(\w+)\s*\]\]/).flatten
    end
    private_class_method :form_field_names

    def self.build_erase(text, display_rows)
      # UI.note lines + blank + table (top border + header + separator + data rows + bottom border) + blank
      total = text.lines.count + 1 + display_rows.length + 4 + 1
      CursorHelper.build_erase_lambda(total)
    end
    private_class_method :build_erase
  end
end
