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

      desc 'Interactive var builder — outputs Espanso vars YAML block'

      def call(**)
        deliver_vars(VarBuilder.run(skip_initial_prompt: true))
      rescue WizardInterrupted
        puts
        UI.error('Interrupted, exiting snippet_cli.')
      end

      private

      def deliver_vars(vars)
        UI.deliver(vars_yaml(vars), label: 'Vars')
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
        params.each { |key, val| lines << "      #{key}: #{yaml_scalar(val)}" }
        lines
      end

      # Quote values that YAML would misinterpret (%, {, [, etc.)
      def yaml_scalar(val)
        return val.to_s if val.is_a?(Numeric) || val == true || val == false

        str = val.to_s
        YAML.dump(str).sub(/\A--- /, '').chomp
      end
    end
  end
end
