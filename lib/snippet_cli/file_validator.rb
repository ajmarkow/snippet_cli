# frozen_string_literal: true

require_relative 'hash_utils'
require_relative 'schema_validator'

module SnippetCli
  # Validates a full Espanso match file (matches array + global_vars + imports + anchors)
  # against the vendored merged schema (official + custom extensions).
  module FileValidator
    # Returns true if the data hash is valid against the matchfile schema.
    def self.valid?(data)
      SchemaValidator.valid?(HashUtils.stringify_keys_deep(data))
    end

    # Returns an array of human-readable error strings with field pointers.
    # Empty array means the data is valid.
    def self.errors(data)
      SchemaValidator.validate(HashUtils.stringify_keys_deep(data)).map do |error|
        pointer = error['data_pointer']
        message = error['error'] || error.fetch('type', 'validation error')
        pointer.to_s.empty? ? message : "at #{pointer}: #{message}"
      end
    end
  end
end
