# frozen_string_literal: true

require_relative 'yaml_param_renderer'

module SnippetCli
  # Renders a single Espanso var entry as YAML lines.
  # Used by SnippetBuilder and commands/vars to share a consistent rendering strategy.
  module VarYamlRenderer
    # Returns an array of YAML lines for one var hash ({ name:, type:, params: }).
    def self.var_lines(var)
      lines = ["  - name: #{var[:name]}", "    type: #{var[:type]}"]
      params = var[:params]
      return lines unless params&.any?

      lines << '    params:'
      params.each { |key, val| lines.concat(YamlParamRenderer.lines(key, val, '      ')) }
      lines
    end
  end
end
