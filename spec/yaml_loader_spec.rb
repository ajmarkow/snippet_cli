# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/yaml_loader'
require 'tempfile'

RSpec.describe SnippetCli::YamlLoader do
  describe '.load' do
    context 'when the file exists and is valid YAML' do
      let(:yaml_file) do
        Tempfile.new(['valid', '.yml']).tap do |f|
          f.write("matches:\n  - trigger: ':t'\n    replace: 'hi'\n")
          f.close
        end
      end
      after { yaml_file.unlink }

      it 'returns the parsed data' do
        result = described_class.load(yaml_file.path)
        expect(result).to eq({ 'matches' => [{ 'trigger' => ':t', 'replace' => 'hi' }] })
      end

      it 'returns an empty hash for an empty file' do
        empty = Tempfile.new(['empty', '.yml']).tap(&:close)
        expect(described_class.load(empty.path)).to eq({})
        empty.unlink
      end
    end

    context 'when the file does not exist' do
      it 'raises FileMissingError' do
        expect { described_class.load('/no/such/file.yml') }
          .to raise_error(SnippetCli::FileMissingError)
      end
    end

    context 'when the file contains invalid YAML' do
      let(:bad_file) do
        Tempfile.new(['bad', '.yml']).tap do |f|
          f.write("foo: [\nbad yaml")
          f.close
        end
      end
      after { bad_file.unlink }

      it 'raises InvalidYamlError' do
        expect { described_class.load(bad_file.path) }
          .to raise_error(SnippetCli::InvalidYamlError)
      end

      it 'includes "Invalid YAML" in the message' do
        expect { described_class.load(bad_file.path) }
          .to raise_error(SnippetCli::InvalidYamlError, /invalid yaml/i)
      end
    end
  end
end
