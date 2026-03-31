# frozen_string_literal: true

require_relative 'conflict_detector'
require_relative 'table_formatter'
require_relative 'ui'
require_relative 'wizard_helpers'

module SnippetCli
  # Resolves trigger input from CLI flags or interactive prompts.
  module TriggerResolver
    include WizardHelpers

    RUST_REGEX_GUIDANCE = "Espanso uses Rust Regex syntax, ensure this is a valid Rust regex.\n" \
                          'https://docs.rs/regex/1.1.8/regex/#syntax'

    private

    def resolve_triggers(opts)
      validate_trigger_flags!(opts[:trigger], opts[:triggers], opts[:regex])

      if opts[:trigger] || opts[:triggers] || opts[:regex]
        resolve_triggers_from_flags(opts)
      else
        resolve_triggers_interactively(opts)
      end
    end

    def resolve_triggers_from_flags(opts)
      list, is_regex, single = resolve_trigger_flags(opts)
      check_conflicts(list, opts[:file], opts[:no_warn])
      [list, is_regex, single]
    end

    def resolve_triggers_interactively(opts)
      type = prompt!(Gum.choose('regular', 'regex', header: 'Trigger type?'))
      list, is_regex = collect_triggers(type, opts[:file], opts[:no_warn])
      [list, is_regex, false]
    end

    def validate_trigger_flags!(trigger, triggers, regex)
      provided = [trigger, triggers, regex].compact
      return if provided.length <= 1

      warn 'Error: --trigger, --triggers, and --regex are mutually exclusive. Provide only one.'
      exit 1
    end

    def resolve_trigger_flags(opts)
      if opts[:regex]
        [[opts[:regex]], true, false]
      elsif opts[:triggers]
        [opts[:triggers].split(',').map(&:strip), false, false]
      else
        [[opts[:trigger]], false, true]
      end
    end

    def collect_triggers(type, file, no_warn)
      if type == 'regex'
        UI.info(RUST_REGEX_GUIDANCE)
        puts
        trigger = prompt_non_empty_trigger('r"^(hello|bye)$"')

        check_conflicts([trigger], file, no_warn)
        return [[trigger], true]
      end

      collect_regular_triggers(file, no_warn)
    end

    def collect_regular_triggers(file, no_warn)
      triggers = prompt_trigger_loop
      check_conflicts(triggers, file, no_warn)
      [triggers, false]
    end

    def prompt_non_empty_trigger(placeholder, header: nil)
      loop do
        opts = { placeholder: placeholder }
        opts[:header] = header if header
        opts[:header_style] = { foreground: '212' } if header
        t = prompt!(Gum.input(**opts))
        return t unless t.strip.empty?

        UI.info('Trigger cannot be empty. Please enter a trigger string.')
      end
    end

    def prompt_trigger_loop
      triggers = []
      UI.info("Multiple triggers can share one replacement.\n" \
              "Enter them one at a time, you'll be asked to add another after each.")
      loop do
        triggers << prompt_non_empty_trigger(':trigger')
        break unless confirm!(build_trigger_confirm_prompt(triggers))
      end
      triggers
    end

    def build_trigger_confirm_prompt(triggers)
      rows = triggers.map { |t| [t] }
      table = TableFormatter.render(rows, headers: ['Trigger'])
      "Current triggers:\n\n#{table}\n\nAdd another trigger?"
    end

    def check_conflicts(triggers, file, no_warn)
      return unless file && File.exist?(file)

      existing = ConflictDetector.extract_triggers(File.read(file))
      existing_triggers = existing.map { |e| e[:trigger] }
      conflicts = triggers.select { |t| existing_triggers.include?(t) }
      return if conflicts.empty?

      warn "Warning: trigger(s) #{conflicts.join(', ')} already exist in #{file}"
      exit 1 unless no_warn
    end
  end
end
