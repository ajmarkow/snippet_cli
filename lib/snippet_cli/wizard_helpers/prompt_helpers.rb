# frozen_string_literal: true

require 'English'
require 'gum'
require_relative '../table_formatter'

module SnippetCli
  module WizardHelpers
    # Gum prompt primitives with Ctrl+C detection via WizardInterrupted.
    module PromptHelpers
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
        result = Gum.confirm(text, prompt_style: { padding: '0 1', margin: '0' })
        raise WizardInterrupted if result.nil?
        raise WizardInterrupted if $CHILD_STATUS.respond_to?(:exitstatus) && $CHILD_STATUS.exitstatus == 130

        result
      rescue Interrupt
        raise WizardInterrupted
      end

      # Renders a table of collected items and asks a follow-up question, without a border.
      def list_confirm!(label, rows, headers, question)
        table = TableFormatter.render(rows, headers: headers)
        confirm!("Current #{label}s:\n\n#{table}\n\n#{question}")
      end

      # Confirms a question then collects a value via the block, or returns nil if declined.
      def optional_prompt(question)
        yield if confirm!(question)
      end

      # Prompts for search terms via a multiline write block.
      # Returns an empty array if the user declines.
      def collect_search_terms
        return [] unless confirm!('Add search terms?')

        raw = prompt!(Gum.write(header: 'Put one search term per line'))
        raw.to_s.lines.map(&:chomp).reject(&:empty?)
      end
    end
  end
end
