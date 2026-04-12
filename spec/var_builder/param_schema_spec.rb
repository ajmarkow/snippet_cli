# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/var_builder/param_schema'

RSpec.describe SnippetCli::VarBuilder::ParamSchema do
  describe '.known_type?' do
    it 'returns true for all standard types' do
      %w[echo random choice date shell script form clipboard].each do |type|
        expect(described_class.known_type?(type)).to be(true)
      end
    end

    it 'returns false for unknown types' do
      expect(described_class.known_type?('bogus')).to be(false)
    end
  end

  describe '.schema_for' do
    it 'returns the schema hash for a known type' do
      schema = described_class.schema_for('echo')
      expect(schema).to include(:required, :optional, :field_types)
    end

    it 'returns nil for unknown types' do
      expect(described_class.schema_for('bogus')).to be_nil
    end
  end

  describe '.valid_params?' do
    context 'echo type' do
      it 'accepts valid params' do
        expect(described_class.valid_params?('echo', { echo: 'hello' })).to be(true)
      end

      it 'rejects missing required field' do
        expect(described_class.valid_params?('echo', {})).to be(false)
      end

      it 'rejects unknown fields' do
        expect(described_class.valid_params?('echo', { echo: 'hi', bogus: 1 })).to be(false)
      end
    end

    context 'shell type' do
      it 'accepts required fields only' do
        expect(described_class.valid_params?('shell', { cmd: 'date', shell: 'bash' })).to be(true)
      end

      it 'accepts with optional fields' do
        params = { cmd: 'date', shell: 'bash', trim: true, debug: true }
        expect(described_class.valid_params?('shell', params)).to be(true)
      end

      it 'rejects when cmd is missing' do
        expect(described_class.valid_params?('shell', { shell: 'bash' })).to be(false)
      end

      it 'rejects unknown fields' do
        expect(described_class.valid_params?('shell', { cmd: 'date', shell: 'bash', nope: true })).to be(false)
      end
    end

    context 'date type' do
      it 'accepts format only' do
        expect(described_class.valid_params?('date', { format: '%Y-%m-%d' })).to be(true)
      end

      it 'accepts with all optional fields' do
        params = { format: '%Y-%m-%d', offset: 86_400, locale: 'en-US', tz: 'America/New_York' }
        expect(described_class.valid_params?('date', params)).to be(true)
      end

      it 'rejects missing format' do
        expect(described_class.valid_params?('date', { offset: 86_400 })).to be(false)
      end
    end

    context 'clipboard type' do
      it 'accepts empty params' do
        expect(described_class.valid_params?('clipboard', {})).to be(true)
      end

      it 'rejects any fields' do
        expect(described_class.valid_params?('clipboard', { extra: 'nope' })).to be(false)
      end
    end

    context 'unknown type' do
      it 'returns false' do
        expect(described_class.valid_params?('bogus', {})).to be(false)
      end
    end
  end
end
