# frozen_string_literal: true

require_relative 'var_yaml_renderer'

module SnippetCli
  # Builds the vars: block as an array of YAML lines.
  # indent: is prepended only to the vars: header; VarYamlRenderer owns var-entry indentation.
  module VarsBlockRenderer
    def self.render(vars, indent: '')
      lines = ["#{indent}vars:"]
      vars.each { |var| lines.concat(VarYamlRenderer.var_lines(var)) }
      lines
    end
  end
end
