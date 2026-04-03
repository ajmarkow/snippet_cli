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
      def collect
        clear = nil
        loop do
          name = prompt!(Gum.input(placeholder: 'Your variable name'))
          if (new_clear = invalid_name_clear(name, clear))
            clear = new_clear
          else
            return accepted_name(name, clear)
          end
        end
      end

      private

      def accepted_name(name, clear)
        clear&.call
        return nil if duplicate?(name)

        name
      end

      def invalid_name_clear(name, clear)
        if name.strip.empty?
          return checkpoint_warning(clear) { UI.warning('Variable name cannot be empty. Please enter a name.') }
        end
        return checkpoint_warning(clear) { warn_prohibited_char(name) } if prohibited_char?(name)

        nil
      end

      def checkpoint_warning(clear, &block)
        clear&.call
        new_clear = UI.cursor_checkpoint
        block.call
        new_clear
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

      def warn_prohibited_char(name)
        prohibited = PROHIBITED_CHARS.map { |c| "'#{c}'" }.join(', ')
        UI.warning("Variable name '#{name}' contains a prohibited character " \
                   "(#{prohibited}) — use only letters, digits, and underscores")
      end
    end
    private_constant :NameCollector
  end
end
