# frozen_string_literal: true

require 'psych'

module SnippetCli
  module ConflictDetector
    TRIGGER_KEYS = %w[trigger triggers regex].freeze

    def self.extract_triggers(content)
      return [] if content.nil? || content.strip.empty?

      doc = Psych.parse(content)
      return [] unless doc

      root = doc.root
      return [] unless root.is_a?(Psych::Nodes::Mapping)

      matches_seq = find_matches_sequence(root)
      return [] unless matches_seq

      extract_from_sequence(matches_seq)
    end

    def self.find_matches_sequence(mapping)
      mapping.children.each_slice(2) do |key, value|
        return value if key.is_a?(Psych::Nodes::Scalar) && key.value == 'matches'
      end
      nil
    end
    private_class_method :find_matches_sequence

    def self.extract_from_sequence(sequence)
      return [] unless sequence.is_a?(Psych::Nodes::Sequence)

      sequence.children.each_with_object([]) do |match_node, entries|
        next unless match_node.is_a?(Psych::Nodes::Mapping)

        extract_from_mapping(match_node, entries)
      end
    end
    private_class_method :extract_from_sequence

    def self.extract_from_mapping(mapping, entries)
      mapping.children.each_slice(2) do |key, value|
        next unless key.is_a?(Psych::Nodes::Scalar)

        extract_key_value(key.value, value, entries)
      end
    end
    private_class_method :extract_from_mapping

    def self.extract_key_value(key, value, entries)
      case key
      when 'trigger', 'regex'
        entries << { trigger: value.value, line: value.start_line + 1 } if value.is_a?(Psych::Nodes::Scalar)
      when 'triggers'
        extract_triggers_array(value, entries)
      end
    end
    private_class_method :extract_key_value

    def self.extract_triggers_array(sequence, entries)
      return unless sequence.is_a?(Psych::Nodes::Sequence)

      sequence.children.each do |scalar|
        entries << { trigger: scalar.value, line: scalar.start_line + 1 } if scalar.is_a?(Psych::Nodes::Scalar)
      end
    end
    private_class_method :extract_triggers_array
  end
end
