# frozen_string_literal: true

require 'dry/cli'
require 'gum'
require_relative '../var_builder'
require_relative '../snippet_builder'
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
        warn e.message
        exit 1
      rescue WizardInterrupted
        puts
        UI.info('Interrupted, exiting snippet_cli.')
      end

      private

      def build_snippet(opts)
        trigger_list, is_regex, single = resolve_triggers(opts)
        replace, vars, label, comment = resolve_replacement(opts[:replace])

        SnippetBuilder.build(
          triggers: trigger_list, replace: replace, is_regex: is_regex,
          single_trigger: single, vars: vars, label: label, comment: comment
        )
      end

      def resolve_replacement(replace_opt)
        if replace_opt
          [replace_opt, [], nil, nil]
        else
          vars = VarBuilder.run
          replace = collect_replace(vars)
          label, comment = collect_advanced
          [replace, vars, label, comment]
        end
      end

      def output_result(yaml, no_clipboard)
        if no_clipboard
          puts
          puts 'Snippet YAML below.'
          puts
          puts yaml
        else
          UI.preview(yaml)
          copy_to_clipboard(yaml)
        end
      end

      def copy_to_clipboard(yaml)
        if confirm!('Copy to clipboard?')
          require 'clipboard'
          Clipboard.copy(yaml)
          UI.success('✓ Copied to clipboard')
        else
          puts
          puts 'Snippet YAML printed above, not copied.'
        end
      end

      def collect_replace(vars)
        if vars.any?
          names = vars.map { |v| "{{#{v[:name]}}}" }.join(', ')
          UI.hint("Hint: use {{var_name}} to insert a variable\nDefined: #{names}")
        end

        if confirm!('Multi-line replacement?')
          prompt!(Gum.write(header: 'Replacement', placeholder: 'Type expansion text...'))
        else
          prompt!(Gum.input(placeholder: 'Replacement text'))
        end
      end

      def collect_advanced
        return [nil, nil] unless confirm!('Add label or comment?')

        label   = prompt!(Gum.input(placeholder: 'Label (optional, press Enter to skip)'))
        comment = prompt!(Gum.input(placeholder: 'Comment (optional, press Enter to skip)'))
        [label.empty? ? nil : label, comment.empty? ? nil : comment]
      end
    end
  end
end
