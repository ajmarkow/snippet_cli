# frozen_string_literal: true

require 'gum'
require_relative 'wizard_helpers/prompt_helpers'
require_relative 'wizard_helpers/validation_loop'

module SnippetCli
  # Collects replacement text from interactive Gum prompts.
  # Handles plain-text (single and multi-line) and alt-type (markdown, html, image_path) inputs.
  module ReplacementTextCollector
    include WizardHelpers::PromptHelpers
    include WizardHelpers::ValidationLoop

    EMPTY_REPLACE_WARNING = 'Replace value is empty. Continue with no replacement text?'

    private

    def collect_replace(_vars)
      loop do
        value = prompt!(gum_replace_input(confirm!('Multi-line replacement?')))
        next if value.strip.empty? && !confirm!(EMPTY_REPLACE_WARNING)

        return value
      end
    end

    def gum_replace_input(multiline)
      style = UI::PROMPT_STYLE
      if multiline
        Gum.write(header: 'Replacement', placeholder: 'Type expansion text...',
                  prompt_style: style, header_style: style)
      else
        Gum.input(placeholder: 'Replacement text', prompt_style: style, header_style: style)
      end
    end

    def collect_alt_value(type)
      prompt_non_empty_replace { prompt_alt_input(type) }
    end

    def prompt_alt_input(type)
      style = UI::PROMPT_STYLE
      if type == :image_path
        prompt!(Gum.input(placeholder: '/path/to/image.png', prompt_style: style, header_style: style))
      else
        prompt!(Gum.write(header: type.to_s.capitalize, placeholder: "Enter #{type}...",
                          prompt_style: style, header_style: style))
      end
    end

    def prompt_non_empty_replace(&)
      prompt_non_empty('Replacement cannot be empty. Please enter replacement text.', &)
    end
  end
end
