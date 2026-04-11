# frozen_string_literal: true

module SnippetCli
  module WizardHelpers
    # Wraps a command body with standard error handling.
    # Rescues WizardInterrupted (Ctrl+C) universally.
    # Rescues typed error_classes passed by the caller, displaying their message via UI.error and exiting 1.
    module ErrorHandler
      def handle_errors(*error_classes)
        yield
      rescue *error_classes => e
        UI.error(e.message)
        exit 1
      rescue WizardInterrupted
        puts
        UI.error('Interrupted, exiting snippet_cli.')
      end
    end
  end
end
