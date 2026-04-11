# frozen_string_literal: true

require 'gum'
require_relative 'prompt_helpers'

module SnippetCli
  module WizardHelpers
    # Selects an Espanso match file for saving.
    # Auto-selects when only one file exists; otherwise prompts via Gum.filter.
    module MatchFileSelector
      include PromptHelpers

      # Returns [basename, full_path] of the chosen match file.
      # Raises NoMatchFilesError when no files exist.
      def pick_match_file
        files = EspansoConfig.match_files
        abort_no_match_files if files.empty?
        return [File.basename(files.first), files.first] if files.size == 1

        basenames = files.map { |f| File.basename(f) }
        chosen = prompt!(Gum.filter(*basenames, header: 'Save to which match file?'))
        [chosen, files.find { |f| File.basename(f) == chosen }]
      end

      private

      def abort_no_match_files
        raise NoMatchFilesError, 'No match files found in Espanso config.'
      end
    end
  end
end
