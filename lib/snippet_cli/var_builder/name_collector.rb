# frozen_string_literal: true

require_relative '../ui'
require_relative '../wizard_helpers'

module SnippetCli
  module VarBuilder
    # Handles the interactive name-collection loop: prompts for a variable
    # name, validates it (non-empty, no prohibited chars, no duplicates), and
    # returns the accepted name or nil when a duplicate is detected.
    class NameCollector
      include WizardHelpers

      def initialize(existing)
        @existing = existing
      end

      # Returns the validated name string, or nil for a duplicate.
      # Raises WizardInterrupted on Ctrl+C / nil input.
      FIRST_VAR_HEADER = "One replacement may use multiple variables.\n" \
                         "Enter names one at a time, you'll be asked to add another after each.\n"

      def collect
        first = @existing.empty?
        name = prompt_until_valid do
          n, first = prompt_name(first)
          [n, name_validation_error(n)]
        end
        return nil if duplicate?(name)

        name
      end

      private

      def prompt_name(first)
        opts = { placeholder: 'Your variable name' }
        opts[:header] = FIRST_VAR_HEADER if first
        [prompt!(Gum.input(**opts)), false]
      end

      def name_validation_error(name)
        return 'Variable name cannot be empty. Please enter a name.' if name.strip.empty?
        return prohibited_char_message(name) if prohibited_char?(name)

        nil
      end

      def duplicate?(name)
        return false unless @existing.any? { |v| v[:name] == name }

        warn "Variable '#{name}' already defined — skipping"
        true
      end

      def prohibited_char?(name)
        PROHIBITED_CHARS.any? { |char| name.include?(char) }
      end

      def prohibited_char_message(name)
        prohibited = PROHIBITED_CHARS.map { |c| "'#{c}'" }.join(', ')
        "Variable name '#{name}' contains a prohibited character " \
          "(#{prohibited}) — use only letters, digits, and underscores"
      end
    end
    private_constant :NameCollector
  end
end
