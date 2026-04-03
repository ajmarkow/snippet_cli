# frozen_string_literal: true

require 'English'
require 'gum'
require_relative 'table_formatter'
require_relative 'ui'
require_relative 'var_builder/name_collector'
require_relative 'var_builder/params'

module SnippetCli
  module VarBuilder
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
    @summary_clear = -> {}

    def self.run(skip_initial_prompt: false)
      interactive_session(skip_initial_prompt: skip_initial_prompt)
    rescue Interrupt
      raise WizardInterrupted
    end

    def self.summary_clear
      @summary_clear
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

    def self.interactive_session(skip_initial_prompt: false)
      vars = []
      loop do
        unless vars.empty? && skip_initial_prompt
          prompt_text = build_confirm_prompt(vars, skip_initial_prompt)
          break unless confirm!(prompt_text)
        end
        append_var!(vars)
      end
      show_summary(vars) unless vars.empty?
      vars
    end
    private_class_method :interactive_session

    def self.build_confirm_prompt(vars, skip_initial_prompt)
      question = confirm_question(vars, skip_initial_prompt)
      return question if vars.empty?

      rows = vars.map { |v| [v[:name], v[:type]] }
      table = TableFormatter.render(rows, headers: %w[Name Type])
      "Current variables:\n\n#{table}\n\n#{question}\n"
    end
    private_class_method :build_confirm_prompt

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
      names = vars.map { |v| "{{#{v[:name]}}}" }.join(', ')
      text = "Reference your variables in the replacement using {{var}} syntax:\n#{names}"
      UI.info(text)
      rows = vars.map { |var| [var[:name], var[:type]] }
      Gum.table(rows, columns: %w[Name Type], print: true)
      puts
      @summary_clear = build_summary_erase(text, vars)
    end
    private_class_method :show_summary

    def self.build_summary_erase(text, vars)
      return -> {} unless $stdout.tty?

      # info box: text lines + top/bottom borders
      # table: top border + header + separator + data rows + bottom border
      # blank line: from trailing puts
      total = text.lines.count + 2 + vars.length + 4 + 1
      lambda {
        $stdout.print TTY::Cursor.up(total)
        $stdout.print "\r"
        $stdout.print TTY::Cursor.clear_screen_down
      }
    end
    private_class_method :build_summary_erase
  end
end
