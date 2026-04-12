# frozen_string_literal: true

require 'gum'
require_relative 'ui'
require_relative 'wizard_helpers/prompt_helpers'
require_relative 'wizard_helpers/validation_loop'
require_relative 'replacement_text_collector'
require_relative 'replacement_validator'

module SnippetCli
  # Handles all interactive replacement collection for the new-snippet wizard.
  # Keeps Gum/UI calls out of NewWorkflow so orchestration and domain logic
  # can be read and tested without UI concerns.
  class ReplacementWizard
    include WizardHelpers::PromptHelpers
    include WizardHelpers::ValidationLoop
    include ReplacementTextCollector
    include ReplacementValidator

    # Collects a replacement hash (type + value) with var validation.
    # Returns e.g. { replace: '...' } or { markdown: '...' } or { image_path: '...', vars: [] }.
    def collect(vars, global_var_names: [])
      collect_replacement(vars, global_var_names: global_var_names)
    end

    # Collects advanced snippet options (label, comment, search_terms, word, propagate_case).
    # Returns a hash with all keys present (nil/false/[] for declined options).
    def collect_advanced_options
      return { label: nil, comment: nil, search_terms: [] } unless confirm!('Show advanced options?')

      advanced_options_hash
    end

    # Collects plain replacement text only (used for --bare mode).
    def collect_plain_replace
      collect_replace([])
    end

    private

    def advanced_options_hash
      {
        label: optional_label,
        comment: optional_comment,
        search_terms: collect_search_terms,
        word: (true if confirm!('Word trigger?')),
        propagate_case: (true if confirm!('Propagate case?'))
      }
    end

    def optional_label
      optional_prompt('Add a label?') do
        prompt!(Gum.input(placeholder: 'Label', prompt_style: UI::PROMPT_STYLE, header_style: UI::PROMPT_STYLE))
      end
    end

    def optional_comment
      optional_prompt('Add a comment?') do
        prompt!(Gum.input(placeholder: 'Comment', prompt_style: UI::PROMPT_STYLE, header_style: UI::PROMPT_STYLE))
      end
    end

    def collect_replacement(vars, global_var_names: [])
      if confirm!('Use a non-plaintext replacement type?')
        select_alt_type(vars, global_var_names: global_var_names)
      else
        collect_with_check(vars, global_var_names: global_var_names) { { replace: collect_replace(vars) } }
      end
    end

    def select_alt_type(vars, global_var_names: [])
      type = prompt!(Gum.filter('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type'))
      return select_alt_type(vars, global_var_names: global_var_names) if image_path_discard_declined?(type, vars)

      if type == 'image_path'
        collect_alt_with_check(:image_path, [], global_var_names: global_var_names).merge(vars: [])
      else
        collect_alt_with_check(type.to_sym, vars, global_var_names: global_var_names)
      end
    end

    def image_path_discard_declined?(type, vars)
      return false unless type == 'image_path' && vars.any?

      UI.info('image_path does not support vars — they will be dropped.')
      !confirm!('Drop vars and continue with image_path?')
    end

    def collect_alt_with_check(type, vars, global_var_names: [])
      collect_with_check(vars, global_var_names: global_var_names) { { type => collect_alt_value(type) } }
    end

    def collect_with_check(vars, global_var_names: [])
      prompt_until_valid do
        replacement = yield
        [replacement, var_error_clear(vars, replacement, global_var_names: global_var_names)]
      end
    end
  end
end
