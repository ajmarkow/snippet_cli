# frozen_string_literal: true

require 'gum'
require_relative 'wizard_helpers/prompt_helpers'
require_relative 'var_summary_renderer'
require_relative 'var_builder/name_collector'
require_relative 'var_builder/params'

module SnippetCli
  module VarBuilder
    extend WizardHelpers::PromptHelpers

    VAR_TYPES = %w[echo shell date random choice script form clipboard].freeze

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
      reorder_vars!(vars)
      summary_clear = vars.empty? ? -> {} : VarSummaryRenderer.show(vars)
      { vars: vars, summary_clear: summary_clear }
    end
    private_class_method :interactive_session

    def self.reorder_vars!(vars)
      return if vars.size < 2
      return unless confirm!('Reorder variables for evaluation order?')

      loop do
        selection = choose_var_to_move(vars)
        break if selection.start_with?('Done')

        move_var!(vars, selection)
      end
    end
    private_class_method :reorder_vars!

    def self.choose_var_to_move(vars)
      choices = vars.each_with_index.map { |v, i| "#{i + 1}. #{v[:name]} (#{v[:type]})" }
      choices << 'Done — keep this order'
      prompt!(Gum.choose(*choices, header: 'Select a variable to move:', header_style: UI::PROMPT_STYLE))
    end
    private_class_method :choose_var_to_move

    def self.move_var!(vars, selection)
      from_idx = selection.match(/^(\d+)\./)[1].to_i - 1
      item = vars.delete_at(from_idx)
      vars.insert(choose_target_position(vars, item[:name]), item)
    end
    private_class_method :move_var!

    def self.choose_target_position(vars, name)
      positions = vars.each_with_index.map { |v, i| "#{i + 1}. Before #{v[:name]}" }
      positions << "#{vars.size + 1}. At end"
      result = prompt!(Gum.choose(*positions, header: "Move \"#{name}\" to:", header_style: UI::PROMPT_STYLE))
      result.match(/^(\d+)\./)[1].to_i - 1
    end
    private_class_method :choose_target_position

    def self.confirm_next?(vars, skip_initial_prompt)
      return true if vars.empty? && skip_initial_prompt

      question = confirm_question(vars, skip_initial_prompt)
      if vars.empty?
        confirm!(question)
      else
        list_confirm!('variable', VarSummaryRenderer.rows(vars), %w[Name Type], question)
      end
    end
    private_class_method :confirm_next?

    def self.confirm_question(vars, skip_initial_prompt)
      return 'Add a variable?' if vars.empty? && !skip_initial_prompt

      'Add another variable?'
    end
    private_class_method :confirm_question

    def self.append_var!(vars)
      var = collect_one_var(vars)
      return if var.nil?

      vars << var
    end
    private_class_method :append_var!
  end
end
