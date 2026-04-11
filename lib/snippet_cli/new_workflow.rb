# frozen_string_literal: true

require 'gum'
require_relative 'var_builder'
require_relative 'snippet_builder'
require_relative 'ui'
require_relative 'wizard_helpers/prompt_helpers'
require_relative 'wizard_helpers/match_file_selector'
require_relative 'wizard_helpers/error_handler'
require_relative 'wizard_context'
require_relative 'trigger_resolver'
require_relative 'replacement_text_collector'
require_relative 'replacement_validator'
require_relative 'espanso_config'
require_relative 'match_file_writer'
require_relative 'global_vars_writer'

module SnippetCli
  # Orchestrates the full new-snippet wizard.
  # Receives all state via WizardContext; no implicit instance-variable sharing.
  class NewWorkflow
    include WizardHelpers::MatchFileSelector
    include WizardHelpers::ErrorHandler
    include TriggerResolver
    include ReplacementTextCollector
    include ReplacementValidator

    def run(opts)
      handle_errors(ValidationError, EspansoConfigError, YamlScalar::InvalidCharacterError, NoMatchFilesError) do
        context = prepare_context(opts)
        yaml, summary_clear = build_snippet(opts, context)
        deliver_snippet(yaml, context.save_path, summary_clear)
      end
    end

    private

    def prepare_context(opts)
      return WizardContext.new unless opts[:save]

      _chosen, save_path = pick_match_file
      global_var_names = GlobalVarsWriter.read_names(save_path)
      WizardContext.new(save_path: save_path, global_var_names: global_var_names)
    end

    def build_snippet(opts, context)
      resolution = resolve_triggers(opts)
      replacement_hash, summary_clear = resolve_replacement(
        no_vars: opts[:no_vars], bare: opts[:bare], global_var_names: context.global_var_names
      )
      [assemble_yaml(resolution, replacement_hash), summary_clear]
    end

    def assemble_yaml(resolution, replacement_hash)
      SnippetBuilder.build(
        triggers: resolution.list,
        is_regex: resolution.is_regex,
        single_trigger: resolution.single_trigger,
        **replacement_hash
      )
    end

    def resolve_replacement(no_vars: false, bare: false, global_var_names: [])
      return [{ replace: collect_replace([]), vars: [], label: nil, comment: nil }, nil] if bare
      return [resolve_no_vars_replacement(global_var_names: global_var_names), nil] if no_vars

      result = VarBuilder.run
      vars, summary_clear = result.values_at(:vars, :summary_clear)
      replacement = collect_replacement(vars, global_var_names: global_var_names)
      advanced = collect_advanced
      [{ vars: vars }.merge(advanced).merge(replacement), summary_clear]
    end

    def resolve_no_vars_replacement(global_var_names: [])
      replacement = collect_replacement([], global_var_names: global_var_names)
      advanced = collect_advanced
      { vars: [] }.merge(advanced).merge(replacement)
    end

    def collect_replacement(vars, global_var_names: [])
      if confirm!('Alternative (non-plaintext) replacement type?')
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

      UI.info('image_path replacements do not support vars — they will be discarded.')
      !confirm!('Discard vars and continue with image_path?')
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

    def deliver_snippet(yaml, save_path, summary_clear)
      summary_clear&.call
      write_save(yaml, save_path) if save_path
      UI.deliver(yaml, label: 'Snippet')
    end

    def write_save(yaml, save_path)
      MatchFileWriter.append(save_path, yaml)
      UI.success("Saved to #{File.basename(save_path)}")
    end

    def collect_advanced
      return { label: nil, comment: nil, search_terms: [] } unless confirm!('Show advanced options?')

      {
        label: optional_prompt('Add a label?') { prompt!(Gum.input(placeholder: 'Label')) },
        comment: optional_prompt('Add a comment?') { prompt!(Gum.input(placeholder: 'Comment')) },
        search_terms: collect_search_terms,
        word: (true if confirm!('Word trigger?')),
        propagate_case: (true if confirm!('Propagate case?'))
      }
    end
  end
end
