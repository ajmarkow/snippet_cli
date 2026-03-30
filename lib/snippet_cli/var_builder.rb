# frozen_string_literal: true

require 'English'
require 'gum'
require_relative 'ui'
require_relative 'var_builder/params'

module SnippetCli
  module VarBuilder
    VAR_TYPES = %w[echo shell date random choice script form].freeze

    SHELLS_BY_PLATFORM = {
      macos: %w[sh bash pwsh nu],
      linux: %w[sh bash pwsh nu],
      windows: %w[cmd powershell pwsh wsl nu]
    }.freeze

    # Collects Espanso variable definitions interactively. Raises WizardInterrupted on cancel.
    def self.run
      interactive_session
    rescue Interrupt
      raise WizardInterrupted
    end

    def self.platform_shells
      case RUBY_PLATFORM
      when /darwin/             then SHELLS_BY_PLATFORM[:macos]
      when /mswin|mingw|cygwin/ then SHELLS_BY_PLATFORM[:windows]
      else SHELLS_BY_PLATFORM[:linux]
      end
    end

    def self.collect_one_var(existing)
      name = prompt!(Gum.input(placeholder: 'var name (no spaces)'))
      if existing.any? { |v| v[:name] == name }
        warn "Variable '#{name}' already defined — skipping"
        return nil
      end
      type = prompt!(Gum.filter(*VAR_TYPES, limit: 1, header: 'Variable type'))
      { name: name, type: type, params: Params.collect(self, type) }
    end
    private_class_method :collect_one_var

    def self.prompt!(value)
      value.nil? ? raise(WizardInterrupted) : value
    rescue Interrupt
      raise WizardInterrupted
    end

    def self.confirm!(text)
      result = Gum.confirm(text)
      raise WizardInterrupted if $CHILD_STATUS.respond_to?(:exitstatus) && $CHILD_STATUS.exitstatus == 130

      result
    rescue Interrupt
      raise WizardInterrupted
    end

    def self.interactive_session
      vars = []
      loop do
        break unless confirm!(vars.empty? ? 'Add a variable?' : 'Add another variable?')

        append_var!(vars)
      end
      vars
    end
    private_class_method :interactive_session

    def self.append_var!(vars)
      var = collect_one_var(vars)
      return if var.nil?

      vars << var
      show_summary(vars)
    end
    private_class_method :append_var!

    def self.show_summary(vars)
      rows = vars.map { |var| [var[:name], var[:type]] }
      Gum.table(rows, columns: %w[Name Type], print: true)
    end
    private_class_method :show_summary
  end
end
