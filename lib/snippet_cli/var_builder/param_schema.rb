# frozen_string_literal: true

module SnippetCli
  module VarBuilder
    # Pure data layer: describes what params are valid for each var type.
    # No Gum/UI calls — independently testable.
    module ParamSchema
      SCHEMAS = {
        'echo' => {
          required: [:echo],
          optional: [],
          field_types: { echo: :string }
        },
        'random' => {
          required: [:choices],
          optional: [],
          field_types: { choices: :string_array }
        },
        'choice' => {
          required: [:values],
          optional: [],
          field_types: { values: :string_array }
        },
        'date' => {
          required: [:format],
          optional: %i[offset locale tz],
          field_types: { format: :string, offset: :integer, locale: :string, tz: :string }
        },
        'shell' => {
          required: %i[cmd shell],
          optional: %i[debug trim],
          field_types: { cmd: :string, shell: :string, debug: :boolean, trim: :boolean }
        },
        'script' => {
          required: [:args],
          optional: [:trim],
          field_types: { args: :string_array, trim: :boolean }
        },
        'form' => {
          required: [:layout],
          optional: [:fields],
          field_types: { layout: :string, fields: :any }
        },
        'clipboard' => {
          required: [],
          optional: [],
          field_types: {}
        }
      }.freeze

      def self.known_type?(type)
        SCHEMAS.key?(type)
      end

      def self.schema_for(type)
        SCHEMAS[type]
      end

      # Returns true if params hash contains all required fields and no unknown fields.
      # Pure method — no UI calls.
      def self.valid_params?(type, params)
        schema = SCHEMAS[type]
        return false unless schema

        allowed = schema[:required] + schema[:optional]
        schema[:required].all? { |f| params.key?(f) } &&
          params.keys.all? { |k| allowed.include?(k) }
      end
    end
  end
end
