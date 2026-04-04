# frozen_string_literal: true

require 'gum'

module SnippetCli
  module VarBuilder
    # Interactive collection of Espanso `params` hashes per variable type.
    module Params
      COLLECTORS = {
        'echo' => ->(b) { { echo: b.prompt!(Gum.input(placeholder: 'echo value')) } },
        'random' => ->(b) { { choices: Params.collect_list(b, 'choice value') } },
        'choice' => ->(b) { { values: Params.collect_list(b, 'value') } },
        'form' => ->(b) { { layout: b.prompt!(Gum.write(header: 'Form layout (use [[field_name]] for fields)')) } }
      }.freeze

      def self.collect(builder, type)
        collector = COLLECTORS[type]
        return collector.call(builder) if collector

        case type
        when 'date'   then date(builder)
        when 'shell'  then shell(builder)
        when 'script' then script(builder)
        else {}
        end
      end

      def self.collect_list(builder, item_label)
        items = []
        loop do
          val = Gum.input(placeholder: "#{item_label} (blank to finish)")
          break if val&.empty?

          items << builder.prompt!(val)
        end
        items
      end

      def self.shell(builder)
        sh = builder.prompt!(Gum.filter(*builder.platform_shells, limit: 1, header: 'Select shell'))
        cmd = builder.prompt!(Gum.input(placeholder: 'shell command'))
        debug_trim(builder, cmd: cmd, shell: sh)
      end
      private_class_method :shell

      def self.script(builder)
        raw = builder.prompt!(
          Gum.write(
            header: 'Script args — one per line, each line becomes a separate argument',
            placeholder: '/path/to/script'
          )
        )
        debug_trim(builder, args: raw.to_s.lines.map(&:chomp).reject(&:empty?))
      end
      private_class_method :script

      def self.date(builder)
        params = { format: builder.prompt!(Gum.input(placeholder: 'date format (e.g. %Y-%m-%d)')) }
        if builder.confirm!('Add an offset?')
          params[:offset] = builder.prompt!(Gum.input(placeholder: 'offset in seconds (e.g. 86400)')).to_i
        end
        if builder.confirm!('Add a locale?')
          params[:locale] = builder.prompt!(Gum.input(placeholder: 'BCP47 locale (e.g. en-US, ja-JP)'))
        end
        params
      end
      private_class_method :date

      def self.debug_trim(builder, params)
        params[:debug] = true if builder.confirm!('Enable debug mode?')
        params[:trim] = true if builder.confirm!('Trim whitespace from output?')
        params
      end
      private_class_method :debug_trim
    end
  end
end
