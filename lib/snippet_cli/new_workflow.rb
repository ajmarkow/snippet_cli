# frozen_string_literal: true

require_relative 'var_builder'
require_relative 'snippet_builder'
require_relative 'ui'
require_relative 'wizard_helpers/match_file_selector'
require_relative 'wizard_helpers/error_handler'
require_relative 'wizard_context'
require_relative 'trigger_resolver'
require_relative 'replacement_wizard'
require_relative 'espanso_config'
require_relative 'match_file_writer'
require_relative 'global_vars_writer'

module SnippetCli
  # Thin orchestrator for the new-snippet wizard.
  # Sequences collaborators (TriggerResolver, ReplacementWizard, SnippetBuilder)
  # but contains no Gum/UI calls or business rules itself.
  class NewWorkflow
    include WizardHelpers::MatchFileSelector
    include WizardHelpers::ErrorHandler
    include TriggerResolver

    def run(opts)
      handle_errors(ValidationError, EspansoConfigError, YamlScalar::InvalidCharacterError, NoMatchFilesError) do
        context = prepare_context(opts)
        yaml, summary_clear = build_snippet(opts, context)
        deliver_snippet(yaml, context, summary_clear)
      end
    end

    private

    def prepare_context(opts)
      pipe_output = SnippetCli.pipe_output
      return WizardContext.new(pipe_output: pipe_output) unless opts[:save]

      _chosen, save_path = pick_match_file
      global_var_names = GlobalVarsWriter.read_names(save_path)
      WizardContext.new(save_path: save_path, global_var_names: global_var_names, pipe_output: pipe_output)
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
      wizard = ReplacementWizard.new
      if bare
        [{ replace: wizard.collect_plain_replace, vars: [], label: nil, comment: nil }, nil]
      elsif no_vars
        [collect_no_vars_replacement(wizard, global_var_names: global_var_names), nil]
      else
        collect_full_replacement(wizard, global_var_names: global_var_names)
      end
    end

    def collect_no_vars_replacement(wizard, global_var_names: [])
      replacement = wizard.collect([], global_var_names: global_var_names)
      advanced = wizard.collect_advanced_options
      { vars: [] }.merge(advanced).merge(replacement)
    end

    def collect_full_replacement(wizard, global_var_names: [])
      result = VarBuilder.run
      vars, summary_clear = result.values_at(:vars, :summary_clear)
      replacement = wizard.collect(vars, global_var_names: global_var_names)
      advanced = wizard.collect_advanced_options
      [{ vars: vars }.merge(advanced).merge(replacement), summary_clear]
    end

    def deliver_snippet(yaml, context, summary_clear)
      summary_clear&.call
      write_save(yaml, context.save_path) if context.save_path
      UI.deliver(yaml, label: 'Snippet', context: context)
    end

    def write_save(yaml, save_path)
      MatchFileWriter.append(save_path, yaml)
      UI.success("Saved to #{File.basename(save_path)}")
    end
  end
end
