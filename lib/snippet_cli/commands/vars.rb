# frozen_string_literal: true

require 'dry/cli'
require_relative '../var_builder'
require_relative '../snippet_builder'
require_relative '../ui'
require_relative '../wizard_helpers'

module SnippetCli
  module Commands
    class Vars < Dry::CLI::Command
      include WizardHelpers

      desc 'Interactive var builder — outputs Espanso vars YAML block (alias: va)'

      option :no_clipboard, type: :boolean, default: false, aliases: ['-nc'],
                            desc: 'Print to stdout only (skip clipboard)'

      def call(no_clipboard: false, **)
        deliver_vars(VarBuilder.run(skip_initial_prompt: true), no_clipboard)
      rescue WizardInterrupted
        puts
        UI.error('Interrupted, exiting snippet_cli.')
      end

      private

      def deliver_vars(vars, no_clipboard)
        output = vars_yaml(vars)
        UI.info('Vars YAML below.')
        UI.format_code(output)
        copy_to_clipboard(output) unless no_clipboard
      end

      def copy_to_clipboard(output)
        if confirm!('Copy to clipboard?')
          require 'clipboard'
          Clipboard.copy(output)
          UI.success('Copied to clipboard.')
        else
          UI.info('Not copied to clipboard.')
        end
      end

      def vars_yaml(vars)
        return "vars: []\n" if vars.empty?

        lines = ['vars:']
        vars.each { |var| lines.concat(var_lines(var)) }
        "#{lines.join("\n")}\n"
      end

      def var_lines(var)
        lines = ["  - name: #{var[:name]}", "    type: #{var[:type]}"]
        params = var[:params]
        return lines unless params&.any?

        lines << '    params:'
        params.each { |key, val| lines << "      #{key}: #{val}" }
        lines
      end
    end
  end
end
