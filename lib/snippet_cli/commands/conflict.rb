# frozen_string_literal: true

require 'dry/cli'
require 'gum'
require 'yaml'
require_relative '../conflict_detector'
require_relative '../ui'
require_relative '../wizard_helpers'
require_relative '../file_helper'
require_relative '../espanso_config'

module SnippetCli
  module Commands
    class Conflict < Dry::CLI::Command
      include WizardHelpers

      desc 'Detect duplicate triggers in an Espanso match YAML file (alias: c)'

      option :file,    aliases: ['-f'], desc: 'Path to Espanso match YAML file'
      option :trigger, type: :array, aliases: ['-t'], desc: 'Trigger(s) to look up (comma-separated or repeated flag)'

      def call(file: nil, trigger: nil, **)
        handle_errors(NoMatchFilesError) { detect_conflicts(file, trigger) }
      rescue FileMissingError => e
        warn e.message
        exit 1
      rescue Psych::SyntaxError => e
        warn "Invalid YAML: #{e.message}"
        exit 1
      end

      private

      def detect_conflicts(file, trigger)
        file ||= pick_match_file.last
        FileHelper.ensure_readable!(file)
        entries = load_entries(file)
        trigger ? show_trigger(entries, trigger) : show_conflicts(entries)
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
        UI.note('The following conflicts were found:')
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
        UI.note('The following conflicts were found:')
        rows = build_rows(matches.group_by { |e| e[:trigger] })
        Gum.table(rows, columns: %w[Trigger Lines], separator: "\t", print: true)
      end
    end
  end
end
