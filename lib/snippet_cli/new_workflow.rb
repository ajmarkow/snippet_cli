# frozen_string_literal: true

require 'gum'
require_relative 'var_builder'
require_relative 'snippet_builder'
require_relative 'ui'
require_relative 'wizard_helpers'
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
    include WizardHelpers
    include TriggerResolver
    include ReplacementTextCollector
    include ReplacementValidator

    def run(opts)
      handle_errors(ValidationError, EspansoConfigError, YamlScalar::InvalidCharacterError, NoMatchFilesError) do
        context = prepare_context(opts)
        yaml, summary_clear = build_snippet(opts, context)
        deliver_snippet(yaml, context.save_path, summary_clear)
      end
    rescue InvalidFlagsError, TriggerConflictError => e
      warn e.message
      exit 1
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
        opts[:replace], simple: opts[:simple], global_var_names: context.global_var_names
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

    def resolve_replacement(replace_opt, simple: false, global_var_names: [])
      return [{ replace: replace_opt, vars: [], label: nil, comment: nil }, nil] if replace_opt
      return [resolve_simple_replacement, nil] if simple

      result = VarBuilder.run
      summary_clear = result[:summary_clear]
      vars = result[:vars]
      replacement = collect_replacement(vars, global_var_names: global_var_names)
      label, comment = collect_advanced
      [{ vars: vars, label: label, comment: comment }.merge(replacement), summary_clear]
    end

    def resolve_simple_replacement
      { replace: collect_replace([]), vars: [], label: nil, comment: nil }
    end

    def collect_replacement(vars, global_var_names: [])
      if confirm!('Alternative (non-plaintext) replacement type?')
        select_alt_type(vars, global_var_names: global_var_names)
      else
        collect_replace_with_check(vars, global_var_names: global_var_names)
      end
    end

    def select_alt_type(vars, global_var_names: [])
      loop do
        type = prompt!(Gum.filter('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type'))
        if type == 'image_path' && vars.any?
          UI.info('image_path replacements do not support vars — they will be discarded.')
          next unless confirm!('Discard vars and continue with image_path?')

          return collect_alt_with_check(:image_path, [], global_var_names: global_var_names).merge(vars: [])
        end
        return collect_alt_with_check(type.to_sym, vars, global_var_names: global_var_names)
      end
    end

    def collect_replace_with_check(vars, global_var_names: [])
      collect_with_check(vars, global_var_names: global_var_names) { { replace: collect_replace(vars) } }
    end

    def collect_alt_with_check(type, vars, global_var_names: [])
      collect_with_check(vars, global_var_names: global_var_names) { { type => collect_alt_value(type) } }
    end

    def collect_with_check(vars, global_var_names: [])
      clear = nil
      loop do
        clear&.call
        replacement = yield
        clear = var_error_clear(vars, replacement, global_var_names: global_var_names)
        return replacement if clear.nil?
      end
    end

    def deliver_snippet(yaml, save_path, summary_clear)
      summary_clear&.call
      write_save(yaml, save_path) if save_path
      output_result(yaml)
    end

    def write_save(yaml, save_path)
      MatchFileWriter.append(save_path, yaml)
      UI.success("Saved to #{File.basename(save_path)}")
    end

    def output_result(yaml)
      UI.deliver(yaml, label: 'Snippet')
    end

    def collect_advanced
      label   = optional_prompt('Add a label?')   { prompt!(Gum.input(placeholder: 'Label')) }
      comment = optional_prompt('Add a comment?') { prompt!(Gum.input(placeholder: 'Comment')) }
      [label, comment]
    end
  end
end
