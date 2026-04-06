# frozen_string_literal: true

require_relative 'ui'
require_relative 'var_usage_checker'
require_relative 'wizard_helpers'

module SnippetCli
  # Collects replacement text from interactive prompts with validation.
  module ReplacementCollector
    include WizardHelpers

    EMPTY_REPLACE_MSG = 'Replacement cannot be empty. Please enter replacement text.'

    private

    def collect_replacement(vars)
      return select_alt_type(vars) if confirm!('Alternative (non-plaintext) replacement type?')

      collect_replace_with_check(vars)
    end

    def select_alt_type(vars)
      loop do
        type = prompt!(Gum.filter('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type'))
        if type == 'image_path' && vars.any?
          UI.info('image_path replacements do not support vars — they will be discarded.')
          next unless confirm!('Discard vars and continue with image_path?')

          return collect_alt_with_check(:image_path, []).merge(vars: [])
        end
        return collect_alt_with_check(type.to_sym, vars)
      end
    end

    def collect_replace_with_check(vars)
      clear = nil
      loop do
        clear&.call
        replacement = { replace: collect_replace(vars) }
        clear = var_error_clear(vars, replacement)
        return replacement if clear.nil?
      end
    end

    def collect_alt_with_check(type, vars)
      clear = nil
      loop do
        clear&.call
        replacement = { type => collect_alt_value(type) }
        clear = var_error_clear(vars, replacement)
        return replacement if clear.nil?
      end
    end

    def collect_alt_value(type)
      prompt_non_empty_replace { prompt_alt_input(type) }
    end

    def prompt_alt_input(type)
      if type == :image_path
        prompt!(Gum.input(placeholder: '/path/to/image.png'))
      else
        prompt!(Gum.write(header: type.to_s.capitalize, placeholder: "Enter #{type}..."))
      end
    end

    def var_error_clear(vars, replacement)
      gv_names = defined?(@global_var_names) ? @global_var_names : []
      errors = VarUsageChecker.match_warnings(vars, replacement, global_var_names: gv_names)
      return nil if errors.empty?

      errors.each { |e| UI.warning(e) }
      return nil if confirm!('Are you sure you want to continue?')

      -> {}
    end

    def collect_replace(_vars)
      prompt_non_empty_replace do
        use_multiline = confirm!('Multi-line replacement?')
        if use_multiline
          prompt!(Gum.write(header: 'Replacement', placeholder: 'Type expansion text...'))
        else
          prompt!(Gum.input(placeholder: 'Replacement text'))
        end
      end
    end

    def prompt_non_empty_replace(&)
      prompt_non_empty(EMPTY_REPLACE_MSG, &)
    end
  end
end
