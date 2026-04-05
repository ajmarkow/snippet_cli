# frozen_string_literal: true

require 'open3'

module SnippetCli
  class EspansoConfigError < StandardError; end

  # Discovers Espanso config paths by shelling out to `espanso path`.
  module EspansoConfig
    # Returns the match directory path (e.g. ~/.config/espanso/match).
    def self.match_dir
      output, status = Open3.capture2('espanso', 'path')
      raise EspansoConfigError, 'Could not determine Espanso config path. Is espanso installed?' unless status.success?

      config_line = output.lines.find { |l| l.start_with?('Config:') }
      raise EspansoConfigError, 'Could not determine Espanso config path from `espanso path` output.' unless config_line

      File.join(config_line.split(':', 2).last.strip, 'match')
    end

    # Returns sorted list of .yml files in the match directory.
    def self.match_files
      Dir.glob(File.join(match_dir, '**', '*.yml'), sort: true)
    end
  end
end
