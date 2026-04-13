# frozen_string_literal: true

require_relative 'match_validator'
require_relative 'vars_block_renderer'
require_relative 'yaml_param_renderer'
require_relative 'yaml_scalar'

module SnippetCli
  # Raised when the match data fails schema validation.
  class ValidationError < StandardError; end

  module SnippetBuilder
    # Builds an Espanso match YAML entry from the given parameters.
    # Validates against the Espanso match JSON schema before generating YAML.
    # Raises ValidationError on failure.
    def self.build(**opts)
      validate!(opts)
      render_yaml(opts)
    end

    def self.validate!(opts)
      schema_errors = MatchValidator.errors(to_match_hash(opts))
      return if schema_errors.empty?

      raise ValidationError, "Schema validation failed:\n#{schema_errors.map { |err| "  - #{err}" }.join("\n")}"
    end
    private_class_method :validate!

    def self.render_yaml(opts)
      lines = trigger_lines(opts[:triggers], opts[:is_regex], opts[:single_trigger])
      lines.concat(vars_lines(opts[:vars])) if opts[:vars]&.any?
      lines.concat(replacement_lines(opts))
      append_optional_fields(lines, opts)
      "#{lines.join("\n")}\n"
    end
    private_class_method :render_yaml

    def self.replacement_lines(opts)
      return replace_lines(opts[:replace]) if opts[:replace]
      return ["  image_path: #{YamlScalar.quote(opts[:image_path])}"] if opts[:image_path]
      return block_scalar_lines('html', opts[:html]) if opts[:html]
      return block_scalar_lines('markdown', opts[:markdown]) if opts[:markdown]

      []
    end
    private_class_method :replacement_lines

    def self.block_scalar_lines(key, val)
      YamlParamRenderer.scalar_lines(key, val, '  ')
    end
    private_class_method :block_scalar_lines

    def self.append_optional_fields(lines, opts)
      append_label_and_comment(lines, opts)
      append_search_terms(lines, opts[:search_terms])
      append_trigger_modifiers(lines, opts)
    end
    private_class_method :append_optional_fields

    def self.append_label_and_comment(lines, opts)
      lines << "  label: #{YamlScalar.quote(opts[:label])}" if opts[:label]&.then { |v| !v.empty? }
      lines << "  comment: #{YamlScalar.quote(opts[:comment])}" if opts[:comment]&.then { |v| !v.empty? }
    end
    private_class_method :append_label_and_comment

    def self.append_trigger_modifiers(lines, opts)
      return if opts[:image_path]

      lines << '  word: true' if opts[:word]
      lines << '  propagate_case: true' if opts[:propagate_case]
    end
    private_class_method :append_trigger_modifiers

    def self.append_search_terms(lines, terms)
      return unless terms&.any?

      lines << '  search_terms:'
      terms.each { |t| lines << "    - #{YamlScalar.quote(t)}" }
    end
    private_class_method :append_search_terms

    def self.trigger_lines(triggers, is_regex, single_trigger)
      if is_regex
        ["- regex: #{YamlScalar.quote(triggers.first)}"]
      elsif single_trigger
        ["- trigger: #{YamlScalar.quote(triggers.first)}"]
      else
        ['- triggers:'] + triggers.map { |t| "    - #{YamlScalar.quote(t)}" }
      end
    end
    private_class_method :trigger_lines

    def self.vars_lines(vars)
      VarsBlockRenderer.render(vars, indent: '  ')
    end
    private_class_method :vars_lines

    def self.replace_lines(str)
      block_scalar_lines('replace', str)
    end
    private_class_method :replace_lines

    def self.to_match_hash(opts)
      hash = build_trigger_hash(opts)
      merge_optional(hash, opts, :replace, :image_path, :html, :markdown, :vars, :label, :comment, :search_terms)
      merge_optional(hash, opts, :word, :propagate_case) unless opts[:image_path]
      hash
    end
    private_class_method :to_match_hash

    def self.merge_optional(hash, opts, *keys)
      keys.each { |key| hash[key] = opts[key] unless skip_key?(key, opts[key]) }
      hash
    end
    private_class_method :merge_optional

    def self.skip_key?(key, val)
      val.nil? || (val.is_a?(Array) && val.empty?) || (val.is_a?(String) && val.empty? && key != :replace)
    end
    private_class_method :skip_key?

    def self.build_trigger_hash(opts)
      if opts[:is_regex]
        { regex: opts[:triggers].first }
      elsif opts[:single_trigger]
        { trigger: opts[:triggers].first }
      else
        { triggers: opts[:triggers] }
      end
    end
    private_class_method :build_trigger_hash
  end
end
