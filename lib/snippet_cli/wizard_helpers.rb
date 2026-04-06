# frozen_string_literal: true

require 'English'
require 'gum'
require_relative 'table_formatter'

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

    # Selects an Espanso match file for saving.
    # Auto-selects when only one file exists; otherwise prompts via Gum.filter.
    # Exits with an error when no match files are found.
    def pick_match_file
      files = EspansoConfig.match_files
      abort_no_match_files if files.empty?
      return [File.basename(files.first), files.first] if files.size == 1

      basenames = files.map { |f| File.basename(f) }
      chosen = prompt!(Gum.filter(*basenames, header: 'Save to which match file?'))
      [chosen, files.find { |f| File.basename(f) == chosen }]
    end

    def abort_no_match_files
      UI.error('No match files found in Espanso config.')
      exit 1
    end

    # Loops until the block yields a non-empty string.
    # Shows warning_message as a transient warning on empty input.
    def prompt_non_empty(warning_message)
      clear = nil
      loop do
        value = yield
        clear&.call
        return value unless value.strip.empty?

        clear = UI.transient_warning(warning_message)
      end
    end
  end
end
