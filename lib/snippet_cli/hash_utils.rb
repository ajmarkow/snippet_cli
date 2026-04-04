# frozen_string_literal: true

module SnippetCli
  # Shared hash-manipulation utilities used across validators.
  module HashUtils
    # Recursively converts symbol keys to string keys so the JSON schema
    # validator can match property names. Symbol values are also stringified.
    def self.stringify_keys_deep(obj)
      case obj
      when Hash
        obj.each_with_object({}) { |(k, v), h| h[k.to_s] = stringify_keys_deep(v) }
      when Array
        obj.map { |item| stringify_keys_deep(item) }
      when Symbol
        obj.to_s
      else
        obj
      end
    end
  end
end
