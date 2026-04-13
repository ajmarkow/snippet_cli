# frozen_string_literal: true

require 'json_schemer'

module SnippetCli
  # Loads the vendored Espanso merged matchfile schema once and exposes
  # valid?/validate for use by MatchValidator and FileValidator.
  # Callers are responsible for stringifying keys before passing data.
  module SchemaValidator
    SCHEMA_PATH = File.expand_path(
      'Espanso_Merged_Matchfile_Schema.json', __dir__
    ).freeze

    def self.valid?(data)
      schemer.valid?(data)
    end

    def self.validate(data)
      schemer.validate(data)
    end

    def self.schemer
      @schemer ||= JSONSchemer.schema(Pathname.new(SCHEMA_PATH))
    end
    private_class_method :schemer
  end
end
