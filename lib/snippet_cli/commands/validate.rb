# frozen_string_literal: true

require 'dry/cli'
require_relative '../file_validator'
require_relative '../ui'
require_relative '../yaml_loader'

module SnippetCli
  module Commands
    class Validate < Dry::CLI::Command
      desc 'Validate an Espanso match YAML file against the schema (alias: v)'

      argument :file, required: true, desc: 'Path to the Espanso match YAML file to validate'

      def call(file:, **)
        data = YamlLoader.load(file)
        report(file, FileValidator.errors(data))
      end

      private

      def report(file, errors)
        return UI.success("#{file} is valid.") if errors.empty?

        errors.each { |e| warn "error: #{e}" }
        exit 1
      end
    end
  end
end
