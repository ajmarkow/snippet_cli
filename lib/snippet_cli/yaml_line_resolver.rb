# frozen_string_literal: true

require 'psych'

module SnippetCli
  # Resolves a JSON Pointer (e.g. "/matches/354") to a 1-based line number
  # in a YAML file by navigating the Psych AST node tree.
  module YamlLineResolver
    # Returns the 1-based line number for the given JSON pointer, or nil if
    # the pointer is empty, invalid, or cannot be resolved in the file.
    def self.resolve(file, pointer)
      return nil if pointer.to_s.empty?

      segments = pointer.to_s.sub(%r{\A/}, '').split('/')
      return nil if segments.empty?

      tree = Psych.parse_file(file)
      node = navigate(tree.root, segments)
      node&.start_line&.+(1)
    rescue StandardError
      nil
    end

    def self.navigate(node, segments)
      return node if segments.empty?

      seg, *rest = segments
      case node
      when Psych::Nodes::Document  then navigate(node.root, segments)
      when Psych::Nodes::Mapping   then navigate_mapping(node, seg, rest)
      when Psych::Nodes::Sequence  then navigate(node.children[Integer(seg, 10)], rest)
      end
    rescue ArgumentError, TypeError
      nil
    end
    private_class_method :navigate

    def self.navigate_mapping(node, key, rest)
      node.children.each_slice(2) do |k, v|
        return navigate(v, rest) if k.value == key
      end
      nil
    end
    private_class_method :navigate_mapping
  end
end
