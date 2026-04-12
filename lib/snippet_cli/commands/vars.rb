# frozen_string_literal: true

require 'dry/cli'
require_relative '../var_builder'
require_relative '../vars_block_renderer'
require_relative '../snippet_builder'
require_relative '../ui'
require_relative '../wizard_context'
require_relative '../wizard_helpers/error_handler'
require_relative '../wizard_helpers/match_file_selector'
require_relative '../espanso_config'
require_relative '../global_vars_writer'

module SnippetCli
  module Commands
    class Vars < Dry::CLI::Command
      include WizardHelpers::ErrorHandler
      include WizardHelpers::MatchFileSelector

      desc 'Build an Espanso vars block interactively (alias: v)'

      option :save, type: :flag, default: false, aliases: ['-s'],
                    desc: 'Save vars to Espanso match file under global_vars'

      def call(**opts)
        handle_errors(EspansoConfigError, NoMatchFilesError) do
          context = WizardContext.new(pipe_output: SnippetCli.pipe_output)
          result = VarBuilder.run(skip_initial_prompt: true)
          save_vars(result[:vars]) if opts[:save]
          deliver_vars(result[:vars], context)
        end
      end

      private

      def deliver_vars(vars, context)
        UI.deliver(vars_yaml(vars), label: 'Vars', context: context)
      end

      def save_vars(vars)
        return if vars.empty?

        chosen, full_path = pick_match_file
        entries = vars_yaml(vars).sub(/\Avars:\n/, '')
        GlobalVarsWriter.append(full_path, entries)
        UI.success("Saved to #{chosen}")
      end

      # pick_match_file is provided by WizardHelpers

      def vars_yaml(vars)
        return "vars: []\n" if vars.empty?

        "#{VarsBlockRenderer.render(vars).join("\n")}\n"
      end
    end
  end
end
