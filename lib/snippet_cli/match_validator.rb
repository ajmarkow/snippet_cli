# frozen_string_literal: true

require 'json'
require 'json_schemer'

module SnippetCli
  # Validates an Espanso match entry (as a Ruby hash) against the vendored
  # JSON schema at vendor/espanso-schema-json/schemas/Espanso_Match_Schema.json.
  # Uses json_schemer which supports JSON Schema draft-07 (required for
  # the if/then conditionals used in the Espanso match schema).
  module MatchValidator
    SCHEMA_PATH = File.expand_path(
      '../../vendor/espanso-schema-json/schemas/Espanso_Match_Schema.json', __dir__
    ).freeze

    # Returns true if the data is valid against the Espanso match schema.
    # Accepts symbol or string keys — keys are stringified before validation.
    def self.valid?(data)
      schemer.valid?(stringify_keys_deep(data))
    end

    # Returns an array of human-readable error strings.
    # Empty array means the data is valid.
    def self.errors(data)
      schemer.validate(stringify_keys_deep(data)).map do |error|
        error['error'] || error.fetch('type', 'validation error')
      end
    end

    def self.schemer
      @schemer ||= JSONSchemer.schema(Pathname.new(SCHEMA_PATH))
    end
    private_class_method :schemer

    # Recursively converts symbol keys to string keys so the JSON schema
    # validator can match property names.
    def self.stringify_keys_deep(obj)
      case obj
      when Hash
        obj.each_with_object({}) { |(k, v), h| h[k.to_s] = stringify_keys_deep(v) }
      when Array
        obj.map { |item| stringify_keys_deep(item) }
      else
        obj
      end
    end
    private_class_method :stringify_keys_deep
  end
end
