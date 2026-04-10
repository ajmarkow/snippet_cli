# frozen_string_literal: true

require 'gum'
require_relative '../ui'
require_relative '../form_field_parser'

module SnippetCli
  module VarBuilder
    # Collects field-level configuration for form variable layouts.
    module FormFields
      FIELD_TYPES = [
        'Single-line text box',
        'Multi-line text box',
        'Choice box',
        'List box'
      ].freeze

      def self.collect(builder, layout)
        field_names = FormFieldParser.extract(layout)
        fields = {}
        field_names.each do |name|
          type = builder.prompt!(
            Gum.filter(*FIELD_TYPES, limit: 1, header: "[[#{name}]] field type")
          )
          config = field_config(builder, name, type)
          fields[name.to_sym] = config if config
        end
        fields
      end

      def self.field_config(builder, name, type)
        case type
        when 'Multi-line text box'
          { multiline: true }
        when 'Choice box'
          { type: :choice, values: collect_values(builder, name) }
        when 'List box'
          { type: :list, values: collect_values(builder, name) }
        end
      end
      private_class_method :field_config

      def self.collect_values(builder, field_name)
        loop do
          values = Params.collect_list(builder, "#{field_name} value")
          return values if values.length >= 2

          UI.warning("Provide at least 2 values for [[#{field_name}]].")
        end
      end
      private_class_method :collect_values
    end
  end
end
