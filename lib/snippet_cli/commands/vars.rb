# frozen_string_literal: true

require 'dry/cli'
require_relative '../var_builder'
require_relative '../snippet_builder'
require_relative '../ui'
require_relative '../wizard_helpers'
require_relative '../espanso_config'
require_relative '../global_vars_writer'

module SnippetCli
  module Commands
    class Vars < Dry::CLI::Command
      include WizardHelpers

      desc 'Interactive var builder — outputs Espanso vars YAML block'

      option :save, type: :boolean, default: false, aliases: ['-s'],
                    desc: 'Save vars to Espanso match file under global_vars'

      def call(**opts)
        result = VarBuilder.run(skip_initial_prompt: true)
        save_vars(result[:vars]) if opts[:save]
        deliver_vars(result[:vars])
      rescue EspansoConfigError => e
        UI.error(e.message)
        exit 1
      rescue WizardInterrupted
        puts
        UI.error('Interrupted, exiting snippet_cli.')
      end

      private

      def deliver_vars(vars)
        UI.deliver(vars_yaml(vars), label: 'Vars')
      end

      def save_vars(vars)
        return if vars.empty?

        chosen, full_path = pick_match_file
        entries = vars_yaml(vars).sub(/\Avars:\n/, '')
        GlobalVarsWriter.append(full_path, entries)
        UI.success("Saved to #{chosen}")
      end

      def pick_match_file
        files = EspansoConfig.match_files
        if files.empty?
          UI.error('No match files found in Espanso config.')
          exit 1
        end

        basenames = files.map { |f| File.basename(f) }
        chosen = prompt!(Gum.filter(*basenames, header: 'Save to which match file?'))
        [chosen, files.find { |f| File.basename(f) == chosen }]
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
