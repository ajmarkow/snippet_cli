# frozen_string_literal: true

module SnippetCli
  # Parses [[field_name]] placeholders from form variable layout strings.
  module FormFieldParser
    PATTERN = /\[\[\s*(\w+)\s*\]\]/

    # Returns an array of field name strings extracted from the layout.
    def self.extract(layout)
      layout.to_s.scan(PATTERN).flatten
    end
  end
end
