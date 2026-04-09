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

    context 'nil and empty string' do
      it "returns '' for nil" do
        expect(described_class.quote(nil)).to eq("''")
      end

      it "returns '' for empty string" do
        expect(described_class.quote('')).to eq("''")
      end
    end

    context 'single-quote path (plain strings)' do
      it 'wraps a plain string in single quotes' do
        expect(described_class.quote('hello')).to eq("'hello'")
      end

      it 'wraps a numeric-looking string in single quotes' do
        expect(described_class.quote('42')).to eq("'42'")
      end

      it 'wraps a string with a trailing colon in single quotes' do
        expect(described_class.quote('foo:')).to eq("'foo:'")
      end

      it 'round-trips through YAML.safe_load' do
        expect(YAML.safe_load(described_class.quote('hello world'))).to eq('hello world')
      end
    end

    context 'double-quote path — string contains single quote' do
      it 'wraps in double quotes' do
        result = described_class.quote("it's")
        expect(result).to start_with('"').and end_with('"')
      end

      it 'round-trips through YAML.safe_load' do
        str = "it's a test"
        expect(YAML.safe_load(described_class.quote(str))).to eq(str)
      end

      it 'escapes inner double quotes' do
        str = %(it's a "test")
        expect(YAML.safe_load(described_class.quote(str))).to eq(str)
      end
    end

    context 'double-quote path — needs_normal_quote? triggers' do
      context 'LEADING_SPECIAL characters' do
        it 'double-quotes strings starting with :' do
          expect(described_class.quote(':hello')).to start_with('"')
        end

        it 'double-quotes strings starting with %' do
          expect(described_class.quote('%Y-%m-%d')).to start_with('"')
        end

        it 'double-quotes strings starting with {' do
          expect(described_class.quote('{{var}}')).to start_with('"')
        end

        it 'double-quotes strings starting with [' do
          expect(described_class.quote('[item]')).to start_with('"')
        end

        it 'double-quotes strings starting with !' do
          expect(described_class.quote('!important')).to start_with('"')
        end

        it 'double-quotes strings starting with |' do
          expect(described_class.quote('|value')).to start_with('"')
        end

        it 'double-quotes strings starting with >' do
          expect(described_class.quote('>value')).to start_with('"')
        end

        it 'double-quotes strings starting with &' do
          expect(described_class.quote('&anchor')).to start_with('"')
        end

        it 'double-quotes strings starting with *' do
          expect(described_class.quote('*alias')).to start_with('"')
        end

        it 'round-trips each LEADING_SPECIAL string through YAML.safe_load' do
          [':x', '%x', '{x', '[x', '!x', '|x', '>x', '&x', '*x'].each do |str|
            expect(YAML.safe_load(described_class.quote(str))).to eq(str), "failed for #{str.inspect}"
          end
        end
      end

      context 'boolean-like values' do
        %w[true false yes no on off null].each do |val|
          it "double-quotes #{val}" do
            expect(described_class.quote(val)).to start_with('"')
          end

          it "double-quotes #{val.upcase}" do
            expect(described_class.quote(val.upcase)).to start_with('"')
          end

          it "round-trips #{val} through YAML.safe_load as a string" do
            expect(YAML.safe_load(described_class.quote(val))).to eq(val)
          end
        end

        it 'double-quotes ~' do
          expect(described_class.quote('~')).to start_with('"')
        end

        it 'round-trips ~ through YAML.safe_load as a string' do
          expect(YAML.safe_load(described_class.quote('~'))).to eq('~')
        end
      end

      context 'inline comment pattern (space + hash)' do
        it 'double-quotes strings containing " #"' do
          expect(described_class.quote('value #comment')).to start_with('"')
        end

        it 'round-trips through YAML.safe_load' do
          str = 'value #comment'
          expect(YAML.safe_load(described_class.quote(str))).to eq(str)
        end
      end

      context 'mapping indicator pattern (colon + space)' do
        it 'double-quotes strings containing ": "' do
          expect(described_class.quote('key: value')).to start_with('"')
        end

        it 'round-trips through YAML.safe_load' do
          str = 'Run: hello'
          expect(YAML.safe_load(described_class.quote(str))).to eq(str)
        end
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

    context 'additional control characters' do
      it 'raises for DEL (0x7f)' do
        expect { described_class.quote("\x7f") }.to raise_error(SnippetCli::YamlScalar::InvalidCharacterError)
      end

      it 'raises for VT (0x0b)' do
        expect { described_class.quote("\x0b") }.to raise_error(SnippetCli::YamlScalar::InvalidCharacterError)
      end

      it 'raises for FF (0x0c)' do
        expect { described_class.quote("\x0c") }.to raise_error(SnippetCli::YamlScalar::InvalidCharacterError)
      end

      it 'allows carriage return (0x0d)' do
        expect { described_class.quote("hello\rworld") }.not_to raise_error
      end
    end
  end
end
