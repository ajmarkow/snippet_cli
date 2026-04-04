# frozen_string_literal: true

require_relative '../ui'

module SnippetCli
  module VarBuilder
    # Handles the interactive name-collection loop: prompts for a variable
    # name, validates it (non-empty, no prohibited chars, no duplicates), and
    # returns the accepted name or nil when a duplicate is detected.
    class NameCollector
      def initialize(existing)
        @existing = existing
      end

      # Returns the validated name string, or nil for a duplicate.
      # Raises WizardInterrupted on Ctrl+C / nil input.
      FIRST_VAR_HEADER = "One replacement may use multiple variables.\n" \
                         "Enter names one at a time, you'll be asked to add another after each.\n"

      def collect
        clear = nil
        first = @existing.empty?
        loop do
          name, first = prompt_name(first)
          if (new_clear = invalid_name_clear(name, clear))
            clear = new_clear
          else
            return accepted_name(name, clear)
          end
        end
      end

      private

      def prompt_name(first)
        opts = { placeholder: 'Your variable name' }
        opts[:header] = FIRST_VAR_HEADER if first && $stdout.tty?
        [prompt!(Gum.input(**opts)), false]
      end

      def accepted_name(name, clear)
        clear&.call
        return nil if duplicate?(name)

        name
      end

      def invalid_name_clear(name, clear)
        return checkpoint_warning(clear, 'Variable name cannot be empty. Please enter a name.') if name.strip.empty?
        return checkpoint_warning(clear, prohibited_char_message(name)) if prohibited_char?(name)

        nil
      end

      def checkpoint_warning(clear, text)
        clear&.call
        UI.transient_warning(text)
      end

      def duplicate?(name)
        return false unless @existing.any? { |v| v[:name] == name }

        warn "Variable '#{name}' already defined — skipping"
        true
      end

      def prompt!(value)
        value.nil? ? raise(WizardInterrupted) : value
      rescue Interrupt
        raise WizardInterrupted
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
