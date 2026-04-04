# frozen_string_literal: true

require 'json'
require 'json_schemer'
require_relative 'hash_utils'

module SnippetCli
  # Validates a full Espanso match file (matches array + global_vars + imports + anchors)
  # against the vendored merged schema (official + custom extensions).
  module FileValidator
    SCHEMA_PATH = File.expand_path(
      '../../vendor/espanso-schema-json/schemas/Espanso_Merged_Matchfile_Schema.json', __dir__
    ).freeze

    # Returns true if the data hash is valid against the matchfile schema.
    def self.valid?(data)
      schemer.valid?(HashUtils.stringify_keys_deep(data))
    end

    # Returns an array of human-readable error strings with field pointers.
    # Empty array means the data is valid.
    def self.errors(data)
      schemer.validate(HashUtils.stringify_keys_deep(data)).map do |error|
        pointer = error['data_pointer']
        message = error['error'] || error.fetch('type', 'validation error')
        pointer.to_s.empty? ? message : "at #{pointer}: #{message}"
      end
    end

    def self.schemer
      @schemer ||= JSONSchemer.schema(Pathname.new(SCHEMA_PATH))
    end
    private_class_method :schemer
  end
end
