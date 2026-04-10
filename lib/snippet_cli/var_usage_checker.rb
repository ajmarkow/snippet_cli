# frozen_string_literal: true

require_relative 'form_field_parser'

module SnippetCli
  # Checks variable usage in a single snippet match.
  # Detects declared-but-unused vars and used-but-undeclared {{refs}}.
  module VarUsageChecker
    VAR_REF_PATTERN = /\{\{(\w+(?:\.\w+)?)\}\}/
    REPLACEMENT_KEYS = %i[replace html markdown image_path].freeze

    # Returns an array of human-readable warning strings.
    # vars: array of var hashes (symbol or string keyed)
    # replacement: hash with one of :replace, :html, :markdown, :image_path
    def self.match_warnings(vars, replacement, global_var_names: [])
      declared = extract_names(vars)
      used     = extract_refs(replacement)
      known    = declared + Array(global_var_names)
      unused_warnings(declared, used) + undeclared_warnings(used, known)
    end

    def self.extract_names(vars)
      Array(vars).flat_map do |v|
        name = v[:name] || v['name']
        next [] unless name

        (v[:type] || v['type']).to_s == 'form' ? form_field_refs(name, v) : [name]
      end
    end
    private_class_method :extract_names

    def self.form_field_refs(name, var)
      params = var[:params] || var['params'] || {}
      layout = params[:layout] || params['layout'] || ''
      FormFieldParser.extract(layout).map { |field| "#{name}.#{field}" }
    end
    private_class_method :form_field_refs

    def self.extract_refs(replacement)
      text = REPLACEMENT_KEYS.filter_map { |k| replacement[k] }.join
      text.scan(VAR_REF_PATTERN).flatten.uniq
    end
    private_class_method :extract_refs

    def self.unused_warnings(declared, used)
      (declared - used).map do |name|
        "Variable '#{name}' is declared but unused — add {{#{name}}} to the replacement text."
      end
    end
    private_class_method :unused_warnings

    def self.undeclared_warnings(used, declared)
      (used - declared).map do |name|
        "'{{#{name}}}' appears in the replacement but was not declared as a variable. " \
          "Remove {{#{name}}} from the replacement."
      end
    end
    private_class_method :undeclared_warnings
  end
end
