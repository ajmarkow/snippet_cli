# frozen_string_literal: true

require 'dry/cli'
require 'gum'
require 'yaml'
require_relative '../conflict_detector'
require_relative '../ui'
require_relative '../wizard_helpers'
require_relative '../espanso_config'

module SnippetCli
  module Commands
    class Conflict < Dry::CLI::Command
      include WizardHelpers

      desc 'Detect duplicate triggers in an Espanso match YAML file (alias: c)'

      option :file,    aliases: ['-f'], desc: 'Path to Espanso match YAML file'
      option :trigger, type: :array, aliases: ['-t'], desc: 'Trigger(s) to look up (comma-separated or repeated flag)'

      def call(file: nil, trigger: nil, **)
        handle_errors do
          file ||= pick_match_file.last
          validate_file!(file)
          entries = load_entries(file)
          trigger ? show_trigger(entries, trigger) : show_conflicts(entries)
        end
      rescue Psych::SyntaxError => e
        warn "Invalid YAML: #{e.message}"
        exit 1
      end

      private

      def validate_file!(file)
        return if File.exist?(file)

        UI.error("File not found: #{file}")
        exit 1
      end

      def load_entries(file)
        ConflictDetector.extract_triggers(File.read(file))
      end

      def show_conflicts(entries)
        duplicates = entries.group_by { |e| e[:trigger] }.select { |_, v| v.size > 1 }
        if duplicates.empty?
          puts 'No conflicts found'
          return
        end
        puts "\e[38;5;231mThe following conflicts were found:\e[0m"
        Gum.table(build_rows(duplicates), columns: %w[Trigger Lines], separator: "\t", print: true)
      end

      def build_rows(groups)
        groups.map do |trig, occurrences|
          [trig, occurrences.map { |e| e[:line] }.join(', ')]
        end
      end

      def show_trigger(entries, triggers)
        matches = entries.select { |e| triggers.include?(e[:trigger]) }
        if matches.empty?
          puts "Trigger(s) #{triggers.join(', ')} not found"
          return
        end
        puts "\e[38;5;231mThe following conflicts were found:\e[0m"
        rows = build_rows(matches.group_by { |e| e[:trigger] })
        Gum.table(rows, columns: %w[Trigger Lines], separator: "\t", print: true)
      end
    end
  end
end
