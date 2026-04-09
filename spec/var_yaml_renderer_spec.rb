# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/var_yaml_renderer'

RSpec.describe SnippetCli::VarYamlRenderer do
  describe '.var_lines' do
    context 'with a simple scalar param' do
      let(:var) { { name: 'dt', type: 'date', params: { format: '%Y-%m-%d' } } }

      it 'starts with the name entry' do
        expect(described_class.var_lines(var).first).to eq('  - name: dt')
      end

      it 'includes the type line' do
        expect(described_class.var_lines(var)).to include('    type: date')
      end

      it 'includes params: header' do
        expect(described_class.var_lines(var)).to include('    params:')
      end

      it 'renders the scalar param' do
        expect(described_class.var_lines(var)).to include('      format: "%Y-%m-%d"')
      end
    end

    context 'with no params' do
      let(:var) { { name: 'x', type: 'echo', params: {} } }

      it 'omits the params: header' do
        expect(described_class.var_lines(var)).not_to include('    params:')
      end

      it 'returns only name and type lines' do
        expect(described_class.var_lines(var)).to eq(["'  - name: x'", '"    type: echo"'])
      end
    end

    context 'with an array param (random choices)' do
      let(:var) { { name: 'pick', type: 'random', params: { choices: %w[foo bar] } } }

      it 'renders choices as a block sequence' do
        lines = described_class.var_lines(var)
        expect(lines).to include('      choices:')
        expect(lines).to include("        - 'foo'")
        expect(lines).to include("        - 'bar'")
      end

      it 'does not render choices as a scalar string' do
        lines = described_class.var_lines(var).join("\n")
        expect(lines).not_to match(/choices:.*\[/)
      end
    end

    context 'with a boolean param' do
      let(:var) { { name: 'sh', type: 'shell', params: { cmd: 'date', trim: true } } }

      it 'renders booleans without quotes' do
        lines = described_class.var_lines(var)
        expect(lines).to include('      trim: true')
      end
    end
  end
end
