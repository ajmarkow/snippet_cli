# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/string_helper'

RSpec.describe SnippetCli::StringHelper do
  describe '.ensure_trailing_newline' do
    it 'returns the string unchanged when it already ends with a newline' do
      expect(described_class.ensure_trailing_newline("hello\n")).to eq("hello\n")
    end

    it 'appends a newline when the string does not end with one' do
      expect(described_class.ensure_trailing_newline('hello')).to eq("hello\n")
    end

    it 'handles a string with multiple trailing newlines by leaving them intact' do
      expect(described_class.ensure_trailing_newline("hello\n\n")).to eq("hello\n\n")
    end

    it 'appends a newline to an empty string' do
      expect(described_class.ensure_trailing_newline('')).to eq("\n")
    end
  end
end
