# frozen_string_literal: true

require 'English'
require 'gum'
require_relative 'ui'

module SnippetCli
  module VarBuilder
    VAR_TYPES = %w[echo shell date random choice script form].freeze

    SHELLS_BY_PLATFORM = {
      macos: %w[sh bash pwsh nu],
      linux: %w[sh bash pwsh nu],
      windows: %w[cmd powershell pwsh wsl nu]
    }.freeze

    PARAM_COLLECTORS = {
      'echo' => ->(b) { { value: b.prompt!(Gum.input(placeholder: 'echo value')) } },
      'date' => ->(b) { { format: b.prompt!(Gum.input(placeholder: 'date format (e.g. %Y-%m-%d)')) } },
      'random' => ->(b) { { choices: b.collect_list('choice value') } },
      'choice' => ->(b) { { values: b.collect_list('value') } },
      'form' => ->(b) { { layout: b.prompt!(Gum.input(placeholder: 'form layout template')) } }
    }.freeze

    # Interactive loop that collects Espanso variable definitions.
    # Returns an Array of var hashes: [{ name:, type:, params: }, ...]
    # Raises WizardInterrupted if the user presses Ctrl+C.
    def self.run
      vars = []
      loop do
        puts
        break unless confirm!(vars.empty? ? 'Add a variable?' : 'Add another variable?')

        var = collect_one_var(vars)
        next unless var

        vars << var
        show_summary(vars)
      end
      vars
    end

    def self.platform_shells
      case RUBY_PLATFORM
      when /darwin/             then SHELLS_BY_PLATFORM[:macos]
      when /mswin|mingw|cygwin/ then SHELLS_BY_PLATFORM[:windows]
      else SHELLS_BY_PLATFORM[:linux]
      end
    end

    def self.collect_one_var(existing)
      puts
      name = prompt!(Gum.input(placeholder: 'var name (no spaces)'))
      if existing.any? { |v| v[:name] == name }
        warn "Variable '#{name}' already defined — skipping"
        return nil
      end
      puts
      type = prompt!(Gum.filter(*VAR_TYPES, limit: 1, header: 'Variable type'))
      puts
      { name: name, type: type, params: collect_params(type) }
    end
    private_class_method :collect_one_var

    def self.prompt!(value) = value.nil? ? raise(WizardInterrupted) : value

    def self.confirm!(text)
      result = Gum.confirm(text)
      raise WizardInterrupted if $CHILD_STATUS.respond_to?(:exitstatus) && $CHILD_STATUS.exitstatus == 130

      result
    end
    private_class_method :confirm!

    def self.collect_params(type)
      collector = PARAM_COLLECTORS[type]
      return collector.call(self) if collector

      case type
      when 'shell'  then collect_shell_params
      when 'script' then collect_script_params
      else {}
      end
    end
    private_class_method :collect_params

    def self.collect_shell_params
      shell = prompt!(Gum.filter(*platform_shells, limit: 1, header: 'Select shell'))
      cmd = prompt!(Gum.input(placeholder: 'shell command'))
      collect_debug_trim(cmd: cmd, shell: shell)
    end
    private_class_method :collect_shell_params

    def self.collect_script_params
      raw = prompt!(
        Gum.write(
          header: 'Script args — one per line, each line becomes a separate argument',
          placeholder: '/path/to/script'
        )
      )
      collect_debug_trim(args: raw.to_s.lines.map(&:chomp).reject(&:empty?))
    end
    private_class_method :collect_script_params

    def self.collect_debug_trim(params)
      params[:debug] = true if confirm!('Enable debug mode?')
      params[:trim] = true if confirm!('Trim whitespace from output?')
      params
    end
    private_class_method :collect_debug_trim

    def self.collect_list(item_label)
      items = []
      loop do
        val = Gum.input(placeholder: "#{item_label} (blank to finish)")
        break if val.nil? || val.empty?

        items << val
      end
      items
    end

    def self.show_summary(vars)
      rows = vars.map { |var| [var[:name], var[:type]] }
      Gum.table(rows, columns: %w[Name Type], print: true)
    end
    private_class_method :show_summary
  end
end
