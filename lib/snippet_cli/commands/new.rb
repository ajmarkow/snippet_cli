# frozen_string_literal: true

require 'dry/cli'
require 'gum'
require_relative '../var_builder'
require_relative '../snippet_builder'
require_relative '../ui'
require_relative '../wizard_helpers'
require_relative '../trigger_resolver'
require_relative '../replacement_collector'
require_relative '../espanso_config'
require_relative '../match_file_writer'
require_relative '../global_vars_writer'

module SnippetCli
  module Commands
    class New < Dry::CLI::Command
      include WizardHelpers
      include TriggerResolver
      include ReplacementCollector

      desc 'Interactive wizard to build an Espanso match entry (alias: n)'

      option :trigger,      aliases: ['-t'],  desc: 'Single trigger string'
      option :triggers,     aliases: ['-T'],  desc: 'Comma-separated list of triggers'
      option :regex,        aliases: ['-r'],  desc: 'Regex trigger pattern'
      option :replace,      aliases: ['-R'],  desc: 'Replacement text'
      option :file,         aliases: ['-f'],  desc: 'Espanso match file to check conflicts against'
      option :no_warn,      type: :boolean, default: false, aliases: ['-nw'],
                            desc: 'Skip conflict warning'
      option :save,         type: :boolean, default: false, aliases: ['-s'],
                            desc: 'Save snippet to Espanso match file'
      option :simple,       type: :boolean, default: false, aliases: ['-S'],
                            desc: 'Simple mode: skip variables, alt types, label, and comment'

      def call(**opts)
        handle_errors(ValidationError, EspansoConfigError, YamlScalar::InvalidCharacterError, NoMatchFilesError) do
          prepare_save if opts[:save]
          deliver_snippet(build_snippet(opts))
        end
      rescue InvalidFlagsError, TriggerConflictError => e
        warn e.message
        exit 1
      end

      private

      def build_snippet(opts)
        resolution = resolve_triggers(opts)
        SnippetBuilder.build(
          triggers: resolution.list, is_regex: resolution.is_regex, single_trigger: resolution.single_trigger,
          **resolve_replacement(opts[:replace], simple: opts[:simple])
        )
      end

      def resolve_replacement(replace_opt, simple: false)
        return { replace: replace_opt, vars: [], label: nil, comment: nil } if replace_opt
        return resolve_simple_replacement if simple

        result = VarBuilder.run
        @summary_clear = result[:summary_clear]
        vars = result[:vars]
        replacement = collect_replacement(vars)
        label, comment = collect_advanced
        { vars: vars, label: label, comment: comment }.merge(replacement)
      end

      def resolve_simple_replacement
        replace = collect_replace([])
        { replace: replace, vars: [], label: nil, comment: nil }
      end

      def prepare_save
        _chosen, @save_path = pick_match_file
        @global_var_names = GlobalVarsWriter.read_names(@save_path)
      end

      def deliver_snippet(yaml)
        @summary_clear&.call
        write_save(yaml) if @save_path
        output_result(yaml)
      end

      def write_save(yaml)
        MatchFileWriter.append(@save_path, yaml)
        UI.success("Saved to #{File.basename(@save_path)}")
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
end
