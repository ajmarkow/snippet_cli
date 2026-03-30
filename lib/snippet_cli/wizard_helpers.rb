# frozen_string_literal: true

require 'English'
require 'gum'

module SnippetCli
  # Shared prompt helpers for interactive wizard commands.
  # Wraps Gum calls with Ctrl+C detection via WizardInterrupted.
  module WizardHelpers
    # Returns the value if non-nil; raises WizardInterrupted otherwise.
    # Gum.choose / .input / .filter / .write return nil on Ctrl+C.
    def prompt!(value)
      raise WizardInterrupted if value.nil?

      value
    rescue Interrupt
      raise WizardInterrupted
    end

    # Wraps Gum.confirm and checks $?.exitstatus for 130 (Ctrl+C).
    # Gum.confirm uses system() which swallows SIGINT and returns false,
    # making it indistinguishable from the user answering "no" — except
    # that $? records the child's exit code 130.
    # SIGINT can also raise Interrupt in Ruby before $? is read.
    def confirm!(text)
      result = Gum.confirm(text)
      raise WizardInterrupted if $CHILD_STATUS.respond_to?(:exitstatus) && $CHILD_STATUS.exitstatus == 130

      result
    rescue Interrupt
      raise WizardInterrupted
    end
  end
end
