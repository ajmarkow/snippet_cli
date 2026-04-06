# frozen_string_literal: true

require 'dry/cli'
require_relative '../file_validator'
require_relative '../ui'
require_relative '../yaml_loader'
require_relative '../wizard_helpers'
require_relative '../espanso_config'

module SnippetCli
  module Commands
    class Validate < Dry::CLI::Command
      include WizardHelpers

      desc 'Validate an Espanso match YAML file against the schema (alias: v)'

      option :file, aliases: ['-f'], desc: 'Path to the Espanso match YAML file to validate'

      def call(file: nil, **)
        file ||= pick_match_file.last
        data = YamlLoader.load(file)
        report(file, FileValidator.errors(data))
      rescue WizardInterrupted
        puts
        UI.error('Interrupted, exiting snippet_cli.')
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
