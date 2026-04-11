# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/yaml_line_resolver'
require 'tempfile'

RSpec.describe SnippetCli::YamlLineResolver do
  let(:yaml_content) do
    <<~YAML
      matches:
        - trigger: ":a"
          replace: "A"
        - trigger: ":b"
          replace: "B"
        - trigger: ":c"
          replace: "C"
    YAML
  end

  let(:tmpfile) do
    Tempfile.new(['resolver_spec', '.yml']).tap do |f|
      f.write(yaml_content)
      f.close
    end
  end

  after { tmpfile.unlink }

  describe '.resolve' do
    it 'returns nil for an empty pointer' do
      expect(described_class.resolve(tmpfile.path, '')).to be_nil
    end

    it 'resolves /matches/0 to line 2 (first sequence item)' do
      expect(described_class.resolve(tmpfile.path, '/matches/0')).to eq(2)
    end

    it 'resolves /matches/1 to line 4 (second sequence item)' do
      expect(described_class.resolve(tmpfile.path, '/matches/1')).to eq(4)
    end

    it 'resolves /matches/2 to line 6 (third sequence item)' do
      expect(described_class.resolve(tmpfile.path, '/matches/2')).to eq(6)
    end

    it 'returns nil for a pointer that cannot be resolved' do
      expect(described_class.resolve(tmpfile.path, '/nonexistent/0')).to be_nil
    end

    it 'returns nil for an out-of-bounds index' do
      expect(described_class.resolve(tmpfile.path, '/matches/99')).to be_nil
    end
  end
end
