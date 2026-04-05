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

      def call(**opts)
        yaml = build_snippet(opts)
        @summary_clear&.call
        save_snippet(yaml) if opts[:save]
        output_result(yaml)
      rescue ValidationError, EspansoConfigError => e
        UI.error(e.message)
        exit 1
      rescue WizardInterrupted
        puts
        UI.error('Interrupted, exiting snippet_cli.')
      end

      private

      def build_snippet(opts)
        trigger_list, is_regex, single = resolve_triggers(opts)
        SnippetBuilder.build(
          triggers: trigger_list, is_regex: is_regex, single_trigger: single, **resolve_replacement(opts[:replace])
        )
      end

      def resolve_replacement(replace_opt)
        return { replace: replace_opt, vars: [], label: nil, comment: nil } if replace_opt

        result = VarBuilder.run
        @summary_clear = result[:summary_clear]
        vars = result[:vars]
        replacement = collect_replacement(vars)
        label, comment = collect_advanced
        { vars: vars, label: label, comment: comment }.merge(replacement)
      end

      def save_snippet(yaml)
        files = EspansoConfig.match_files
        if files.empty?
          UI.error('No match files found in Espanso config.')
          exit 1
        end

        basenames = files.map { |f| File.basename(f) }
        chosen = prompt!(Gum.filter(*basenames, header: 'Save to which match file?'))
        full_path = files.find { |f| File.basename(f) == chosen }

        MatchFileWriter.append(full_path, yaml)
        UI.success("Saved to #{chosen}")
      end

      def output_result(yaml)
        UI.deliver(yaml, label: 'Snippet')
      end

      def collect_advanced
        label   = confirm!('Add a label?')   ? prompt!(Gum.input(placeholder: 'Label'))   : nil
        comment = confirm!('Add a comment?') ? prompt!(Gum.input(placeholder: 'Comment')) : nil
        [label, comment]
      end
    end
  end
end
