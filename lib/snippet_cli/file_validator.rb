# frozen_string_literal: true

require 'json'
require 'json_schemer'

module SnippetCli
  # Validates a full Espanso match file (matches array + global_vars + imports + anchors)
  # against the vendored merged schema (official + custom extensions).
  module FileValidator
    SCHEMA_PATH = File.expand_path(
      '../../vendor/espanso-schema-json/schemas/Espanso_Merged_Matchfile_Schema.json', __dir__
    ).freeze

    # Returns true if the data hash is valid against the matchfile schema.
    def self.valid?(data)
      schemer.valid?(stringify_keys_deep(data))
    end

    # Returns an array of human-readable error strings with field pointers.
    # Empty array means the data is valid.
    def self.errors(data)
      schemer.validate(stringify_keys_deep(data)).map do |error|
        pointer = error['data_pointer']
        message = error['error'] || error.fetch('type', 'validation error')
        pointer.to_s.empty? ? message : "at #{pointer}: #{message}"
      end
    end

    def self.schemer
      @schemer ||= JSONSchemer.schema(Pathname.new(SCHEMA_PATH))
    end
    private_class_method :schemer

    def self.stringify_keys_deep(obj)
      case obj
      when Hash
        obj.each_with_object({}) { |(k, v), h| h[k.to_s] = stringify_keys_deep(v) }
      when Array
        obj.map { |item| stringify_keys_deep(item) }
      when Symbol
        obj.to_s
      else
        obj
      end
    end
    private_class_method :stringify_keys_deep
  end
end
