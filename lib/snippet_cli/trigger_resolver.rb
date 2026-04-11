# frozen_string_literal: true

require_relative 'ui'
require_relative 'wizard_helpers'

module SnippetCli
  # Resolves trigger input from CLI flags or interactive prompts.
  module TriggerResolver
    TriggerResolution = Struct.new(:list, :is_regex, :single_trigger)

    include WizardHelpers

    RUST_REGEX_GUIDANCE = "Espanso uses Rust Regex syntax, ensure this is a valid Rust regex.\n" \
                          'https://docs.rs/regex/1.1.8/regex/#syntax'

    private

    def resolve_triggers(opts)
      resolve_triggers_interactively(opts)
    end

    def resolve_triggers_interactively(_opts)
      type = prompt!(Gum.choose('regular', 'regex', header: "Trigger type?\n"))
      list, is_regex = collect_triggers(type)
      TriggerResolution.new(list, is_regex, false)
    end

    def collect_triggers(type)
      if type == 'regex'
        UI.info(RUST_REGEX_GUIDANCE)
        puts
        trigger = prompt_non_empty_trigger('r"^(hello|bye)$"')
        return [[trigger], true]
      end

      [prompt_trigger_loop, false]
    end

    def prompt_non_empty_trigger(placeholder, header: nil)
      prompt_non_empty('Trigger cannot be empty. Please enter a trigger string.') do
        prompt!(Gum.input(**trigger_input_opts(placeholder, header)))
      end
    end

    def multi_trigger_header
      "Multiple triggers can share one replacement.\n" \
        "Enter them one at a time, you'll be asked to add another after each.\n"
    end

    def trigger_input_opts(placeholder, header)
      opts = { placeholder: placeholder }
      opts[:header] = header if header
      opts
    end

    def prompt_trigger_loop
      triggers = []
      loop do
        header = triggers.empty? ? multi_trigger_header : nil
        triggers << prompt_non_empty_trigger(':trigger', header: header)
        break unless list_confirm!('trigger', triggers.map { |t| [t] }, ['Trigger'], 'Add another trigger?')
      end
      triggers
    end
  end
end
