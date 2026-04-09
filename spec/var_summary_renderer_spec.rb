# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/var_summary_renderer'

RSpec.describe SnippetCli::VarSummaryRenderer do
  describe '.rows' do
    context 'with a non-form variable' do
      let(:vars) { [{ name: 'dt', type: 'date', params: {} }] }

      it 'returns [[name, type]] for plain vars' do
        expect(described_class.rows(vars)).to eq([%w[dt date]])
      end
    end

    context 'with a form variable' do
      let(:vars) { [{ name: 'myform', type: 'form', params: { layout: 'Name: [[name]] City: [[city]]' } }] }

      it 'expands each field as a dot-notation row' do
        rows = described_class.rows(vars)
        expect(rows).to include(['myform.name', 'form field'])
        expect(rows).to include(['myform.city', 'form field'])
      end

      it 'does not include the bare form var as a row' do
        rows = described_class.rows(vars)
        expect(rows).not_to include(%w[myform form])
      end
    end

    context 'with mixed vars' do
      let(:vars) do
        [
          { name: 'myform', type: 'form', params: { layout: 'Hi [[name]]' } },
          { name: 'greeting', type: 'echo', params: {} }
        ]
      end

      it 'renders form fields and regular vars together' do
        rows = described_class.rows(vars)
        expect(rows).to eq([['myform.name', 'form field'], %w[greeting echo]])
      end
    end
  end

  describe '.show' do
    let(:vars) { [{ name: 'dt', type: 'date', params: {} }] }

    before do
      allow(Gum).to receive(:table)
      allow($stdout).to receive(:puts)
    end

    it 'calls UI.note with {{var}} syntax explanation' do
      expect(SnippetCli::UI).to receive(:note).with(a_string_including('{{var}}'))
      described_class.show(vars)
    end

    it 'calls UI.note showing the var name in braces' do
      expect(SnippetCli::UI).to receive(:note).with(a_string_including('{{dt}}'))
      described_class.show(vars)
    end

    it 'calls Gum.table with Name and Type columns' do
      expect(Gum).to receive(:table).with([%w[dt date]], columns: %w[Name Type], print: true)
      described_class.show(vars)
    end

    it 'returns a callable lambda' do
      result = described_class.show(vars)
      expect(result).to respond_to(:call)
    end
  end
end
