# frozen_string_literal: true

require 'dry/cli'
require_relative '../var_builder'
require_relative '../snippet_builder'

module SnippetCli
  module Commands
    class Vars < Dry::CLI::Command
      desc 'Interactive var builder — outputs Espanso vars YAML block (alias: va)'

      option :no_clipboard, type: :boolean, default: false, aliases: ['-nc'],
                            desc: 'Print to stdout only (skip clipboard)'

      def call(no_clipboard: false, **)
        vars   = VarBuilder.run
        output = vars_yaml(vars)

        if no_clipboard
          puts output
        else
          require 'clipboard'
          Clipboard.copy(output)
          puts '✓ Copied to clipboard'
        end
      end

      private

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
