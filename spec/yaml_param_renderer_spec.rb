# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/yaml_param_renderer'

RSpec.describe SnippetCli::YamlParamRenderer do
  describe '.scalar_lines' do
    context 'with a single-line value' do
      it 'returns a single quoted-scalar line' do
        result = described_class.scalar_lines('replace', 'Hello!', '  ')
        expect(result).to eq(["  replace: 'Hello!'"])
      end
    end

    context 'with a multiline value' do
      it 'returns a block scalar header and indented content lines' do
        result = described_class.scalar_lines('replace', "line one\nline two", '  ')
        expect(result.first).to eq('  replace: |')
        expect(result.last).to include('    line one')
        expect(result.last).to include('    line two')
      end
    end
  end
end
