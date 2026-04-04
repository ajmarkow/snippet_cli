# frozen_string_literal: true

require 'dry/cli'
require 'gum'
require_relative '../var_builder'
require_relative '../snippet_builder'
require_relative '../var_usage_checker'
require_relative '../ui'
require_relative '../wizard_helpers'
require_relative '../trigger_resolver'

module SnippetCli
  module Commands
    class New < Dry::CLI::Command
      include WizardHelpers
      include TriggerResolver

      desc 'Interactive wizard to build an Espanso match entry (alias: n)'

      option :trigger,      aliases: ['-t'],  desc: 'Single trigger string'
      option :triggers,     aliases: ['-T'],  desc: 'Comma-separated list of triggers'
      option :regex,        aliases: ['-r'],  desc: 'Regex trigger pattern'
      option :replace,      aliases: ['-R'],  desc: 'Replacement text'
      option :file,         aliases: ['-f'],  desc: 'Espanso match file to check conflicts against'
      option :no_warn,      type: :boolean, default: false, aliases: ['-nw'],
                            desc: 'Skip conflict warning'

      def call(**opts)
        yaml = build_snippet(opts)
        VarBuilder.summary_clear.call
        output_result(yaml)
      rescue ValidationError => e
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

        vars = VarBuilder.run
        replacement = collect_replacement(vars)
        label, comment = collect_advanced
        { vars: vars, label: label, comment: comment }.merge(replacement)
      end

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
        return prompt!(Gum.input(placeholder: '/path/to/image.png')) if type == :image_path

        prompt!(Gum.write(header: type.to_s.capitalize, placeholder: "Enter #{type}..."))
      end

      def var_error_clear(vars, replacement)
        errors = VarUsageChecker.match_warnings(vars, replacement)
        return nil if errors.empty?

        errors.each { |e| UI.warning(e) }
        return nil if confirm!('Are you sure you want to continue?')

        -> {}
      end

      def output_result(yaml)
        pipe = SnippetCli.pipe_output
        if pipe
          pipe.print yaml
        else
          UI.info('Snippet YAML below.')
          UI.format_code(yaml)
        end
      end

      def collect_replace(_vars)
        use_multiline = confirm!('Multi-line replacement?')
        return prompt!(Gum.write(header: 'Replacement', placeholder: 'Type expansion text...')) if use_multiline

        prompt!(Gum.input(placeholder: 'Replacement text'))
      end

      def collect_advanced
        label   = confirm!('Add a label?')   ? prompt!(Gum.input(placeholder: 'Label'))   : nil
        comment = confirm!('Add a comment?') ? prompt!(Gum.input(placeholder: 'Comment')) : nil
        [label, comment]
      end
    end
  end
end
