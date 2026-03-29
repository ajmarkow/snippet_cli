# frozen_string_literal: true

require 'dry/cli'
require 'gum'
require_relative '../conflict_detector'

module SnippetCli
  module Commands
    class Conflict < Dry::CLI::Command
      desc 'Detect duplicate triggers in an Espanso match YAML file'

      argument :file,    required: true,  desc: 'Path to Espanso match YAML file'
      argument :trigger, required: false, desc: 'Specific trigger to look up'

      def call(file:, trigger: nil, **)
        entries = load_entries(file)
        trigger ? show_trigger(entries, trigger) : show_conflicts(entries)
      rescue Psych::SyntaxError => e
        warn "Invalid YAML: #{e.message}"
        exit 1
      end

      private

      def load_entries(file)
        unless File.exist?(file)
          warn "File not found: #{file}"
          exit 1
        end
        ConflictDetector.extract_triggers(File.read(file))
      end

      def show_conflicts(entries)
        duplicates = entries.group_by { |e| e[:trigger] }.select { |_, v| v.size > 1 }
        if duplicates.empty?
          puts 'No conflicts found'
          return
        end
        puts 'The following conflicts were found:'
        Gum.table(build_rows(duplicates), columns: %w[Instance Trigger Line], print: true)
      end

      def build_rows(groups)
        groups.flat_map do |trig, occurrences|
          occurrences.each_with_index.map { |e, i| [i + 1, trig, e[:line]] }
        end
      end

      def show_trigger(entries, trigger)
        matches = entries.select { |e| e[:trigger] == trigger }
        if matches.empty?
          puts "Trigger '#{trigger}' not found"
          return
        end
        rows = matches.each_with_index.map { |e, i| [i + 1, e[:trigger], e[:line]] }
        puts 'The following conflicts were found:'
        Gum.table(rows, columns: %w[Instance Trigger Line], print: true)
      end
    end
  end
end
