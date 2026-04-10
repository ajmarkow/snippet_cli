# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/vars_block_renderer'

RSpec.describe SnippetCli::VarsBlockRenderer do
  let(:single_var) { [{ name: 'dt', type: 'date', params: { format: '%Y-%m-%d' } }] }
  let(:two_vars) do
    [
      { name: 'name', type: 'echo', params: { echo: 'World' } },
      { name: 'dt',   type: 'date', params: { format: '%Y-%m-%d' } }
    ]
  end

  describe '.render' do
    context 'with no indent (default)' do
      it 'starts with a bare vars: header' do
        expect(described_class.render(single_var).first).to eq('vars:')
      end

      it 'includes var name and type lines from VarYamlRenderer' do
        lines = described_class.render(single_var)
        expect(lines).to include('  - name: dt')
        expect(lines).to include('    type: date')
      end

      it 'returns an array of strings' do
        expect(described_class.render(single_var)).to be_an(Array)
        expect(described_class.render(single_var)).to all(be_a(String))
      end

      it 'includes all vars when multiple are given' do
        lines = described_class.render(two_vars)
        expect(lines).to include('  - name: name')
        expect(lines).to include('  - name: dt')
      end

      it 'returns just the header line for an empty vars array' do
        expect(described_class.render([])).to eq(['vars:'])
      end
    end

    context 'with indent: "  "' do
      it 'prefixes the vars: header with the indent' do
        expect(described_class.render(single_var, indent: '  ').first).to eq('  vars:')
      end

      it 'does not add indent to var entry lines (VarYamlRenderer owns that)' do
        lines = described_class.render(single_var, indent: '  ')
        expect(lines).to include('  - name: dt')
        expect(lines).to include('    type: date')
      end

      it 'returns just the indented header for an empty vars array' do
        expect(described_class.render([], indent: '  ')).to eq(['  vars:'])
      end
    end
  end
end
