# frozen_string_literal: true

require 'gum'
require_relative 'param_schema'
require_relative 'form_fields'

module SnippetCli
  module VarBuilder
    # Interactive collection of Espanso `params` hashes per variable type.
    module Params
      COLLECTORS = {
        'echo' => lambda { |b|
          { echo: b.prompt!(Gum.input(placeholder: 'echo value', prompt_style: UI::PROMPT_STYLE,
                                      header_style: UI::PROMPT_STYLE)) }
        },
        'random' => lambda { |b|
          raw = b.prompt!(Gum.write(header: 'Put one random choice per line', prompt_style: UI::PROMPT_STYLE,
                                    header_style: UI::PROMPT_STYLE))
          { choices: raw.to_s.lines.map(&:chomp).reject(&:empty?) }
        },
        'choice' => lambda { |b|
          raw = b.prompt!(Gum.write(header: 'Put one choice per line', prompt_style: UI::PROMPT_STYLE, header_style: UI::PROMPT_STYLE))
          { values: raw.to_s.lines.map(&:chomp).reject(&:empty?) }
        }
      }.freeze

      def self.collect(builder, type)
        params = collect_raw(builder, type)
        validate!(type, params)
        params
      end

      def self.validate!(type, params)
        return unless ParamSchema.known_type?(type)
        return if ParamSchema.valid_params?(type, params)

        raise SnippetCli::InvalidParamsError,
              "Invalid params #{params.inspect} for var type '#{type}'"
      end

      def self.collect_raw(builder, type)
        collector = COLLECTORS[type]
        return collector.call(builder) if collector

        case type
        when 'date'      then date(builder)
        when 'shell'     then shell(builder)
        when 'script'    then script(builder)
        when 'form'      then form(builder)
        else {}
        end
      end

      def self.collect_list(builder, item_name)
        raw = builder.prompt!(Gum.write(header: "Put one #{item_name} per line", prompt_style: UI::PROMPT_STYLE,
                                        header_style: UI::PROMPT_STYLE))
        raw.to_s.lines.map(&:chomp).reject(&:empty?)
      end

      def self.shell(builder)
        sh = builder.prompt!(Gum.filter(*builder.platform_shells, limit: 1, header: 'Select shell'))
        cmd = builder.prompt!(Gum.input(placeholder: 'shell command', prompt_style: UI::PROMPT_STYLE, header_style: UI::PROMPT_STYLE))
        debug_trim(builder, cmd: cmd, shell: sh)
      end

      def self.script(builder)
        gum = Gum.write(header: 'Script args — one per line',
                        placeholder: '/path/to/script', prompt_style: UI::PROMPT_STYLE, header_style: UI::PROMPT_STYLE)
        raw = builder.prompt!(gum)
        params = { args: raw.to_s.lines.map(&:chomp).reject(&:empty?) }
        params[:trim] = true if builder.confirm!('Trim whitespace from output?')
        params
      end

      def self.date(builder)
        params = { format: builder.prompt!(Gum.input(placeholder: 'date format (e.g. %Y-%m-%d)',
                                                     prompt_style: UI::PROMPT_STYLE, header_style: UI::PROMPT_STYLE)) }
        date_optional_params(builder, params)
      end

      DATE_OPT_FIELDS = [
        [:offset, 'Add an offset?', 'offset in seconds (e.g. 86400)', :to_i],
        [:locale, 'Add a locale?', 'BCP47 locale (e.g. en-US, ja-JP)', nil],
        [:tz,     'Add a timezone?', 'IANA timezone (e.g. America/New_York)', nil]
      ].freeze

      def self.date_optional_params(builder, params)
        style = UI::PROMPT_STYLE
        DATE_OPT_FIELDS.each do |key, prompt, ph, conv|
          next unless builder.confirm!(prompt)

          val = builder.prompt!(Gum.input(placeholder: ph, prompt_style: style, header_style: style))
          params[key] = conv ? val.public_send(conv) : val
        end
        params
      end

      def self.form(builder)
        layout = form_layout(builder)
        fields = FormFields.collect(builder, layout)
        params = { layout: layout }
        params[:fields] = fields if fields.any?
        params
      end

      def self.form_layout(builder)
        ps = UI::PROMPT_STYLE
        ph = 'Form layout (use [[field_name]] for fields)'
        gum = if builder.confirm!('Multi-line form?')
                Gum.write(header: ph, prompt_style: ps, header_style: ps)
              else
                Gum.input(placeholder: ph, prompt_style: ps, header_style: ps)
              end
        builder.prompt!(gum)
      end

      def self.debug_trim(builder, params)
        params[:debug] = true if builder.confirm!('Enable debug mode?')
        params[:trim] = true if builder.confirm!('Trim whitespace from output?')
        params
      end

      private_class_method :collect_raw, :shell, :script, :date,
                           :date_optional_params, :form, :form_layout, :debug_trim
    end
  end
end
