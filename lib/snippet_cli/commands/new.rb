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
      option :no_clipboard, type: :boolean, default: false, aliases: ['-nc'],
                            desc: 'Print to stdout instead of clipboard'

      def call(**opts)
        yaml = build_snippet(opts)
        output_result(yaml, opts[:no_clipboard])
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
        rep = resolve_replacement(opts[:replace])

        SnippetBuilder.build(
          triggers: trigger_list, is_regex: is_regex, single_trigger: single, **rep
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
        if confirm!('Alternative (non-plaintext) replacement type?')
          type = prompt!(Gum.filter('markdown', 'html', 'image_path', limit: 1, header: 'Replacement type'))
          collect_alt_with_check(type.to_sym, vars)
        else
          collect_replace_with_check(vars)
        end
      end

      def collect_replace_with_check(vars)
        loop do
          replacement = { replace: collect_replace(vars) }
          return replacement if var_warnings_cleared?(vars, replacement)
        end
      end

      def collect_alt_with_check(type, vars)
        loop do
          replacement = { type => collect_alt_value(type) }
          return replacement if var_warnings_cleared?(vars, replacement)
        end
      end

      def collect_alt_value(type)
        case type
        when :image_path
          prompt!(Gum.input(placeholder: '/path/to/image.png'))
        else
          prompt!(Gum.write(header: type.to_s.capitalize, placeholder: "Enter #{type}..."))
        end
      end

      def var_warnings_cleared?(vars, replacement)
        warnings = VarUsageChecker.match_warnings(vars, replacement)
        return true if warnings.empty?

        clear = UI.cursor_checkpoint
        warnings.each { |w| UI.warning(w) }
        confirmed = confirm!('Are you sure you want to continue?')
        clear.call
        confirmed
      end

      def output_result(yaml, no_clipboard)
        UI.info('Snippet YAML below.')
        UI.format_code(yaml)
        copy_to_clipboard(yaml) unless no_clipboard
      end

      def copy_to_clipboard(yaml)
        if confirm!('Copy to clipboard?')
          require 'clipboard'
          Clipboard.copy(yaml)
          UI.success('Copied to clipboard.')
        else
          UI.info('Not copied to clipboard.')
        end
      end

      def collect_replace(_vars)
        if confirm!('Multi-line replacement?')
          prompt!(Gum.write(header: 'Replacement', placeholder: 'Type expansion text...'))
        else
          prompt!(Gum.input(placeholder: 'Replacement text'))
        end
      end

      def collect_advanced
        label   = confirm!('Add a label?')   ? prompt!(Gum.input(placeholder: 'Label'))   : nil
        comment = confirm!('Add a comment?') ? prompt!(Gum.input(placeholder: 'Comment')) : nil
        [label, comment]
      end
    end
  end
end
