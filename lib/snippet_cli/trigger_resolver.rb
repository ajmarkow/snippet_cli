# frozen_string_literal: true

require_relative 'conflict_detector'
require_relative 'ui'
require_relative 'wizard_helpers'

module SnippetCli
  # Resolves trigger input from CLI flags or interactive prompts.
  module TriggerResolver
    include WizardHelpers

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
        trigger = prompt!(Gum.input(placeholder: ':(gr|great)ing'))
        check_conflicts([trigger], file, no_warn)
        return [[trigger], true]
      end

      collect_regular_triggers(file, no_warn)
    end

    def collect_regular_triggers(file, no_warn)
      UI.info(
        "Multiple triggers can share one replacement.\n" \
        "Enter them one at a time, you'll be asked to add another after each."
      )
      triggers = prompt_trigger_loop
      check_conflicts(triggers, file, no_warn)
      [triggers, false]
    end

    def prompt_trigger_loop
      triggers = []
      loop do
        t = Gum.input(placeholder: ':trigger')
        raise WizardInterrupted if t.nil?

        triggers << t unless t.empty?
        break unless confirm!('Add another trigger?')
      end
      triggers
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
