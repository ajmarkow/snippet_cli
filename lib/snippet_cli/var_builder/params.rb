# frozen_string_literal: true

require 'gum'
require_relative 'form_fields'

module SnippetCli
  module VarBuilder
    # Interactive collection of Espanso `params` hashes per variable type.
    module Params
      COLLECTORS = {
        'echo' => ->(b) { { echo: b.prompt!(Gum.input(placeholder: 'echo value')) } },
        'random' => ->(b) { { choices: Params.collect_list(b, 'choice value') } },
        'choice' => ->(b) { { values: Params.collect_list(b, 'value') } }
      }.freeze

      def self.collect(builder, type)
        collector = COLLECTORS[type]
        return collector.call(builder) if collector

        case type
        when 'date'      then date(builder)
        when 'shell'     then shell(builder)
        when 'script'    then script(builder)
        when 'form'      then form(builder)
        when 'clipboard' then clipboard(builder)
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
        params = { args: raw.to_s.lines.map(&:chomp).reject(&:empty?) }
        params[:trim] = true if builder.confirm!('Trim whitespace from output?')
        params
      end
      private_class_method :script

      def self.date(builder)
        params = { format: builder.prompt!(Gum.input(placeholder: 'date format (e.g. %Y-%m-%d)')) }
        date_optional_params(builder, params)
      end
      private_class_method :date

      def self.date_optional_params(builder, params)
        if builder.confirm!('Add an offset?')
          params[:offset] = builder.prompt!(Gum.input(placeholder: 'offset in seconds (e.g. 86400)')).to_i
        end
        if builder.confirm!('Add a locale?')
          params[:locale] = builder.prompt!(Gum.input(placeholder: 'BCP47 locale (e.g. en-US, ja-JP)'))
        end
        if builder.confirm!('Add a timezone?')
          params[:tz] = builder.prompt!(Gum.input(placeholder: 'IANA timezone (e.g. America/New_York)'))
        end
        params
      end
      private_class_method :date_optional_params

      def self.form(builder)
        layout = if builder.confirm!('Multi-line form?')
                   builder.prompt!(Gum.write(header: 'Form layout (use [[field_name]] for fields)'))
                 else
                   builder.prompt!(Gum.input(placeholder: 'Form layout (use [[field_name]] for fields)'))
                 end
        fields = FormFields.collect(builder, layout)
        params = { layout: layout }
        params[:fields] = fields if fields.any?
        params
      end
      private_class_method :form

      def self.clipboard(_builder)
        {}
      end
      private_class_method :clipboard

      def self.debug_trim(builder, params)
        params[:debug] = true if builder.confirm!('Enable debug mode?')
        params[:trim] = true if builder.confirm!('Trim whitespace from output?')
        params
      end
      private_class_method :debug_trim
    end
  end
end
