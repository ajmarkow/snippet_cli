# frozen_string_literal: true

require_relative 'match_validator'
require_relative 'yaml_scalar'

module SnippetCli
  # Raised when the match data fails schema validation.
  class ValidationError < StandardError; end

  module SnippetBuilder # rubocop:disable Metrics/ModuleLength
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
      if val.include?("\n")
        indented = val.lines.map { |line| "    #{line.chomp}" }.join("\n")
        ["  #{key}: |", indented]
      else
        ["  #{key}: #{YamlScalar.quote(val)}"]
      end
    end
    private_class_method :block_scalar_lines

    def self.append_optional_fields(lines, opts)
      lines << "  label: #{YamlScalar.quote(opts[:label])}" if opts[:label]&.then { !it.empty? }
      lines << "  comment: #{YamlScalar.quote(opts[:comment])}" if opts[:comment]&.then { !it.empty? }
    end
    private_class_method :append_optional_fields

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
      lines = ['  vars:']
      vars.each do |var|
        lines << "  - name: #{var[:name]}"
        lines << "    type: #{var[:type]}"
        params = var[:params]
        next unless params&.any?

        lines << '    params:'
        params.each { |key, val| lines.concat(param_lines(key, val, '      ')) }
      end
      lines
    end
    private_class_method :vars_lines

    def self.param_lines(key, val, indent)
      if val.is_a?(Array)
        ["#{indent}#{key}:", *val.map { |item| "#{indent}  - #{YamlScalar.quote(item.to_s)}" }]
      else
        ["#{indent}#{key}: #{YamlScalar.quote(val.to_s)}"]
      end
    end
    private_class_method :param_lines

    def self.replace_lines(str)
      if str.include?("\n")
        indented = str.lines.map { |line| "    #{line.chomp}" }.join("\n")
        ['  replace: |', indented]
      else
        ["  replace: #{YamlScalar.quote(str)}"]
      end
    end
    private_class_method :replace_lines

    def self.to_match_hash(opts)
      hash = build_trigger_hash(opts)
      merge_optional(hash, opts, :replace, :image_path, :html, :markdown, :vars, :label, :comment)
    end
    private_class_method :to_match_hash

    def self.merge_optional(hash, opts, *keys)
      keys.each do |key|
        val = opts[key]
        hash[key] = val if val.is_a?(Array) ? val.any? : val && !val.to_s.empty?
      end
      hash
    end
    private_class_method :merge_optional

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
