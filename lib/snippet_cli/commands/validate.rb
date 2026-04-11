# frozen_string_literal: true

require 'dry/cli'
require_relative '../file_validator'
require_relative '../ui'
require_relative '../yaml_loader'
require_relative '../wizard_helpers/error_handler'
require_relative '../wizard_helpers/match_file_selector'
require_relative '../espanso_config'

module SnippetCli
  module Commands
    class Validate < Dry::CLI::Command
      include WizardHelpers::ErrorHandler
      include WizardHelpers::MatchFileSelector

      desc 'Validate an Espanso match YAML file against the schema (alias: v)'

      option :file, aliases: ['-f'], desc: 'Path to the Espanso match YAML file to validate'

      def call(file: nil, **)
        handle_errors(NoMatchFilesError) do
          file ||= pick_match_file.last
          data = YamlLoader.load(file)
          report(file, FileValidator.errors(data))
        end
      rescue FileMissingError, InvalidYamlError => e
        warn e.message
        exit 1
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
