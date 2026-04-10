# frozen_string_literal: true

require 'spec_helper'
require 'snippet_cli/form_field_parser'

RSpec.describe SnippetCli::FormFieldParser do
  describe '.extract' do
    it 'returns field names from a layout string' do
      expect(described_class.extract('Hello [[first_name]], you are [[age]] years old'))
        .to eq(%w[first_name age])
    end

    it 'handles extra whitespace inside brackets' do
      expect(described_class.extract('[[  name  ]] and [[ city ]]'))
        .to eq(%w[name city])
    end

    it 'returns empty array when no fields are present' do
      expect(described_class.extract('No fields here')).to eq([])
    end

    it 'returns empty array for empty string' do
      expect(described_class.extract('')).to eq([])
    end

    it 'returns empty array for nil' do
      expect(described_class.extract(nil)).to eq([])
    end

    it 'does not return duplicate field names' do
      expect(described_class.extract('[[city]] and [[city]] again'))
        .to eq(%w[city city])
    end

    it 'does not match single-bracket var refs like {{name}}' do
      expect(described_class.extract('{{name}} is not [[name]]'))
        .to eq(%w[name])
    end

    it 'handles a layout with a single field' do
      expect(described_class.extract('[[email]]')).to eq(%w[email])
    end
  end
end
