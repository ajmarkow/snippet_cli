# frozen_string_literal: true

module SnippetCli
  # Helpers for quoting scalar values in hand-built YAML output.
  module YamlScalar
    BOOLEAN_LIKE = /\A(y|n|yes|no|true|false|on|off|null|~)\z/i
    LEADING_SPECIAL = /\A[:#&*!|>"%@`{}\[\]]/

    # Quote a scalar value for YAML output.
    # Strategy (per yaml-multiline.info):
    #   - string containing '  → double-quoted with escaped inner content
    #   - string matching special YAML patterns → double-quoted
    #   - all other strings → single-quoted
    def self.quote(str)
      return "''" if str.nil? || str.empty?

      if str.include?("'")
        escaped = str.gsub('\\', '\\\\\\\\').gsub('"', '\\"')
        return "\"#{escaped}\""
      end

      return "\"#{str.gsub('"', '\\"')}\"" if needs_double_quote?(str)

      "'#{str}'"
    end

    def self.needs_double_quote?(str)
      LEADING_SPECIAL.match?(str) ||
        BOOLEAN_LIKE.match?(str) ||
        str.include?(': ') ||
        str.include?(' #')
    end
    private_class_method :needs_double_quote?
  end
end
