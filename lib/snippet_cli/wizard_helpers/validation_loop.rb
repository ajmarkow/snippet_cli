# frozen_string_literal: true

module SnippetCli
  module WizardHelpers
    # Loop-until-valid prompt abstractions.
    module ValidationLoop
      # General loop-until-valid primitive.
      # The block must yield [value, error_or_nil].
      # When error is a String, shows it as a transient warning.
      # When error is a Callable (e.g. a lambda), uses it directly as the clear function.
      # Loops until the block yields a nil error.
      def prompt_until_valid
        clear = nil
        loop do
          value, error = yield
          clear&.call
          return value if error.nil?

          clear = error.respond_to?(:call) ? error : UI.transient_warning(error)
        end
      end

      # Loops until the block yields a non-empty string.
      # Shows warning_message as a transient warning on empty input.
      def prompt_non_empty(warning_message, &prompt_block)
        prompt_until_valid do
          value = prompt_block.call
          [value, value.strip.empty? ? warning_message : nil]
        end
      end
    end
  end
end
