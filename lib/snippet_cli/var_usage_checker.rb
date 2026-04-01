# frozen_string_literal: true

module SnippetCli
  # Checks variable usage in a single snippet match.
  # Detects declared-but-unused vars and used-but-undeclared {{refs}}.
  module VarUsageChecker
    VAR_REF_PATTERN = /\{\{(\w+)\}\}/
    REPLACEMENT_KEYS = %i[replace html markdown image_path].freeze

    # Returns an array of human-readable warning strings.
    # vars: array of var hashes (symbol or string keyed)
    # replacement: hash with one of :replace, :html, :markdown, :image_path
    def self.match_warnings(vars, replacement)
      declared = extract_names(vars)
      used     = extract_refs(replacement)
      unused_warnings(declared, used) + undeclared_warnings(used, declared)
    end

    def self.extract_names(vars)
      Array(vars).filter_map { |v| v[:name] || v['name'] }
    end
    private_class_method :extract_names

    def self.extract_refs(replacement)
      text = REPLACEMENT_KEYS.filter_map { |k| replacement[k] }.join
      text.scan(VAR_REF_PATTERN).flatten.uniq
    end
    private_class_method :extract_refs

    def self.unused_warnings(declared, used)
      (declared - used).map { |name| "variable '#{name}' is declared but unused in replacement" }
    end
    private_class_method :unused_warnings

    def self.undeclared_warnings(used, declared)
      (used - declared).map { |name| "variable '{{#{name}}}' is used but not declared in vars" }
    end
    private_class_method :undeclared_warnings
  end
end
