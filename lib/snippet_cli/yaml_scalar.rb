# frozen_string_literal: true

module SnippetCli
  # Helpers for quoting scalar values in hand-built YAML output.
  module YamlScalar
    class InvalidCharacterError < StandardError; end

    BOOLEAN_LIKE = /\A(y|n|yes|no|true|false|on|off|null|~)\z/i
    LEADING_SPECIAL = /\A[:#&*!|>"%@`{}\[\]]/
    # Control characters that are invalid in YAML scalars (excludes tab \x09, newline \x0a, carriage return \x0d)
    CONTROL_CHARS = /[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/

    # Quote a scalar value for YAML output.
    # Strategy (per yaml-multiline.info):
    #   - string containing '  → normal-quoted with escaped inner content
    #   - string matching special YAML patterns → normal-quoted
    #   - all other strings → single-quoted
    def self.quote(str)
      return "''" if str.nil? || str.empty?

      reject_control_chars!(str)

      if str.include?("'")
        escaped = str.gsub('\\', '\\\\\\\\').gsub('"', '\\"')
        return "\"#{escaped}\""
      end

      return "\"#{str.gsub('\\', '\\\\\\\\').gsub('"', '\\"')}\"" if needs_normal_quote?(str)

      "'#{str}'"
    end

    def self.reject_control_chars!(str)
      return unless CONTROL_CHARS.match?(str)

      raise InvalidCharacterError, "String contains YAML-invalid control characters: #{str.inspect}"
    end
    private_class_method :reject_control_chars!

    def self.needs_normal_quote?(str)
      LEADING_SPECIAL.match?(str) ||
        BOOLEAN_LIKE.match?(str) ||
        str.include?(': ') ||
        str.include?(' #')
    end
    private_class_method :needs_normal_quote?
  end
end
