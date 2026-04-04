# frozen_string_literal: true

require 'dry/cli'
require 'yaml'
require_relative '../file_validator'
require_relative '../ui'

module SnippetCli
  module Commands
    class Validate < Dry::CLI::Command
      desc 'Validate an Espanso match YAML file against the schema (alias: vl)'

      argument :file, required: true, desc: 'Path to the Espanso match YAML file to validate'

      def call(file:, **)
        data = load_yaml(file)
        report(file, FileValidator.errors(data))
      rescue Psych::SyntaxError => e
        warn "Invalid YAML: #{e.message}"
        exit 1
      end

      private

      def report(file, errors)
        return UI.success("#{file} is valid.") if errors.empty?

        errors.each { |e| warn "error: #{e}" }
        exit 1
      end

      def load_yaml(file)
        unless File.exist?(file)
          warn "File not found: #{file}"
          exit 1
        end
        YAML.safe_load_file(file, permitted_classes: [Symbol]) || {}
      end
    end
  end
end
