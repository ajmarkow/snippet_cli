# frozen_string_literal: true

require_relative 'ui'
require_relative 'var_usage_checker'
require_relative 'wizard_helpers'

module SnippetCli
  # Validates replacement data against declared vars.
  # Returns a clear lambda when the user wants to retry, nil when they accept or there are no issues.
  module ReplacementValidator
    include WizardHelpers

    private

    def var_error_clear(vars, replacement, global_var_names: [])
      result = VarUsageChecker.match_warnings(vars, replacement, global_var_names: global_var_names)
      return nil if result[:unused].empty? && result[:undeclared].empty?

      display_var_warnings(result)
      return nil if confirm!('Are you sure you want to continue?')

      -> {}
    end

    def display_var_warnings(result)
      result[:unused].each do |name|
        UI.warning("Variable '#{name}' is declared but unused — add {{#{name}}} to the replacement text.")
      end
      result[:undeclared].each do |name|
        UI.warning("'{{#{name}}}' appears in the replacement but was not declared as a variable. " \
                   "Remove {{#{name}}} from the replacement.")
      end
    end
  end
end
