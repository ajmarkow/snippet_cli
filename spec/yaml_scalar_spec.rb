# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/yaml_scalar'

RSpec.describe SnippetCli::YamlScalar do
  describe '.quote' do
    context 'control characters' do
      it 'raises an error for a string containing NUL' do
        expect { described_class.quote("\x00") }.to raise_error(SnippetCli::YamlScalar::InvalidCharacterError)
      end

      it 'raises an error for a string containing BEL' do
        expect { described_class.quote("\x07") }.to raise_error(SnippetCli::YamlScalar::InvalidCharacterError)
      end

      it 'raises an error for a string containing ESC' do
        expect { described_class.quote("\x1b") }.to raise_error(SnippetCli::YamlScalar::InvalidCharacterError)
      end

      it 'raises an error for a string with mixed control characters' do
        expect { described_class.quote("hello\x00\x07\x1bworld") }.to raise_error(SnippetCli::YamlScalar::InvalidCharacterError)
      end

      it 'allows tabs and newlines' do
        expect { described_class.quote("hello\tworld") }.not_to raise_error
        expect { described_class.quote("hello\nworld") }.not_to raise_error
      end
    end

    context 'backslash escaping in double-quoted output' do
      it 'escapes backslashes when string triggers needs_normal_quote?' do
        # Starts with ":" which triggers LEADING_SPECIAL → double-quote path
        result = described_class.quote(':\\x00')
        expect(result).to eq('":\\\\x00"')
      end

      it 'produces valid YAML when backslash sequences are present' do
        result = described_class.quote(':\\x00')
        parsed = YAML.safe_load(result)
        expect(parsed).to eq(':\\x00')
      end
    end
  end
end
