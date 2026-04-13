# frozen_string_literal: true

require_relative 'hash_utils'
require_relative 'schema_validator'

module SnippetCli
  # Validates an Espanso match entry (as a Ruby hash) against the merged
  # schema embedded at lib/snippet_cli/Espanso_Merged_Matchfile_Schema.json.
  # Uses json_schemer which supports JSON Schema draft-07 (required for
  # the if/then conditionals used in the Espanso match schema).
  module MatchValidator
    # Returns true if the data is valid against the Espanso match schema.
    # Accepts symbol or string keys — keys are stringified before validation.
    # The merged schema validates a full matchfile, so the entry is wrapped in
    # a { "matches" => [...] } envelope before validation.
    def self.valid?(data)
      SchemaValidator.valid?(wrap(HashUtils.stringify_keys_deep(data)))
    end

    # Returns an array of human-readable error strings.
    # Empty array means the data is valid.
    def self.errors(data)
      SchemaValidator.validate(wrap(HashUtils.stringify_keys_deep(data))).map do |error|
        error['error'] || error.fetch('type', 'validation error')
      end
    end

    def self.wrap(entry)
      { 'matches' => [entry] }
    end
    private_class_method :wrap
  end
end
