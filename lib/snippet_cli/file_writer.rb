# frozen_string_literal: true

module SnippetCli
  # Shared file-writing interface for all Espanso file writers.
  # Centralises the write operation so file-safety behaviors (e.g. atomic write)
  # need only be added here.
  module FileWriter
    def self.write(path, content)
      File.write(path, content)
    end
  end
end
