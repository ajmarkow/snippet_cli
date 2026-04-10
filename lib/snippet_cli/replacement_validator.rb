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

    def var_error_clear(vars, replacement)
      gv_names = defined?(@global_var_names) ? @global_var_names : []
      errors = VarUsageChecker.match_warnings(vars, replacement, global_var_names: gv_names)
      return nil if errors.empty?

      errors.each { |e| UI.warning(e) }
      return nil if confirm!('Are you sure you want to continue?')

      -> {}
    end
  end
end
