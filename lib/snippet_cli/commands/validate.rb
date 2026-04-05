# frozen_string_literal: true

require 'dry/cli'
require_relative '../file_validator'
require_relative '../ui'
require_relative '../yaml_loader'

module SnippetCli
  module Commands
    class Validate < Dry::CLI::Command
      desc 'Validate an Espanso match YAML file against the schema (alias: v)'

      option :file, required: true, aliases: ['-f'], desc: 'Path to the Espanso match YAML file to validate (required)'

      def call(file: nil, **)
        unless file
          UI.error('--file is required. Run with --help for usage.')
          exit 1
        end
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
