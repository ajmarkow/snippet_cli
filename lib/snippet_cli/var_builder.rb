# frozen_string_literal: true

require 'gum'
require_relative 'ui'
require_relative 'wizard_helpers'
require_relative 'var_builder/name_collector'
require_relative 'var_builder/params'

module SnippetCli
  module VarBuilder
    extend WizardHelpers

    VAR_TYPES = %w[echo shell date random choice script form].freeze

    # Characters that break variable-to-mapping resolution. Add more here as needed.
    PROHIBITED_CHARS = %w[-].freeze

    SHELLS_BY_PLATFORM = {
      macos: %w[sh bash pwsh nu],
      linux: %w[sh bash pwsh nu],
      windows: %w[cmd powershell pwsh wsl nu]
    }.freeze

    # Collects Espanso variable definitions interactively. Raises WizardInterrupted on cancel.
    # skip_initial_prompt: true skips "Add a variable?" and goes straight to collecting the first var.
    # Returns { vars: Array, summary_clear: Proc }.
    def self.run(skip_initial_prompt: false)
      interactive_session(skip_initial_prompt: skip_initial_prompt)
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
      name = NameCollector.new(existing).collect
      return nil if name.nil?

      type = prompt!(Gum.filter(*VAR_TYPES, limit: 1, header: 'Variable type'))
      { name: name, type: type, params: Params.collect(self, type) }
    end
    private_class_method :collect_one_var

    def self.interactive_session(skip_initial_prompt: false)
      vars = []
      loop do
        break unless confirm_next?(vars, skip_initial_prompt)

        append_var!(vars)
      end
      summary_clear = vars.empty? ? -> {} : show_summary(vars)
      { vars: vars, summary_clear: summary_clear }
    end
    private_class_method :interactive_session

    def self.confirm_next?(vars, skip_initial_prompt)
      return true if vars.empty? && skip_initial_prompt

      question = confirm_question(vars, skip_initial_prompt)
      if vars.empty?
        confirm!(question)
      else
        list_confirm!('variable', vars.map { |v| [v[:name], v[:type]] }, %w[Name Type], question)
      end
    end
    private_class_method :confirm_next?

    def self.confirm_question(vars, skip_initial_prompt)
      if skip_initial_prompt then 'Add an additional variable?'
      elsif vars.empty?      then 'Add a variable?'
      else                        'Add another variable?'
      end
    end
    private_class_method :confirm_question

    def self.append_var!(vars)
      var = collect_one_var(vars)
      return if var.nil?

      vars << var
    end
    private_class_method :append_var!

    def self.show_summary(vars)
      rows = summary_rows(vars)
      names = rows.map { |name, _type| "{{#{name}}}" }.join(', ')
      text = "Reference your variables in the replacement using {{var}} syntax:\n#{names}"
      UI.note(text)
      puts
      Gum.table(rows, columns: %w[Name Type], print: true)
      puts
      build_summary_erase(text, rows)
    end
    private_class_method :show_summary

    def self.summary_rows(vars)
      vars.flat_map do |var|
        if var[:type] == 'form'
          form_field_names(var[:params][:layout]).map { |field| ["#{var[:name]}.#{field}", 'form field'] }
        else
          [[var[:name], var[:type]]]
        end
      end
    end
    private_class_method :summary_rows

    def self.form_field_names(layout)
      layout.to_s.scan(/\[\[\s*(\w+)\s*\]\]/).flatten
    end
    private_class_method :form_field_names

    def self.build_summary_erase(text, rows)
      return -> {} unless $stdout.tty?

      # UI.note lines + blank + table (top border + header + separator + data rows + bottom border) + blank
      total = text.lines.count + 1 + rows.length + 4 + 1
      lambda {
        $stdout.print TTY::Cursor.up(total)
        $stdout.print "\r"
        $stdout.print TTY::Cursor.clear_screen_down
      }
    end
    private_class_method :build_summary_erase
  end
end
