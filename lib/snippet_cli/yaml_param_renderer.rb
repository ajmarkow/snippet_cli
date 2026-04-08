# frozen_string_literal: true

require_relative 'yaml_scalar'

module SnippetCli
  # Renders variable param key/value pairs as YAML lines with proper indentation.
  module YamlParamRenderer
    def self.lines(key, val, indent)
      case val
      when Hash  then hash_lines(key, val, indent)
      when Array then ["#{indent}#{key}:", *val.map { |item| "#{indent}  - #{YamlScalar.quote(item.to_s)}" }]
      when true, false then ["#{indent}#{key}: #{val}"]
      else scalar_lines(key, val.to_s, indent)
      end
    end

    def self.hash_lines(key, hash, indent)
      result = ["#{indent}#{key}:"]
      hash.each { |k, v| result.concat(lines(k, v, "#{indent}  ")) }
      result
    end
    private_class_method :hash_lines

    def self.scalar_lines(key, str, indent)
      if str.include?("\n")
        indented = str.lines.map { |line| "#{indent}  #{line.chomp}" }.join("\n")
        ["#{indent}#{key}: |", indented]
      else
        ["#{indent}#{key}: #{YamlScalar.quote(str)}"]
      end
    end
    private_class_method :scalar_lines
  end
end
