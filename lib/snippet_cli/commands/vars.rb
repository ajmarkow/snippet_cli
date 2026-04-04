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

      def call(**)
        deliver_vars(VarBuilder.run(skip_initial_prompt: true))
      rescue WizardInterrupted
        puts
        UI.error('Interrupted, exiting snippet_cli.')
      end

      private

      def deliver_vars(vars)
        output = vars_yaml(vars)
        if $stdout.tty?
          UI.info('Vars YAML below.')
          UI.format_code(output)
        else
          $stdout.print output
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
